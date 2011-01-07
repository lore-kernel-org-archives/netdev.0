From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] sched: CHOKe packet scheduler (v0.2)
Date: Fri, 07 Jan 2011 09:37:23 +0100
Message-ID: <1294389443.2704.101.camel@edumazet-laptop>
References: <20110104162930.6fa672e3@nehalam>
	 <1294208375.3420.46.camel@edumazet-laptop>
	 <20110105091718.02f8a00f@nehalam>
	 <1294248332.10633.25.camel@edumazet-laptop>
	 <20110105112104.64ad3c86@nehalam>
	 <1294286850.2723.65.camel@edumazet-laptop>
	 <20110106205549.0de56de1@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56149 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753832Ab1AGIh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jan 2011 03:37:28 -0500
Received: by wwa36 with SMTP id 36so18265697wwa.1
        for <netdev@vger.kernel.org>; Fri, 07 Jan 2011 00:37:27 -0800 (PST)
In-Reply-To: <20110106205549.0de56de1@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 06 janvier 2011 =C3=A0 20:55 -0800, Stephen Hemminger a =C3=A9=
crit :
> The problem is that large tables of pointers in kernel require either
> contiguous allocation or some indirect table algorithm.
>=20

By large table, how many slots do you envision ?

1024 ?
8192 ?
65536 ?

Even insane value like 65536 is OK most of the time.
if kmalloc(GFP_KERNEL) fails, try vmalloc().

We are in process context and are allowed to sleep when qdisc is
created.

Anyway, accessing a random skb in a list of 65536 skbs is just crazy.


