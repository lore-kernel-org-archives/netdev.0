From: Imre Palik <imrep.amz@gmail.com>
Subject: Re: [RFC PATCH v2] bridge: make it possible for packets to traverse
 the bridge without hitting netfilter
Date: Fri, 06 Mar 2015 11:34:29 +0100
Message-ID: <54F982B5.90108@gmail.com>
References: <1424705163-13428-1-git-send-email-imrep.amz@gmail.com>	<20150223160619.GF24297@breakpoint.cc>	<54EEF32D.2010202@amazon.de> <20150226.113431.238255529591339000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, bridge@lists.linux-foundation.org,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, aliguori@amazon.com, nbd@openwrt.org
To: David Miller <davem@davemloft.net>, imrep@amazon.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:37978 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932082AbbCFKem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 05:34:42 -0500
In-Reply-To: <20150226.113431.238255529591339000.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/26/15 17:34, David Miller wrote:
> From: Imre Palik <imrep@amazon.de>
> Date: Thu, 26 Feb 2015 11:19:25 +0100
> 
>> If you are looking for peculiarities in my setup then here they are:
>> I am on 4k pages, and perf is not working :-(
>> (I am trying to fix those too, but that is far from being a low hanging fruit.)
>> So my guess would be that the packet pipeline doesn't fit in the cache/tlb
> 
> Pure specualtion until you can actually use perf to measure these
> things.
> 
> And I don't want to apply patches which were designed based upon
> pure speculation.
> 

I did performance measurements in the following way:

Removed those pieces of the packet pipeline that I don't necessarily need one-by-one.  Then measured their effect on small packet performance.

This was the only part that produced considerable effect.

The pure speculation was about why the effect is more than 15% increase in packet throughput, although the code path avoided contains way less code than 15% of the packet pipeline.  It seems, Felix Fietkau profiled similar changes, and found my guess well founded.

Now could anybody explain me what else is wrong with my patch?  I run out of ideas what to improve.

Thanks

Imre
