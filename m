From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] Add PTP cross-timestamp to the PTP driver interface
Date: Fri, 26 Jun 2015 08:55:07 +0200
Message-ID: <20150626065507.GB1511@localhost.localdomain>
References: <1435275777-3918-1-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jacob.e.keller@intel.com,
	john.ronciak@intel.com, kevin.b.stanton@intel.com
To: Christopher Hall <christopher.s.hall@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:34452 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034AbbFZGzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 02:55:12 -0400
Received: by wicnd19 with SMTP id nd19so36703724wic.1
        for <netdev@vger.kernel.org>; Thu, 25 Jun 2015 23:55:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1435275777-3918-1-git-send-email-christopher.s.hall@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris,

Basically this patch looks okay to me.  Could you please add LKML,
John Stultz and tglx (the time guys) onto CC?  I would like to get
their Acks or at least let them have a chance to review it.

On Thu, Jun 25, 2015 at 04:42:56PM -0700, Christopher Hall wrote:
> This patch allows system and device time ("cross-timestamp") to be performed 
> by the driver. Currently, the timestamping is performed in the PTP_SYS_OFFSET 
> ioctl.  It reads gettimeofday() and the gettime64() callback provided by the 
> driver. The cross-timestamp is best effort ignoring the latency between the 
> capture of system time (getnstimeofday()) and the device time 
> (driver callback).

You can make the motivation more clear by mentioning how the newer
PCIe spec foresees "perfect" timestamps.  If I didn't already know the
background, I would wonder who would ever want "best effort" single
cross timestamps.

> Additionally, the callback, getsynctime64(), will only be called when 
> n_samples == 1 because the driver returns only 1 cross-timestamp where 
> multiple samples cannot be chained together.

There should be a way for user space to find out whether a particular
device offers the cross timestamp capability.  There are reserved
fields in 'struct ptp_clock_caps' that could be used.

Thanks,
Richard
