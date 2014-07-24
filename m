From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/5] net-timestamp: extend SCM_TIMESTAMPING
 ancillary data struct
Date: Thu, 24 Jul 2014 14:15:28 -0700 (PDT)
Message-ID: <20140724.141528.1823901044834131393.davem@davemloft.net>
References: <CA+FuTScobCk5EFgsht=S0mfF4fVh1fKqAAV8+mZLk9h1O_uwnA@mail.gmail.com>
	<20140723.211256.2143360320648788946.davem@davemloft.net>
	<CA+FuTSfMzbvGAM--LmB6i1R5cGZchmQqMNYkbcQGBn6jRAWG9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	richardcochran@gmail.com, david.daney@cavium.net,
	kreese@caviumnetworks.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54629 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751533AbaGXVPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 17:15:32 -0400
In-Reply-To: <CA+FuTSfMzbvGAM--LmB6i1R5cGZchmQqMNYkbcQGBn6jRAWG9A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Thu, 24 Jul 2014 16:48:04 -0400

>> I can't believe we're going to hold onto syststamp just for one
>> odd-ball MIPS ethernet driver.  Really?
>>
>> I think putting in whatever work is necessary to convert Octeon over
>> to exposing a proper PTP device is much better than having this
>> syststamp thing rot in our data structures forever.
> 
> Implementing ptp_clock_info gettime/settime/adjtime/adjfreq using
> CVMX_MIO_PTP_CLOCK_[CFG|HI|COMP] might be feasible.
> 
> That does not address legacy application dependencies on syststamp.
> Even with a PTP device, it is unclear whether anyone would invest time
> to convert their application to use it. The most relevant code I could
> find is cavium ptp-1588v2 on github. That configures SO_TIMESTAMPING
> to generate both raw + sys tstamps and preferentially reads the first.
> If this is the only known octeon timestamping user, then it would be
> just as safe to simply remove syststamp.

The kernel would simply saw that adjusted HW timestamps are not
supported, the application has to accomodate the possibility of
needing to use one of the other timestamping flavors.
