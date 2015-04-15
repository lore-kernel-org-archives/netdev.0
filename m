From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Question] TCP stack performance decrease since 3.14
Date: Wed, 15 Apr 2015 14:01:52 -0700
Message-ID: <1429131712.7346.144.camel@edumazet-glaptop2.roam.corp.google.com>
References: <552EBCA8.6090408@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rapier <rapier@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:36375 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536AbbDOVBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 17:01:54 -0400
Received: by iebrs15 with SMTP id rs15so37411585ieb.3
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2015 14:01:53 -0700 (PDT)
In-Reply-To: <552EBCA8.6090408@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-15 at 15:31 -0400, rapier wrote:
> All,
> 
> First, my apologies if this came up previously but I couldn't find 
> anything using a keyword search of the mailing list archive.
> 
> As part of the on going work with web10g I need to come up with baseline 
> TCP stack performance for various kernel revision. Using netperf and 
> super_netperf* I've found that performance for TCP_CC, TCP_RR, and 
> TCP_CRR has decreased since 3.14.
> 
> 	3.14	3.18	4.0 	decrease %
> TCP_CC	183945	179222	175793	4.4%
> TCP_RR	594495	585484	561365	5.6%
> TCP_CRR	98677	96726	93026	5.7%
> 
> Stream tests have remained the same from 3.14 through 4.0.
> 
> All tests were conducted on the same platform from clean boot with stock 
> kernels.
> 
> So my questions are:
> 
> Has anyone else seen this or is this a result of some weirdness on my 
> system or artifact of my tests?
> 
> If others have seen this or is just simply to be expected (from new 
> features and the like) is it due to the TCP stack itself or other 
> changes in the kernel?
> 
> If so, is there anyway to mitigate the effect of this via stack tuning, 
> kernel configuration, etc?
> 
> Thanks!
> 
> Chris
> 
> 
> * The above results are the average of 10 iterations of super_netperf 
> for each test. I can run more iterations to verify the results but it 
> seem consistent. The number of parallel processes for each test was 
> tuned to produce the maximum test result. In other words, enough to push 
> things but not enough to cause performance hits due to being 
> cpu/memory/etc bound. If anyone wants the full results and test scripts 
> just let me know.
> --

Make sure you do not hit a c-state issue.

I've seen improvements in the stack translate to longer wait times, and
cpu takes longer to exit deep c-state.
