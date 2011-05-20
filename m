From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fwd: pktgen with vlan packets
Date: Fri, 20 May 2011 18:43:17 +0200
Message-ID: <1305909797.3173.35.camel@edumazet-laptop>
References: <BANLkTinybQHjqXe-0SOU4wHTJg0M=QX=ow@mail.gmail.com>
	 <BANLkTinBGkApfasGywg888wDXZBYPOpQDQ@mail.gmail.com>
	 <1305904837.3173.20.camel@edumazet-laptop>
	 <BANLkTinTEM4BLzoOQiDFyY13Yj=ZqhXu5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Lynch, Jonathan" <jonathan.lynch@thenowfactory.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34442 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935006Ab1ETQnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2011 12:43:21 -0400
Received: by wwa36 with SMTP id 36so4214082wwa.1
        for <netdev@vger.kernel.org>; Fri, 20 May 2011 09:43:19 -0700 (PDT)
In-Reply-To: <BANLkTinTEM4BLzoOQiDFyY13Yj=ZqhXu5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 20 mai 2011 =C3=A0 17:30 +0100, Lynch, Jonathan a =C3=A9cri=
t :
> Hi Eric,
>=20
> Thanks for your quick response.
>=20
> I tried your suggestion for number 1 and I got the following oops -
> see log2 attached
>  - i ran  tc qdisc before testing to confirm there is no qdisc for et=
h4.
>=20
> Then I tried suggestion 2, it works and sends packets over multiple
> VLAN interfaces using multiple threads.
>  (When I combine suggestion 1 and 2 it crashes when I try sending to
> more than 1 VLAN interface)

Well, yes, I guess there is nothing we can do about the crash issue,
since pktgen is doing some hacks and we are not going to add additional
tests in xmit fast path.

pktgen should directly work with the lowerdev.
[ going through vlan stack is an addtional overhead anyway ]

To send packets to several vlans, you would need to add a pktgen patch.
[to accept a range of vlan_id, or a list of vlan_id]

Or just use "flag VID_RND" ? (It'll chose a random id in [0..4095])


