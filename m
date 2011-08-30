From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 802.1Q VLAN random tag injected when vlan configured on
 forcedeth interface
Date: Tue, 30 Aug 2011 16:42:42 +0200
Message-ID: <1314715362.2935.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20110830125111.GA28341@ruff.mobi>
	 <1314710628.2935.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110830134624.GB28341@ruff.mobi>  <20110830142310.GC28341@ruff.mobi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Ruslan N. Marchenko" <me@ruff.mobi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:65417 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754153Ab1H3Oml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 10:42:41 -0400
Received: by wyg24 with SMTP id 24so4966607wyg.19
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 07:42:40 -0700 (PDT)
In-Reply-To: <20110830142310.GC28341@ruff.mobi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 ao=C3=BBt 2011 =C3=A0 16:23 +0200, Ruslan N. Marchenko a =C3=
=A9crit :
> On Tue, Aug 30, 2011 at 03:46:24PM +0200, Ruslan N. Marchenko wrote:
> > On Tue, Aug 30, 2011 at 03:23:48PM +0200, Eric Dumazet wrote:
> > >=20
> > > What kernel version are you using ?
> > >=20
> > Oh, sorry for missing it, it runs on=20
> > Linux ruff.mobi 2.6.38-11-generic #48-Ubuntu SMP Fri Jul 29 19:05:1=
4 UTC 2011 i686 i686 i386 GNU/Linux
> >=20
> > Just fyi - the openwrt box to which it is connected is=20
> > Linux OpenWrt 2.6.39.2 #2 Fri Aug 12 09:36:23 EEST 2011 mips GNU/Li=
nux
> > although packet drop happens even if there're no vlans configured o=
n remote side.
> >=20
> Here is double-tag sample:
> 16:20:31.151268 e0:46:9a:4e:88:1d > 00:26:18:40:21:62, ethertype 802.=
1Q (0x8100), length 106: vlan 2112, p 7, ethertype 802.1Q, vlan 6, p 0,=
 ethertype IPv4, [|ip]
>         0x0000:  0026 1840 2162 e046 9a4e 881d 8100 e840
>         0x0010:  8100 0006 0800 4500 0054 abec 0000
>=20
>=20

Latest kernel should be fine. Some patches need to be backported by
Ubuntu team, if you can test them.

commit 9331db4f00cfee8a79d2147ac83723ef436b9759
Author: Jiri Pirko <jpirko@redhat.com>
Date:   Wed Aug 17 23:50:37 2011 -0700

    forcedeth: call vlan_mode only if hw supports vlans
   =20
    If hw does not support vlans, dont call nv_vlan_mode because it has=
 no point.
    I believe that this should fix issues on older non-vlan supportive
    chips (like Ingo has).
   =20
    Reported-ty: Ingo Molnar <mingo@elte.hu>
    Signed-off-by: Jiri Pirko <jpirko@redhat.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit 0891b0e08937aaec2c4734acb94c5ff8042313bb
Author: Jiri Pirko <jpirko@redhat.com>
Date:   Tue Jul 26 10:19:28 2011 +0000

    forcedeth: fix vlans
   =20
    For some reason, when rxaccel is disabled, NV_RX3_VLAN_TAG_PRESENT =
is
    still set and some pseudorandom vids appear. So check for
    NETIF_F_HW_VLAN_RX as well. Also set correctly hw_features and set =
vlan
    mode on probe.
   =20
    Signed-off-by: Jiri Pirko <jpirko@redhat.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit 3326c784c9f492e988617d93f647ae0cfd4c8d09
Author: Jiri Pirko <jpirko@redhat.com>
Date:   Wed Jul 20 04:54:38 2011 +0000

    forcedeth: do vlan cleanup
   =20
    - unify vlan and nonvlan rx path
    - kill np->vlangrp and nv_vlan_rx_register
    - allow to turn on/off rx vlan accel via ethtool (set_features)
   =20
    Signed-off-by: Jiri Pirko <jpirko@redhat.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
