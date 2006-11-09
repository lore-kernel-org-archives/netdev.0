From: Brian Haley <brian.haley@hp.com>
Subject: Re: why do we mangle checksums for v6 ICMP?
Date: Thu, 09 Nov 2006 12:32:18 -0500
Message-ID: <45536622.90708@hp.com>
References: <20061108221332.GI29920@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:5355 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1424162AbWKIRcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Nov 2006 12:32:20 -0500
To: Al Viro <viro@ftp.linux.org.uk>
In-Reply-To: <20061108221332.GI29920@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Al,

Al Viro wrote:
> 	AFAICS, the rules are:
> 
> (1) checksum is 16-bit one's complement of the one's complement sum of
> relevant 16bit words.
> 
> (2) for v4 UDP all-zeroes has special meaning - no checksum; if you get
> it from (1), send all-ones instead.
> 
> (3) for v6 UDP we have the same remapping as in (2), but all-zeroes has
> different meaning - not "ignore checksum" as in v4, but "reject the
> packet".
> 
> (4) there is no (4).
> 
> 	IOW, nobody except UDP has any business doing that 0->0xffff
> replacement.  However, we have
>        if (icmp6h->icmp6_cksum == 0)
>                icmp6h->icmp6_cksum = -1;

This doesn't look necessary, RFCs 4443/2463 don't mention it being 
necessary, and BSD doesn't do it either.  I'll cook-up a patch to remove 
that since I was doing some other mods in that codepath.

> and similar in net/ipv6/raw.c

Maybe here it only needs to be done if (fl->proto == IPPROTO_UDP)?

-Brian
