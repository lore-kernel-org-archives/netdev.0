From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [net-next 11/13] igb: Update PTP function names/variables and
 locations.
Date: Thu, 23 Aug 2012 18:48:13 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5807857FFC@ORSMSX105.amr.corp.intel.com>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1345715813-20757-12-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120823111622.GC2238@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD079@ORSMSX101.amr.corp.intel.com>
 <20120823175335.GB2192@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD32D@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Vick, Matthew" <matthew.vick@intel.com>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:31003 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759195Ab2HWStG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 14:49:06 -0400
In-Reply-To: <06DFBC1E25D8024DB214DC7F41A3CD34488DD32D@ORSMSX101.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Vick, Matthew
> Sent: Thursday, August 23, 2012 11:35 AM
> To: Richard Cochran
> Cc: Kirsher, Jeffrey T; davem@davemloft.net; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com
> Subject: RE: [net-next 11/13] igb: Update PTP function names/variables and
> locations.
> 
> > -----Original Message-----
> > From: Richard Cochran [mailto:richardcochran@gmail.com]
> > Sent: Thursday, August 23, 2012 10:54 AM
> > To: Vick, Matthew
> > Cc: Kirsher, Jeffrey T; davem@davemloft.net; netdev@vger.kernel.org;
> > gospo@redhat.com; sassmann@redhat.com
> > Subject: Re: [net-next 11/13] igb: Update PTP function names/variables
> > and locations.
> >
> > On Thu, Aug 23, 2012 at 04:22:02PM +0000, Vick, Matthew wrote:
> >
> > > > >  #ifdef CONFIG_IGB_PTP
> > > > > -static int igb_ethtool_get_ts_info(struct net_device *dev,
> > > > > +static int igb_get_ts_info(struct net_device *dev,
> > > >
> > > > I like the old name better.
> > >
> > > The old name is out of the coding style of igb. Every other function
> > is igb_get_* or igb_set_*, with the exception of igb_ethtool_begin and
> > igb_ethtool_complete. Are you suggesting we add _ethtool to every
> > ethtool function in igb?
> >
> > No, just leave the names alone, and keep the functions where they are.
> > It is just churn.
> >
> > One of the most useful ways to understand code (at least for me) is to
> > use git blame. It tells you when code was added, what the reason was,
> > and how the change looks in context. By moving and renaming willy
> > nilly, you are obscuring this valuable information.
> 
> Repairing is not churn. I think it's better to make the code clearer than
> require developers use git blame to figure out who named a function in a
> silly way. I agree, it kind of stinks to lose that history, but I'd rather
> not skip making the right change because of git blame concerns.

The history isn't lost, it is just obscured. I agree if the change is necessary it should be done. I think we all disagree on what is necessary. I would prefer function names to match. Richard has a point regarding the time stamping all packets, however again the ioctl turning that on tends to be quite PTP centric already. I think that value isn't necessarily added due to the current coupling of the features. It is partially coupled by the hardware anyways.

Effectively with the PTP framework disabled you have a half useful feature that is enabled by a strange ioctl that has a lot of PTP specific names, and doesn't always do what you want.

I am not sure how much work would be required to get to a state where the separation of function makes sense.

- Jake

> 
> >
> > [...]
> >
> > >
> > > Which, this function calls igb_systim_to_hwtstamp anyway, which is
> > > global.
> >
> > So how does calling two global functions in series improve performance?
> 
> It isn't calling two global functions. It's calling a global function that
> calls a static function.
> 
> > > Also, in a follow-on patch I have coming, igb_ptp_tx_hwtstamp won't
> > > even be called in clean_tx_irq, FWIW.
> >
> > If this is part of some larger plan, then it would help to see that
> > plan.
> 
> Definitely fair enough. I will work with Jeff to try and push the whole
> series next time (at the very least, I'd like to re-spin the series for
> the ethtool query patch).
> 
> > > > >  /**
> > > > >   * igb_clean_tx_irq - Reclaim resources after transmit completes
> > > > >   * @q_vector: pointer to q_vector containing needed info @@
> > > > > -5827,7
> > > > > +5796,7 @@ static bool igb_clean_tx_irq(struct igb_q_vector
> > > > *q_vector)
> > > > >
> > > > >  #ifdef CONFIG_IGB_PTP
> > > > >  		/* retrieve hardware timestamp */
> > > > > -		igb_tx_hwtstamp(q_vector, tx_buffer);
> > > > > +		igb_ptp_tx_hwtstamp(q_vector, tx_buffer);
> > > >
> > > > This name stinks, too. You know that you can have time stamping
> > > > all by itself, right? It is logically separate from the ptp clock
> > stuff.
> > > >
> > > > This patch doesn't really improve the driver at all, IMHO.
> > > >
> > > > Thanks,
> > > > Richard
> > >
> > > Yes, I'm aware. But, as it stands today, we don't use it for
> > > anything
> > else. If the function is feature specific, then we should be calling
> > it out as such.
> >
> > Right now the time stamping is being equated with the clock functions,
> > but it really should be decoupled. The 82580 can time stamp every
> > received packet, which can be interesting for performance monitoring,
> > even without PTP (and adding *that* would be a useful change).
> 
> As Jake said, there's no support for hardware timestamping without PTP
> today. As such, if the function is only useful for that feature, then I
> think it's less ambiguous to leave it the way I've coded it today. If we
> de-couple hardware timestamping and clock synchronization, which I
> wouldn't be opposed to, then the function name can reflect becoming more
> generic. As it stands, I'd rather not call something generic when it
> isn't. I think it's misleading, personally.
> 
> > > I'm sorry you feel like this patch doesn't improve the driver. The
> > goal is code cleanup and consistency, both of which I consider to be
> > driver improvements and is why I made the patches.
> >
> > But the code wasn't dirty in the first place. It doesn't need this
> > "cleaning." This series undoes the inline-able functions for no good
> > reason. As far as ixgbe goes, this driver came first, so you might as
> > well be making *that* driver consistent with this one.
> >
> > Thanks,
> > Richard
> 
> Actually, yes, the code *was* dirty, because it breaks the coding style of
> the rest of the driver and isn't as self-documenting as it could be, and
> the inline-able functions you claim I'm destroying called global functions
> anyway. Also, just because igb came first doesn't mean we should ignore
> porting better or clearer solutions from later drivers. If something is
> better or clearer, I think we should use be using it.
> 
> Cheers,
> Matthew
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
