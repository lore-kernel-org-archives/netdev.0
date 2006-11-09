From: David Miller <davem@davemloft.net>
Subject: Re: why do we mangle checksums for v6 ICMP?
Date: Thu, 09 Nov 2006 15:14:02 -0800 (PST)
Message-ID: <20061109.151402.15590179.davem@davemloft.net>
References: <20061108221332.GI29920@ftp.linux.org.uk>
	<45536622.90708@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ftp.linux.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:7854
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1424242AbWKIXNy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 18:13:54 -0500
To: brian.haley@hp.com
In-Reply-To: <45536622.90708@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Brian Haley <brian.haley@hp.com>
Date: Thu, 09 Nov 2006 12:32:18 -0500

> Al Viro wrote:
> > 	AFAICS, the rules are:
> > 
> > (1) checksum is 16-bit one's complement of the one's complement sum of
> > relevant 16bit words.
> > 
> > (2) for v4 UDP all-zeroes has special meaning - no checksum; if you get
> > it from (1), send all-ones instead.
> > 
> > (3) for v6 UDP we have the same remapping as in (2), but all-zeroes has
> > different meaning - not "ignore checksum" as in v4, but "reject the
> > packet".
> > 
> > (4) there is no (4).
> > 
> > 	IOW, nobody except UDP has any business doing that 0->0xffff
> > replacement.  However, we have
> >        if (icmp6h->icmp6_cksum == 0)
> >                icmp6h->icmp6_cksum = -1;
> 
> This doesn't look necessary, RFCs 4443/2463 don't mention it being 
> necessary, and BSD doesn't do it either.  I'll cook-up a patch to remove 
> that since I was doing some other mods in that codepath.

This is how things look to me too.

> > and similar in net/ipv6/raw.c
> 
> Maybe here it only needs to be done if (fl->proto == IPPROTO_UDP)?

Yes, I believe that is what is needed.
