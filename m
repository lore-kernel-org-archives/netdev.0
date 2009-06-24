From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: e100 skb allocation
Date: Wed, 24 Jun 2009 06:47:50 -0400
Message-ID: <20090624104750.GA18486@hmsreliant.think-freely.org>
References: <b9e8fcbd0906240149g2f2e18f2vcd7dce234c949564@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Nicholas Van Orton <turanammo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40275 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751708AbZFXKr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 06:47:56 -0400
Content-Disposition: inline
In-Reply-To: <b9e8fcbd0906240149g2f2e18f2vcd7dce234c949564@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 24, 2009 at 02:19:48PM +0530, Nicholas Van Orton wrote:
> Hello,
> 
> 	For the Intel 8256 Ethernet Controller (e100.c), I notice that at the
> time of skb allocation using netdev_alloc_skb() and just before
> calling skb_reserve(), rx->skb->head and rx->skb->tail do not point to
> the same location. In fact they are already 16bytes apart. After
> calling  skb_reserve(), which would add a 2 byte padding, head and
> tail would be 18 bytes apart. Is this behaviour correct? Shouldn't the
> ethernet header be 14+2 bytes after padding? Why aren't head and tail
> at the same location at the beginning?
> 
Yes, its fine (although IIRC it should be 32, rather than 16 bytes).
netdev_alloc_skb, in its implementation, allocates an skb that is NET_SKB_PAD
bytes larger than the caller requested, then it calls skb_reserve internally to
add NET_SKB_PAD bytes of data to the skb's buffer.

Neil

> 
> Thanks and regards,
> Nicholas
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
