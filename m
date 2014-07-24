From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v3 1/5] net-timestamp: extend SCM_TIMESTAMPING
 ancillary data struct
Date: Thu, 24 Jul 2014 19:05:14 -0400
Message-ID: <CA+FuTSfm_WXtFYDeUNspN4=VNAAaQRxe2mvUYDD9Ho-yqJt8GA@mail.gmail.com>
References: <CA+FuTScobCk5EFgsht=S0mfF4fVh1fKqAAV8+mZLk9h1O_uwnA@mail.gmail.com>
 <20140723.211256.2143360320648788946.davem@davemloft.net> <CA+FuTSfMzbvGAM--LmB6i1R5cGZchmQqMNYkbcQGBn6jRAWG9A@mail.gmail.com>
 <20140724.141528.1823901044834131393.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Chad Reese <kreese@caviumnetworks.com>,
	ddaney@caviumnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f171.google.com ([209.85.220.171]:32893 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164AbaGXXFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 19:05:46 -0400
Received: by mail-vc0-f171.google.com with SMTP id hq11so6221852vcb.2
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2014 16:05:45 -0700 (PDT)
In-Reply-To: <20140724.141528.1823901044834131393.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> That does not address legacy application dependencies on syststamp.
>> Even with a PTP device, it is unclear whether anyone would invest time
>> to convert their application to use it. The most relevant code I could
>> find is cavium ptp-1588v2 on github. That configures SO_TIMESTAMPING
>> to generate both raw + sys tstamps and preferentially reads the first.
>> If this is the only known octeon timestamping user, then it would be
>> just as safe to simply remove syststamp.
>
> The kernel would simply saw that adjusted HW timestamps are not
> supported, the application has to accomodate the possibility of
> needing to use one of the other timestamping flavors.

Cavium's PTP library already programs the device PTP clock,
just not through the standard interface. It appears to map the
memory addresses CVMX_MIO_.. directly. In any case, it
will gracefully handle the loss of syststamp.

I doubt that there are other users of this Octeon interface, but
if so, they can reasonably be expected to do the same and
rely on the same legacy Octeon PTP clock interface +
hwtstamp as alternative. Is that enough justification to remove
syststamp without patching the driver to implement
ptp_clock_info?

Cleanup would be two patches: one to revert the relevant
code in the octeon driver (mostly, ptp_to_ktime), and a
follow-up to remove the core code now that the last user
is gone.
