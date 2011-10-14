From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 5/6] igb: fix timecompare_upate race condition
Date: Fri, 14 Oct 2011 11:26:46 +0200
Message-ID: <20111014092646.GA22928@netboy.at.omicron.at>
References: <1318573288-18286-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1318573288-18286-6-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Jacob Keller <jacob.e.keller@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:46013 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752291Ab1JNJ0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 05:26:47 -0400
Received: by eye27 with SMTP id 27so939897eye.19
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 02:26:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1318573288-18286-6-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 13, 2011 at 11:21:27PM -0700, Jeff Kirsher wrote:
> From: Jacob Keller <jacob.e.keller@intel.com>
> 
> This patch closes a possible race condition when timestamping using
> the timecompare_update function as a method to detect clock skew of
> the internal cycle counter. Because timecompare_update usually allows
> skew detection no more than once a second, if ptpd or other software
> performs a clock offset (for example, using the "date" command), there
> is a small window of time where the clock skew will not match the
> current kernel wall time. This patch forces the timecompare_update to
> calculate skew every time we timestamp a packet, which removes the
> possibility of this race condition.

NAK.

What will happen when you use the card for the telecom profile?

In that case you can expect 32 sync packets per second (plus delay
requests times number of clients).

A better way is to remove the timecompare stuff and offer a PTP
Hardware Clock instead. That would make the race condition a non-issue
and also enable the nice hardware clock offered by the card(s).

Thanks,
Richard
