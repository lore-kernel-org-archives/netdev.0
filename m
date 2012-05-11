From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [net-next 06/12] ixgbe: Hardware Timestamping + PTP Hardware
 Clock (PHC)
Date: Fri, 11 May 2012 18:05:55 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5807794941@ORSMSX105.amr.corp.intel.com>
References: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1336632413-19135-7-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120510141122.GB3392@localhost.localdomain>
 <02874ECE860811409154E81DA85FBB580779423F@ORSMSX105.amr.corp.intel.com>
 <20120511051509.GA2170@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10605 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932096Ab2EKSF5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 14:05:57 -0400
In-Reply-To: <20120511051509.GA2170@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Thursday, May 10, 2012 10:15 PM
> To: Keller, Jacob E
> Cc: Kirsher, Jeffrey T; davem@davemloft.net; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com
> Subject: Re: [net-next 06/12] ixgbe: Hardware Timestamping + PTP Hardware
> Clock (PHC)
> 
> On Thu, May 10, 2012 at 09:53:18PM +0000, Keller, Jacob E wrote:
> > > > +	/*
> > > > +	 * If this bit is set, then the RX registers contain the time
> stamp. No
> > > > +	 * other packet will be time stamped until we read these
> registers, so
> > > > +	 * read the registers to make them available again. Because only
> one
> > > > +	 * packet can be time stamped at a time, we know that the
> register
> > > > +	 * values must belong to this one here and therefore we don't
> need to
> > > > +	 * compare any of the additional attributes stored for it.
> > >
> > > I suspect that this assumption is wrong. What happens if the time
> > > stamping logic locks a value but the packet is lost because the ring is
> full?
> > >
> > > BTW, the IGB driver also has this defect.
> > >
> >
> > Note how I read the rx registers first? So it will always clear the value.
> > That should unlock the value for the next rx stamp packet.
> 
> 1. Hw recognizes ptp event packet, locks time stamp 2. Hw drops packet because
> queue is full 3. No more time stamps are ever generated
> 
> Can this happen? The docs seems to say it can.
> 
> Richard

It might be possible. I'm curious what's the best method to solve this. I don't
think this generation of hardware can get an interrupt when the RX timestamp is
locked, and I don't know how easy it would be to process the sequence number within
the driver. It might be the case that the next packet would still be marked in the
descriptor and therefor the previous timestamp would apply to the next packet. I am
not sure, but I know we haven't seen issues where timestamps drop completely. This
is something I am not sure what's the best solution.

- Jake
