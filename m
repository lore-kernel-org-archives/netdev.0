From: Tom Herbert <therbert@google.com>
Subject: Re: Performance regression on kernels 3.10 and newer
Date: Fri, 15 Aug 2014 15:16:50 -0700
Message-ID: <CA+mtBx-LZgnpWAf3Jn0htoga32UaMc-NAqURmXezmZmwg2oGRQ@mail.gmail.com>
References: <53ECFDAB.5010701@intel.com>
	<1408041962.6804.31.camel@edumazet-glaptop2.roam.corp.google.com>
	<53ED4354.9090904@intel.com>
	<20140814.162024.2218312002979492106.davem@davemloft.net>
	<53EE4023.6080902@intel.com>
	<CA+mtBx_aEe6SvWV6tfqzGWcPvVM+FE6kbnyFE5FbECU9HN7EXg@mail.gmail.com>
	<53EE5B25.3040206@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:54954 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171AbaHOWQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2014 18:16:51 -0400
Received: by mail-ig0-f179.google.com with SMTP id h18so3080044igc.6
        for <netdev@vger.kernel.org>; Fri, 15 Aug 2014 15:16:50 -0700 (PDT)
In-Reply-To: <53EE5B25.3040206@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 15, 2014 at 12:10 PM, Alexander Duyck
<alexander.h.duyck@intel.com> wrote:
> On 08/15/2014 11:49 AM, Tom Herbert wrote:
>> Alex, I tried to repro your problem running your script (on bnx2x).
>> Didn't see see the issue and in fact ip_dest_check did not appear in
>> top perf functions on perf. I assume this is more related to the
>> steering configuration rather than the device (although flow director
>> might be a fundamental difference).
>>
>
> So the original script I put out had a typo.  It was supposed to run all
> 60 at the same time, not one at a time.  So make sure you add an
> ampersand to the end of the netperf command line if you run the test so
> that it is 60 at once, not 60 in series.
>
> Also one other thing I had to do was disable tcp_autocork.  Without that
> the test is a large packets test instead of a small packet test.
>
Okay, by running netperf in background, disabling autoconf, and
turning off RPS/RFS I'm able to get ipv4_dst_check to come up in perf;
but t's not nearly as bad as what you've reported though, only about
1.5%. When I applied path to move rt_genid to different cacheline
ipv4_dst_check goes away (ipv4: move rt_genid to different cache
line). Can you try this patch in your setup?

Thanks,
Tom

> Thanks,
>
> Alex
>
