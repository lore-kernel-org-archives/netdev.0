From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next-2.6] bonding: move processing of recv handlers
 into handle_frame()
Date: Tue, 19 Apr 2011 16:02:32 +0200
Message-ID: <1303221752.3480.217.camel@edumazet-laptop>
References: <1303220896-9092-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46558 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678Ab1DSOCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 10:02:38 -0400
Received: by wwa36 with SMTP id 36so6995795wwa.1
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 07:02:37 -0700 (PDT)
In-Reply-To: <1303220896-9092-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 19 avril 2011 =C3=A0 15:48 +0200, Jiri Pirko a =C3=A9crit :
> Since now when bonding uses rx_handler, all traffic going into bond
> device goes thru bond_handle_frame. So there's no need to go back int=
o
> bonding code later via ptype handlers. This patch converts
> original ptype handlers into "bonding receive probes". These function=
s
> are called from bond_handle_frame and they are registered per-mode.
>=20
> Note that vlan packets are also handled because they are always untag=
ged
> thanks to vlan_untag()
>=20
> Note that this also allows arpmon for eth-bond-bridge-vlan topology.
>=20
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>



>  			}
> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bond=
ing.h
> index 6126c6a..85fb822 100644
> --- a/drivers/net/bonding/bonding.h
> +++ b/drivers/net/bonding/bonding.h
> @@ -226,6 +226,8 @@ struct bonding {
>  	struct   slave *primary_slave;
>  	bool     force_primary;
>  	s32      slave_cnt; /* never change this value outside the attach/d=
etach wrappers */
> +	void     (*recv_probe)(struct sk_buff *, struct bonding *,
> +			       struct slave *);
>  	rwlock_t lock;
>  	rwlock_t curr_slave_lock;
>  	s8       kill_timers;


Any performance numbers ?

I am asking because recv_probe sits in a often dirtied cache line...

It would be nice to separate rx & tx path needs



