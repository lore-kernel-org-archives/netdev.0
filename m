From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/6] net: pad skb data and shinfo as a whole rather than
 individually
Date: Fri, 06 Jan 2012 13:33:46 +0100
Message-ID: <1325853226.2999.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1325783399.25206.413.camel@zakaz.uk.xensource.com>
	 <1325783624-14601-2-git-send-email-ian.campbell@citrix.com>
	 <1325785607.4759.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1325791164.29084.8.camel@dagon.hellion.org.uk>
	 <1325794968.2748.6.camel@edumazet-laptop>
	 <1325848815.25206.471.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57818 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751471Ab2AFMdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 07:33:50 -0500
Received: by wgbdr13 with SMTP id dr13so1692614wgb.1
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2012 04:33:49 -0800 (PST)
In-Reply-To: <1325848815.25206.471.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 06 janvier 2012 =C3=A0 11:20 +0000, Ian Campbell a =C3=A9cr=
it :

> It doesn't fit in a single cache line today.

It really does, thanks to your (net: pack skb_shared_info more
efficiently) previous patch.

I dont understand your numbers, very hard to read.

Current net-next :

offsetof(struct skb_shared_info, nr_frags)=3D0x0
offsetof(struct skb_shared_info, frags[1])=3D0x40   (0x30 on 32bit arch=
es)

So _all_ fields, including one frag, are included in a single cache lin=
e
on most machines (64-bytes cache line), IF struct skb_shared_info is
aligned.

Your patch obviously breaks this on 64bit arches, unless you make sure
sizeof(struct skb_shared_info) is a multiple of cache line.

[BTW, it is incidentaly the case after your 1/6 patch]

fields reordering is not going to change anything on this.

Or maybe I misread your patch ?

At least you claimed in Changelog :=20

<quote>
 Reducing this overhead means that sometimes the tail end of
 the data can end up in the same cache line as the beginning of the shi=
nfo but
 in many cases the allocation slop means that there is no overlap.
</quote>
