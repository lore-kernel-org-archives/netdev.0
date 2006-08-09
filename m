From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] limit rt cache size
Date: Wed, 9 Aug 2006 02:24:04 +0200
Message-ID: <200608090224.04158.ak@suse.de>
References: <200608080711.06788.ak@suse.de> <200608090123.01123.ak@suse.de> <20060808.171152.58440635.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: akepner@sgi.com, kuznet@ms2.inr.ac.ru, dev@sw.ru,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:32926 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1030370AbWHIAYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 20:24:34 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060808.171152.58440635.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 09 August 2006 02:11, David Miller wrote:
> From: Andi Kleen <ak@suse.de>
> Date: Wed, 9 Aug 2006 01:23:01 +0200
> 
> > The problem is to find out what a good boundary is.
> 
> The more I think about this the more I lean towards
> two conclusions:
> 
> 1) dynamic table growth is the only reasonable way to
>    handle this and not waste memory in all cases

Yes, but even with dynamic growth you still need some upper boundary 
(otherwise a DOS could eat all your memory). And it would need
to be figured out what it is.

BTW does dynamic shrink after a load spike make sense too?

> 2) for cases where we haven't implemented dynamic
>    table growth, specifying a proper limit argument
>    to the hash table allocation is a sufficient
>    solution for the time being

Agreed, just we don't know what the proper limits are. 

I guess it would need someone running quite a lot of benchmarks.
Anyone volunteering? @)

Or do some cheesy default and document the options to change
it clearly and wait for feedback from users on what works for
them?

-Andi
