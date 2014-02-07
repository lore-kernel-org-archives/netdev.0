From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: Re: Question about skb_flow_dissect() and 802.1q/802.1ad
Date: Fri, 07 Feb 2014 21:36:42 +0200
Message-ID: <12212434.KMML02VyKq@tuxracer>
References: <1396838.WXqPOv9eKS@tuxracer> <1391800285.10160.62.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp10.mail.ru ([94.100.176.152]:35493 "EHLO smtp10.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751361AbaBGThs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 14:37:48 -0500
Received: from [2a01:6d80:103:13::c3ea:4404] (port=50471 helo=tuxracer.localnet)
	by smtp10.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1WBrFC-0004jc-Kw
	for netdev@vger.kernel.org; Fri, 07 Feb 2014 23:37:47 +0400
In-Reply-To: <1391800285.10160.62.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D0=92 =D0=BF=D0=B8=D1=81=D1=8C=D0=BC=D0=B5 =D0=BE=D1=82 7 =D1=84=D0=B5=
=D0=B2=D1=80=D0=B0=D0=BB=D1=8F 2014 11:11:25 =D0=BF=D0=BE=D0=BB=D1=8C=D0=
=B7=D0=BE=D0=B2=D0=B0=D1=82=D0=B5=D0=BB=D1=8C Eric Dumazet =D0=BD=D0=B0=
=D0=BF=D0=B8=D1=81=D0=B0=D0=BB:
> On Fri, 2014-02-07 at 20:44 +0200, Sergey Popovich wrote:

> Well, all you need is to properly set network header before calling
> skb_flow_dissect()

It seems, network header pointing properly to network protocol header
(IPv4, IPv6 in my case).

But skb->protocol points to htons(ETH_P_8021Q) and skb_flow_dissect()
looks inside network header, not layer 2 where vlan header resides.

Thats main problem with this. layer2+3 and layer3+4 - original bonding
xmit hash policies also affected by skb->protocol =3D=3D htons(ETH_P_80=
21Q)
for stacked vlans.

Thanks for quick answer.

>=20
> All is about headers. hdr and _hdr are vague.

Well, 802.1q !=3D 802.1ad, VLAN !=3D VMAN (QinQ, etc.), I consider this=
, butthis=20
is quick patch, no problem with any names. Sorry for this.

Patch only for give a hint on question I ask. Thanks.


--=20
SP5474-RIPE
Sergey Popovich
