From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 07/12] ixgbe: Enable timesync clock-out feature for
 PPS support on X540
Date: Fri, 11 May 2012 07:36:07 +0200
Message-ID: <20120511053605.GB2170@netboy.at.omicron.at>
References: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1336632413-19135-8-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120510141721.GC3392@localhost.localdomain>
 <02874ECE860811409154E81DA85FBB5807794253@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:44788 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754731Ab2EKFgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 01:36:18 -0400
Received: by bkcji2 with SMTP id ji2so1927059bkc.19
        for <netdev@vger.kernel.org>; Thu, 10 May 2012 22:36:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <02874ECE860811409154E81DA85FBB5807794253@ORSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 10, 2012 at 09:54:52PM +0000, Keller, Jacob E wrote:
> > Since this function is called in every interrupt, I would check this flag
> > first thing.
> > 
> Not sure what you mean? Check this before checking the other interrupts?
> I can do that.

I only meant that, assuming that the other interrupt sources are much
more frequent than the PPS, the normal case will be that the PPS flag
is not set.

It would be more efficient (that is, shorter ISR code path in normal
case) to check the flag first, perhaps like this.

ixgbe_intr()
{
	...
#ifdef CONFIG_IXGBE_PTP
	if (eicr & IXGBE_EICR_TIMESYNC)
		ixgbe_ptp_check_pps_event(adapter, eicr);
#endif
	...
}

Thanks,
Richard
