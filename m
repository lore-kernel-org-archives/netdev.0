From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 11/13] igb: Update PTP function names/variables and
 locations.
Date: Thu, 23 Aug 2012 20:11:18 +0200
Message-ID: <20120823181117.GD2192@netboy.at.omicron.at>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1345715813-20757-12-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120823111622.GC2238@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD079@ORSMSX101.amr.corp.intel.com>
 <20120823175335.GB2192@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB5807857EEA@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Vick, Matthew" <matthew.vick@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:49232 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755420Ab2HWSLa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 14:11:30 -0400
Received: by weyx8 with SMTP id x8so559366wey.19
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 11:11:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <02874ECE860811409154E81DA85FBB5807857EEA@ORSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 23, 2012 at 06:00:37PM +0000, Keller, Jacob E wrote:
> > 
> > Right now the time stamping is being equated with the clock functions, but
> > it really should be decoupled. The 82580 can time stamp every received
> > packet, which can be interesting for performance monitoring, even without
> > PTP (and adding *that* would be a useful change).
> > 
> The timestamp all does not really work with the ptp clock features
> gone, because you don't have the clock. You can't equate the time
> values of the packets when the clock isn't synched to something
> meaningful. Yes that does not require PTP adjustment functions, but
> it does require the SYSTIME setup and some method to get the clock
> correct, which currently is only done in the PTP init sequence.

Relative, high resolution time stamps can be interesting all by
themselves. That is why wireshark has a whole menu of timing choices
including relative since start, inter-packet, and so on.

> Timestamp all packets also can cause a performance hit when used with certain workloads.

Only when enabled.

> ixgbe hardware is (currently) even more closely synched with PTP for the register bits so it does make some sense for ixgbe to remain the way it is. Right now the igb features are partially synched (even before this change) in odd ways. The time values returned when PHC information is disabled are basically only useful for comparing between themselves, not with any meaningful clock on the device.

Yes, I agree that igb is a bit oddly synced WRT clock and time
stamping. I would welcome a change to let it have HW time stamping as
an independent feature.

Thanks,
Richard
