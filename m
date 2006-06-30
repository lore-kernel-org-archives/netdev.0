From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: jumbo frames and memory fragmentation
Date: Fri, 30 Jun 2006 22:48:21 +0400
Message-ID: <20060630184820.GA9558@2ka.mipt.ru>
References: <E1FwIcw-00068x-00@gondolin.me.apana.org.au> <44A56520.5010703@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:16325 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932995AbWF3Ssq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 14:48:46 -0400
To: Chris Friesen <cfriesen@nortel.com>
Content-Disposition: inline
In-Reply-To: <44A56520.5010703@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 30, 2006 at 11:53:36AM -0600, Chris Friesen (cfriesen@nortel.com) wrote:
> >Either upgrade your kernel or backport the page-splitting code in the
> >current tree.  That's really the only sane solution for jumbo packets.
> 
> Looking at the page-splitting code, it says "82571 and greater support 
> packet-split...".  We're running the 82546GB device.  Looks like it 
> won't help me.

It definitely will.
Packet split in hardware means separating data and headers into
different pages in different reads, while software page split means that 
skb has a list of fragments where part of the packet will be DMAed, so
jumbo frame will be converted into several pages.

-- 
	Evgeniy Polyakov
