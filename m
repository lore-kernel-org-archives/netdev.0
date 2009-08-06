From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: 2.6.31-rc5-git2 crash [net/core/flow.c:flow_cache_new_hashrnd]
Date: Fri, 07 Aug 2009 08:23:05 +1000
Message-ID: <1249597385.24311.10.camel@pasglop>
References: <4A78292A.5000607@in.ibm.com>  <4A783B1F.7000602@in.ibm.com>
	 <1249395350.8016.5.camel@concordia>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Sachin Sant <sachinp@in.ibm.com>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, linuxppc-dev@ozlabs.org
To: michael@ellerman.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:57977 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754167AbZHFWX1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2009 18:23:27 -0400
In-Reply-To: <1249395350.8016.5.camel@concordia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-08-05 at 00:15 +1000, Michael Ellerman wrote:

> > c000000000600000  00001010      .long 0x1010
> > 0:mon>
> > c000000000600004  00000008      .long 0x8
> > c000000000600008  00001013      .long 0x1013
> > c00000000060000c  0000000f      .long 0xf
> > c000000000600010  7961626f      rldimi. r1,r11,44,41
> > c000000000600014  6f740000      xoris   r20,r27,0
> > c000000000600018  00101600      .long 0x101600
> > c00000000060001c  00000c00      .long 0xc00
> > c000000000600020  00000400      .long 0x400
> > c000000000600024  00101100      .long 0x101100
> > c000000000600028  000008e9      .long 0x8e9

BTW. Corruption looks like bi_recs... ie, broken yaboot. This was fixed
recently, yaboot would eventually crap over the kernel for certain sizes
of the kernel image.

0x1010 = BI_FIRST
0x1013 = BI_BOOTLOADER_ID followed by 0x7961626f6f74 which is
"yaboot" :-)
0x1016 = BI_MACHTYPE

etc...

Cheers,
Ben.

