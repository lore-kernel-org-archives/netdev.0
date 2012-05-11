From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 06/12] ixgbe: Hardware Timestamping + PTP Hardware
 Clock (PHC)
Date: Fri, 11 May 2012 07:15:09 +0200
Message-ID: <20120511051509.GA2170@netboy.at.omicron.at>
References: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1336632413-19135-7-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120510141122.GB3392@localhost.localdomain>
 <02874ECE860811409154E81DA85FBB580779423F@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:43109 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753820Ab2EKFPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 01:15:22 -0400
Received: by bkcji2 with SMTP id ji2so1919379bkc.19
        for <netdev@vger.kernel.org>; Thu, 10 May 2012 22:15:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <02874ECE860811409154E81DA85FBB580779423F@ORSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 10, 2012 at 09:53:18PM +0000, Keller, Jacob E wrote:
> > > +	/*
> > > +	 * If this bit is set, then the RX registers contain the time stamp. No
> > > +	 * other packet will be time stamped until we read these registers, so
> > > +	 * read the registers to make them available again. Because only one
> > > +	 * packet can be time stamped at a time, we know that the register
> > > +	 * values must belong to this one here and therefore we don't need to
> > > +	 * compare any of the additional attributes stored for it.
> > 
> > I suspect that this assumption is wrong. What happens if the time stamping
> > logic locks a value but the packet is lost because the ring is full?
> > 
> > BTW, the IGB driver also has this defect.
> >
> 
> Note how I read the rx registers first? So it will always clear the value.
> That should unlock the value for the next rx stamp packet.

1. Hw recognizes ptp event packet, locks time stamp
2. Hw drops packet because queue is full
3. No more time stamps are ever generated

Can this happen? The docs seems to say it can.

Richard
