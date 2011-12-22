From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ICMP packets - ll_temac with Microblaze
Date: Thu, 22 Dec 2011 11:46:51 +0100
Message-ID: <1324550811.2153.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EF1B0D9.2010007@monstr.eu>
	 <4EF30744.6000509@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: monstr@monstr.eu, David Miller <davem@davemloft.net>,
	John Williams <john.williams@petalogix.com>,
	netdev@vger.kernel.org
To: Michael Wang <wangyun@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:41186 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752698Ab1LVKq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 05:46:56 -0500
Received: by lahd3 with SMTP id d3so865092lah.19
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2011 02:46:54 -0800 (PST)
In-Reply-To: <4EF30744.6000509@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 22 d=C3=A9cembre 2011 =C3=A0 18:32 +0800, Michael Wang a =C3=A9=
crit :
> On 12/21/2011 06:11 PM, Michal Simek wrote:
>=20
> > Hi Eric and David,
> >=20
> > I have found one problem with ll_temac driver and
> > this commit: net: more accurate skb truesize
> > sha1: 87fb4b7b533073eeeaed0b6bf7c2328995f6c075
> >=20
> > The problem is only with icmp packets from the target. It is sent a=
nd
> > driver receive it
> > but it is not proceed to the application.
> >=20
>=20
> Hi, Michal
>=20
> What's the type of icmp you are using? such as "EchoReps", we can fin=
d
> the actually handler routine by this type.
>=20
> And you said the packet already received by driver, can you tell me t=
he
> way you used to confirm this?
>=20
> And have you checked when was the icmp packet being dropped, is it in
> icmp_rcv or before or later?

Packet was dropped right before being queued in RAW socket
receive_queue, because of low sk_rcvbuf setting (against skb->truesize)
