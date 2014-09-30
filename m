From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: How exactly does CHECKSUM_COMPLETE works?
Date: Tue, 30 Sep 2014 20:19:05 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63B4159B@avmb3.qlogic.org>
References: <B5657A6538887040AD3A81F1008BEC63B41317@avmb3.qlogic.org>
	 <CA+mtBx_17aJuK=xjnDukGJOfw-twHg=rF5rDacg6pga6ZTTRcw@mail.gmail.com>
	 <B5657A6538887040AD3A81F1008BEC63B4152D@avmb3.qlogic.org>
	 <1412104977.30721.94.camel@edumazet-glaptop2.roam.corp.google.com>,<1412105832.30721.95.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Tom Herbert (Partner - google)" <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:13219 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752482AbaI3UTZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2014 16:19:25 -0400
In-Reply-To: <1412105832.30721.95.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Can you pinpoint me to what exactly in the code corrects NAPI_GRO_CB(skb)->csum
> > by negating the ipv4 part in the ones' complete checksum?
> >
> > E.g., for ipv6 [in ipv6_gro_receive()] I can see that skb_gro_postpull_rcsum() is
> > called after pulling the ipv6 header [and before proceeding to the next protocol],
> > but I can't seem to find anything similar to this for ipv4 [in inet_gro_receive()].
> >
>
>
> IPv4 header is supposed to have a 0 checksum ;)
>

Oops. Sorry, you're right.

But this is a bit strange.

I mean, if I go back to the IP-GRE case [with GRE checksum], the IP
csum negates the rest of the IP header and the GRE csum negates
everything else [GRE header, inner headers and payload].
So the mechanism might work as-is, but all the driver has to
do in order to claim that an IP-gre packet with checksum option is
CHECKSUM_COMPLETE is to write 0xffffffff on the skb's csum field.
 