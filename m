From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] ipv6: use stronger hash for reassembly queue hash
 table
Date: Fri, 08 Mar 2013 07:23:39 -0800
Message-ID: <1362756219.15793.240.camel@edumazet-glaptop>
References: <20130307214211.GP7941@order.stressinduktion.org>
	 <20130308055718.GA28531@order.stressinduktion.org>
	 <20130308130433.GB28531@order.stressinduktion.org>
	 <1362754386.15793.226.camel@edumazet-glaptop>
	 <20130308150831.GD28531@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:52632 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757848Ab3CHPXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 10:23:43 -0500
Received: by mail-pb0-f49.google.com with SMTP id xa12so1240109pbc.8
        for <netdev@vger.kernel.org>; Fri, 08 Mar 2013 07:23:42 -0800 (PST)
In-Reply-To: <20130308150831.GD28531@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-08 at 16:08 +0100, Hannes Frederic Sowa wrote:
> On Fri, Mar 08, 2013 at 06:53:06AM -0800, Eric Dumazet wrote:
> > No matter how you hash, a hacker can easily fill your defrag unit with
> > not complete datagrams, so what's the point ?
> 
> I want to harden reassembly logic against all fragments being put in
> the same hash bucket because of malicious traffic and thus creating
> long list traversals in the fragment queue hash table.

Note that the long traversal was a real issue with TCP (thats why I
introduced ipv6_addr_jhash()), as a single ehash slot could contains
thousand of sockets.

But with fragments, we should just limit the depth of any particular
slot, and drop above a particular threshold.

reassembly is a best effort mechanism, better make sure it doesnt use
all our cpu cycles.
