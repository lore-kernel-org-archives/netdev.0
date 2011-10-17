From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 5/6] ixgbe: add hardware timestamping support
Date: Mon, 17 Oct 2011 18:44:33 +0200
Message-ID: <20111017164433.GA2028@netboy.at.omicron.at>
References: <1318854062-3628-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1318854062-3628-6-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Jacob Keller <jacob.e.keller@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:53579 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001Ab1JQQoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 12:44:32 -0400
Received: by eye27 with SMTP id 27so3150381eye.19
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2011 09:44:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1318854062-3628-6-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 17, 2011 at 05:21:01AM -0700, Jeff Kirsher wrote:
> The cyclecounter has the potential to miss a wrap-around of the
> systim register (this should occur no more often than every 35
> seconds) unless some activity regarding the cycle counter occurs at
> least once within this time. This version adds a cycle counter read
> every time the watchdog task is run, which should occur at least once
> within this timeframe. Any packets being timestamped will also count
> as a read due to the call to timecompare_update.

So, is this wrap around due to the fact that you are tied to the
system time via time_compare? Or, putting it another way, can't you
program the hardware time stamping unit so that the registers have
some reasonable resolution (like 64 bits worth of nanoseconds) and
just offer RAW timestamps?

I would really like to move away from the timecompare hacks and
towards a proper PHC->SYS PPS solution.

> This version fixes an issue regarding timecompare not updating
> detected skew after the clock offset is changed due to ptpd or outside
> influence from the OS. Now the skew detection is forced just before we
> hand a timestamp up to the kernel stack

Again, doing the update thing on every packet won't work for real
world PTP scenarios.

Thanks,
Richard
