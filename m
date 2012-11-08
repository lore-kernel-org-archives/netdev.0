From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/4 net-next] net: allow skb->head to be a page fragment
Date: Thu, 08 Nov 2012 05:30:49 -0800
Message-ID: <1352381449.19779.13.camel@edumazet-glaptop>
References: <1335522818.2775.227.camel@edumazet-glaptop>
	 <509A19E6.4040707@gmail.com>  <509A1D49.4080306@gmail.com>
	 <1352286264.3140.3575.camel@edumazet-glaptop>  <509B6368.9010206@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Li Yu <raise.sail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:45837 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755555Ab2KHNaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2012 08:30:52 -0500
Received: by mail-ie0-f174.google.com with SMTP id k13so4119202iea.19
        for <netdev@vger.kernel.org>; Thu, 08 Nov 2012 05:30:52 -0800 (PST)
In-Reply-To: <509B6368.9010206@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-08 at 15:46 +0800, Li Yu wrote:

> I think that all kmalloced() objects are continuous on both virtual
> and physical address space, so such page fragment converting should be
> safe until we use slab allocator to free them.
> 

Its not safe at all. Good luck with coping with SLAB, SLUB, SLOB, and
various debugging facilities on top of them.

> I ask this question since I am working on a patch to try to directly
> forward the data from rx queue of a socket to tx queue of another 
> socket. We noticed that the splice itself still has visible costs when 
> forwarding small messages, and hope such direct forwarding optimization
> can improve this, this idea comes from TCP friends.

If not using splice, you directly transfert one skb coming from one
side, to the other side, so you dont care skb->head being a frag or not.

If messages are small, there is probably no hope trying to coalesce them
(or else fixing the application would be much easier)
