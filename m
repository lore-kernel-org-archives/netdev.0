From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [Question] TCP stack performance decrease since 3.14
Date: Wed, 15 Apr 2015 14:31:49 -0700
Message-ID: <552ED8C5.8000109@hp.com>
References: <552EBCA8.6090408@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: rapier <rapier@psc.edu>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3425.houston.hp.com ([15.201.208.53]:56066 "EHLO
	g4t3425.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752159AbbDOVbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 17:31:53 -0400
In-Reply-To: <552EBCA8.6090408@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/15/2015 12:31 PM, rapier wrote:
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
>      3.14    3.18    4.0     decrease %
> TCP_CC    183945    179222    175793    4.4%
> TCP_RR    594495    585484    561365    5.6%
> TCP_CRR    98677    96726    93026    5.7%
>
> Stream tests have remained the same from 3.14 through 4.0.

Have the service demands (usec of CPU consumed per KB) remained the same 
on the stream tests?  Even then, stateless offloads can help hide a 
multitude of path-length sins.

> All tests were conducted on the same platform from clean boot with stock
> kernels.
>
> So my questions are:
>
> Has anyone else seen this or is this a result of some weirdness on my
> system or artifact of my tests?

I've wondered if such a thing might be taking place but never had a 
chance to check.

One thing you might consider is "perf" profiling to see how the CPU 
consumption break-down has changed.

happy benchmarking,

rick jones

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
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
