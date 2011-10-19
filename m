From: Jacob Keller <jacob.keller@gmail.com>
Subject: Re: [net-next 5/6] ixgbe: add hardware timestamping support
Date: Wed, 19 Oct 2011 10:04:33 -0700
Message-ID: <CA+P7+xoP7VE0FEKnLCbzygw499xLr1PFynPn6W0+ud6KwZHgEg@mail.gmail.com>
References: <1318854062-3628-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1318854062-3628-6-git-send-email-jeffrey.t.kirsher@intel.com> <20111017164433.GA2028@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	Jacob Keller <jacob.e.keller@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57482 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753596Ab1JSREy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 13:04:54 -0400
Received: by wyg36 with SMTP id 36so1961598wyg.19
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2011 10:04:53 -0700 (PDT)
In-Reply-To: <20111017164433.GA2028@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 17, 2011 at 9:44 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Mon, Oct 17, 2011 at 05:21:01AM -0700, Jeff Kirsher wrote:
>> The cyclecounter has the potential to miss a wrap-around of the
>> systim register (this should occur no more often than every 35
>> seconds) unless some activity regarding the cycle counter occurs at
>> least once within this time. This version adds a cycle counter read
>> every time the watchdog task is run, which should occur at least onc=
e
>> within this timeframe. Any packets being timestamped will also count
>> as a read due to the call to timecompare_update.
>
> So, is this wrap around due to the fact that you are tied to the
> system time via time_compare? Or, putting it another way, can't you
> program the hardware time stamping unit so that the registers have
> some reasonable resolution (like 64 bits worth of nanoseconds) and
> just offer RAW timestamps?

The wrap around is due to hardware limitations. The ixgbe devices
cannot support 64bits worth of nanoseconds and still have the ability
to adjust the frequency in parts per billion. A larger increment
increases the resolution available for frequency adjustments, but
decreases the time it takes for the cycle counter to wrap around.

>
> I would really like to move away from the timecompare hacks and
> towards a proper PHC->SYS PPS solution.
>

I agree that this is the correct approach. The timecompare
functionality does have issues.

>> This version fixes an issue regarding timecompare not updating
>> detected skew after the clock offset is changed due to ptpd or outsi=
de
>> influence from the OS. Now the skew detection is forced just before =
we
>> hand a timestamp up to the kernel stack
>
> Again, doing the update thing on every packet won't work for real
> world PTP scenarios.
>
Which is why the PHC solution is better. Work on implementing this
support is in progress. Out of curiosity, what is the sync rate for
the scenario that breaks this? I would like to try that rate out on my
setup.

> Thanks,
> Richard
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
