From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/5] net-timestamp: extend SCM_TIMESTAMPING
 ancillary data struct
Date: Thu, 24 Jul 2014 16:50:53 -0700 (PDT)
Message-ID: <20140724.165053.659177921712979472.davem@davemloft.net>
References: <CA+FuTSfMzbvGAM--LmB6i1R5cGZchmQqMNYkbcQGBn6jRAWG9A@mail.gmail.com>
	<20140724.141528.1823901044834131393.davem@davemloft.net>
	<CA+FuTSfm_WXtFYDeUNspN4=VNAAaQRxe2mvUYDD9Ho-yqJt8GA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	richardcochran@gmail.com, kreese@caviumnetworks.com,
	ddaney@caviumnetworks.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55848 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934753AbaGXXuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 19:50:55 -0400
In-Reply-To: <CA+FuTSfm_WXtFYDeUNspN4=VNAAaQRxe2mvUYDD9Ho-yqJt8GA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Thu, 24 Jul 2014 19:05:14 -0400

>>> That does not address legacy application dependencies on syststamp.
>>> Even with a PTP device, it is unclear whether anyone would invest time
>>> to convert their application to use it. The most relevant code I could
>>> find is cavium ptp-1588v2 on github. That configures SO_TIMESTAMPING
>>> to generate both raw + sys tstamps and preferentially reads the first.
>>> If this is the only known octeon timestamping user, then it would be
>>> just as safe to simply remove syststamp.
>>
>> The kernel would simply saw that adjusted HW timestamps are not
>> supported, the application has to accomodate the possibility of
>> needing to use one of the other timestamping flavors.
> 
> Cavium's PTP library already programs the device PTP clock,
> just not through the standard interface. It appears to map the
> memory addresses CVMX_MIO_.. directly. In any case, it
> will gracefully handle the loss of syststamp.
> 
> I doubt that there are other users of this Octeon interface, but
> if so, they can reasonably be expected to do the same and
> rely on the same legacy Octeon PTP clock interface +
> hwtstamp as alternative. Is that enough justification to remove
> syststamp without patching the driver to implement
> ptp_clock_info?
> 
> Cleanup would be two patches: one to revert the relevant
> code in the octeon driver (mostly, ptp_to_ktime), and a
> follow-up to remove the core code now that the last user
> is gone.

I'm not sure I understand, can users still get hardware timestamps
from Octeon cards after such a change?  Unless I misunderstand, the
only thing left available will be software timestamps, right?
