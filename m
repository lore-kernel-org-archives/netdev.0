From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] veth: Fix unregister_netdevice_queue for
 veth
Date: Sat, 31 Oct 2009 10:41:39 +0100
Message-ID: <4AEC0653.8050109@gmail.com>
References: <4AEA8F0F.4030100@gmail.com> <m1hbtgmqew.fsf@fess.ebiederm.org> <m1639wjshq.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Pavel Emelyanov <xemul@openvz.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60056 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932262AbZJaJlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Oct 2009 05:41:40 -0400
In-Reply-To: <m1639wjshq.fsf_-_@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman a =E9crit :
> I tested the recent unregister many changes and got a weird,
> nasty and seemingly unrelasted kernel oops. Changing
> unregister_netdevice_queue to use list_move_tail fixes
> the problem for me.
>=20
> ip link add type veth
> rmmod veth
>=20
> ls /sys/class/net/
> showed one of the veth devices still present.
>=20
> A subsequent ip link oopsed the box.
>=20
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>=20

Yes, problem is __rtnl_kill_links() doesnt anymore restart
its loop and does :

        for_each_netdev(net, dev) {
                if (dev->rtnl_link_ops =3D=3D ops)
                        ops->dellink(dev, &list_kill);
        }
        unregister_netdevice_many(&list_kill);

As veth wants in its dellink() method to unregister two netdevices,
we really want your fix or corrupt list_kill

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks Eric
