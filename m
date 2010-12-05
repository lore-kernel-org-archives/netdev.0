From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: Question about __alloc_skb() speedup
Date: Sun, 5 Dec 2010 18:56:24 +0800
Message-ID: <20101205105616.GA4770@Desktop-Junchang>
References: <20101203101450.GA9573@Desktop-Junchang>
 <1291373429.2897.96.camel@edumazet-laptop>
 <20101204141826.GA5830@Desktop-Junchang>
 <1291474058.2806.96.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:58772 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752734Ab0LEK4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Dec 2010 05:56:40 -0500
Received: by pzk6 with SMTP id 6so1683516pzk.19
        for <netdev@vger.kernel.org>; Sun, 05 Dec 2010 02:56:39 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1291474058.2806.96.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 04, 2010 at 03:47:38PM +0100, Eric Dumazet wrote:
>
>Yes I believe so, pktgen being very specific, but I have few questions :
>
>Is it with SLUB or SLAB ?
I had read your discussion about "net: allocate skbs on local node" in
the list, so SLUB was used.

BTW, what I observed is that network subsystem scales well on NUMA
systems equipped with a single processor(up to six cores), but the
performance didn't scale very well if there are two processors. 

I have noticed there are a number of discussions in the list. Are 
there any suggestions? I'm very pleasant to do test.

>
>How many buffers in TX ring on you nic (ethtool -g eth0) ?
>
Pre-set maximums:
RX:             4096
RX Mini:        0
RX Jumbo:       0
TX:             4096
Current hardware settings:
RX:             512
RX Mini:        0
RX Jumbo:       0
TX:             512

>What is the datalen value here ? (you prefetch, then advance skb->data)
>
16. But the following skb_push will drawback 14 bytes.

>32 or 64bit kernel ?
>
This is a CentOS 5.5 - 64bit distribution with the latest net-next.

>How many pps do you get before and after patch ?
>
A Intel SR1625 server with two E5530 quad-core processors and a single
ixgbe-based NIC.
Without prefetch: 8.63 Mpps
With prefetch: 9.03 Mpps
Improvement: 4.6%


Thanks.
--Junchang
