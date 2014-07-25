From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v3 1/5] net-timestamp: extend SCM_TIMESTAMPING
 ancillary data struct
Date: Thu, 24 Jul 2014 20:10:55 -0400
Message-ID: <CA+FuTSdVFHVEp0-orPe7KNEbF2-Lsu+myBNdi9bW7kVV3FM6cA@mail.gmail.com>
References: <CA+FuTSfMzbvGAM--LmB6i1R5cGZchmQqMNYkbcQGBn6jRAWG9A@mail.gmail.com>
 <20140724.141528.1823901044834131393.davem@davemloft.net> <CA+FuTSfm_WXtFYDeUNspN4=VNAAaQRxe2mvUYDD9Ho-yqJt8GA@mail.gmail.com>
 <20140724.165053.659177921712979472.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Chad Reese <kreese@caviumnetworks.com>,
	David Daney <ddaney@caviumnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:54424 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934824AbaGYARY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 20:17:24 -0400
Received: by mail-oi0-f52.google.com with SMTP id h136so2679933oig.25
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2014 17:17:24 -0700 (PDT)
In-Reply-To: <20140724.165053.659177921712979472.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> The kernel would simply saw that adjusted HW timestamps are not
>>> supported, the application has to accomodate the possibility of
>>> needing to use one of the other timestamping flavors.
>>
>> Cavium's PTP library already programs the device PTP clock,
>> just not through the standard interface. It appears to map the
>> memory addresses CVMX_MIO_.. directly. In any case, it
>> will gracefully handle the loss of syststamp.
>>
>> I doubt that there are other users of this Octeon interface, but
>> if so, they can reasonably be expected to do the same and
>> rely on the same legacy Octeon PTP clock interface +
>> hwtstamp as alternative. Is that enough justification to remove
>> syststamp without patching the driver to implement
>> ptp_clock_info?
>>
>> Cleanup would be two patches: one to revert the relevant
>> code in the octeon driver (mostly, ptp_to_ktime), and a
>> follow-up to remove the core code now that the last user
>> is gone.
>
> I'm not sure I understand, can users still get hardware timestamps
> from Octeon cards after such a change?  Unless I misunderstand, the
> only thing left available will be software timestamps, right?

They will still receive hardware timestamps in raw format. The
only feature that is deprecated is hardware timestamps
converted to system time format (ptp_to_ktime).

By querying the PTP clock source, users can perform  perform
this conversion to system time themselves. The Octeon driver
does not support the standard PTP clock interface, but does
appear to use its own alternative using shared memory. I'm
not exactly sure how that memory is setup.
