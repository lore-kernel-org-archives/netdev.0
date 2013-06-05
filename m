From: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Subject: Re: [PATCH] net: tun: release the reference of tun device in tun_recvmsg
Date: Wed, 5 Jun 2013 17:20:14 +0200
Message-ID: <201306051720.15029.a.miskiewicz@gmail.com>
References: <201304250822.38944.a.miskiewicz@gmail.com> <201305290029.35303.a.miskiewicz@gmail.com> <51AC5345.6020904@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	Balakumaran Kannan <kumaran.4353@gmail.com>,
	Maruthi Thotad <Maruthi.Thotad@ap.sony.com>,
	"David S. Miller" <davem@davemloft.net>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f53.google.com ([209.85.214.53]:35065 "EHLO
	mail-bk0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756210Ab3FEPUT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 11:20:19 -0400
Received: by mail-bk0-f53.google.com with SMTP id e11so404678bkh.26
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 08:20:17 -0700 (PDT)
In-Reply-To: <51AC5345.6020904@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 03 of June 2013, Gao feng wrote:
> On 05/29/2013 06:29 AM, Arkadiusz Miskiewicz wrote:
> > On Friday 26 of April 2013, Jason Wang wrote:
> >> On 04/26/2013 01:03 PM, Gao feng wrote:
> >>> On 04/25/2013 11:04 PM, Arkadiusz Miskiewicz wrote:
> >>>> On Thursday 25 of April 2013, Gao feng wrote:
> >>>>> We forget to release the reference of tun device in tun_recvmsg=
=2E
> >>>>> bug introduced in commit 54f968d6efdbf7dec36faa44fc11f01b0e4d19=
90
> >>>>> (tuntap: move socket to tun_file)
> >>>>=20
> >>>> Hm, still hitting the problem even with the patch - dmesg:
> >>> Ok, seams there are another problems we haven't discovered.
> >>> it's excellent if you can find out which commit introduces this
> >>> bug by git bisect.
> >>>=20
> >>> Thanks!
> >>=20
> >> Yes, bisect will be helpful. If you could not do it, please tell m=
e the
> >> steps to reproduce the issue and the tree you used. I just test wi=
th
> >> net.git and net-next.git with a tap device created by tunctl, didn=
't
> >> meet the issue.
> >=20
> > Took a while. Suspected patch is below. I'm running fresh linus git
> > (3.10.0-rc3-00046-g58f8bbd) with the patch reverted and couldn't
> > reproduce problem anymore after several tries (will do more testing
> > in meantime).
>=20
> Thanks for your helpful work :)
> I already send a patch to fix this problem.

Please push it into stable kernel (3.9) queue, too. Works well here.

commit 534c877928a16ae5f9776436a497109639bf67dc
Author: Gao feng <gaofeng@cn.fujitsu.com>
Date:   Sun Jun 2 22:16:21 2013 +0000

    ipv6: assign rt6_info to inet6_ifaddr in init_loopback
   =20
    Commit 25fb6ca4ed9cad72f14f61629b68dc03c0d9713f
    "net IPv6 : Fix broken IPv6 routing table after loopback down-up"
    forgot to assign rt6_info to the inet6_ifaddr.
    When disable the net device, the rt6_info which allocated
    in init_loopback will not be destroied in __ipv6_ifa_notify.
   =20
    This will trigger the waring message below
    [23527.916091] unregister_netdevice: waiting for tap0 to become fre=
e.=20
Usage count =3D 1
   =20
    Reported-by: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
    Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

--=20
Arkadiusz Mi=C5=9Bkiewicz, arekm / maven.pl
