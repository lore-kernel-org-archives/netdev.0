From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel panic when using bridge
Date: Tue, 12 Apr 2011 07:51:30 +0200
Message-ID: <1302587490.3603.22.camel@edumazet-laptop>
References: <4D9E62D9.5010400@scotdoyle.com>
	 <20110408121700.0aad53fe@nehalam>	<4D9FE5BE.6060600@scotdoyle.com>
	 <20110409161908.a2aca120.shimoda.hiroaki@gmail.com>
	 <4DA39330.2030102@scotdoyle.com> <20110411183105.46e86684@nehalam>
	 <4DA3CB4B.9090506@scotdoyle.com> <1302581384.3603.14.camel@edumazet-laptop>
	 <1302582172.3603.18.camel@edumazet-laptop> <4DA3E074.5090603@scotdoyle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	netdev@vger.kernel.org
To: Scot Doyle <lkml@scotdoyle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58954 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753665Ab1DLFvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 01:51:35 -0400
Received: by wya21 with SMTP id 21so5388640wya.19
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2011 22:51:34 -0700 (PDT)
In-Reply-To: <4DA3E074.5090603@scotdoyle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 12 avril 2011 =C3=A0 00:17 -0500, Scot Doyle a =C3=A9crit :
> On 04/11/2011 11:22 PM, Eric Dumazet wrote:
> > Also, I would first check if skb->dst already set to not leak a dst
> >
> > if (!skb->dst) {

Oh well, sorry (not enough time these days to even test patches)

	if (!skb_dst(skb)) {

> > 	rt =3D bridge_parent_rtable(dev);
> > 	if (!rt) {
> > 		kfree_skb(skb);
> > 		return 0;
> > 	}
> > 	skb_dst_set_noref(skb,&rt->dst);
> > }
>=20
> Thank you for the idea. Here is the compiler output referring to the=20
> first line above.
>=20
> net/bridge/br_netfilter.c: In function 'br_parse_ip_options':
> net/bridge/br_netfilter.c:260:10: error: 'struct sk_buff' has no memb=
er=20
> named 'dst'
>=20


