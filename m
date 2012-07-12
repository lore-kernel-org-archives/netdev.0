From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 1/2] tcp: Fix out of bounds access to tcpm_vals
Date: Wed, 11 Jul 2012 18:46:51 -0700
Message-ID: <4FFE2C8B.7080802@gmail.com>
References: <20120712001804.26542.2889.stgit@gitlad.jf.intel.com> <20120711.173249.1303803416502735349.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:52536 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756196Ab2GLBq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 21:46:57 -0400
Received: by pbbrp8 with SMTP id rp8so2892841pbb.19
        for <netdev@vger.kernel.org>; Wed, 11 Jul 2012 18:46:56 -0700 (PDT)
In-Reply-To: <20120711.173249.1303803416502735349.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/11/2012 5:32 PM, David Miller wrote:
> From: Alexander Duyck<alexander.h.duyck@intel.com>
> Date: Wed, 11 Jul 2012 17:18:04 -0700
>
>> The recent patch "tcp: Maintain dynamic metrics in local cache." introduced
>> an out of bounds access due to what appears to be a typo.   I believe this
>> change should resolve the issue by replacing the access to RTAX_CWND with
>> TCP_METRIC_CWND.
>>
>> Signed-off-by: Alexander Duyck<alexander.h.duyck@intel.com>
> Applied, thanks a lot.
>
> How did you spot this, did you get a compiler warning?
>
> I ask because while working on this, I at one point put the
> tcp timestamp members after the metrics array in the
> tcp_metrics_bucket struct.  And I got a warning from gcc about
> an array bounds violation that I could not figure out.
>
> I am pretty certain this bug here is what it was warning about.  And
> the problem is that if you put the array at the end gcc doesn't warn
> in order to handle things similar to what people use zero length
> arrays for.
It came up as a compiler warning.  I suspect it may have something to do 
with the optimizations I had turned on since it complained that the 
issue was in tcp_update_metrics but then reported it on the one line in 
tcp_metric_set.

Thanks,

Alex
