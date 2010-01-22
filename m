From: Blaschka <frank.blaschka@de.ibm.com>
Subject: Re: [RFC] qeth: exploit gro for layer 3 driver
Date: Fri, 22 Jan 2010 07:14:20 +0100
Message-ID: <20100122061420.GA31545@tuxmaker.boeblingen.de.ibm.com>
References: <20100121123722.GA13815@tuxmaker.boeblingen.de.ibm.com> <20100121.051133.102632014.davem@davemloft.net> <20100121134845.GA28645@tuxmaker.boeblingen.de.ibm.com> <20100121.060354.119388130.davem@davemloft.net> <1264084527.5880.45.camel@bender>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: Jan Glauber <jang@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.17.165]:44057 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751413Ab0AVGOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 01:14:22 -0500
Content-Disposition: inline
In-Reply-To: <1264084527.5880.45.camel@bender>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 21, 2010 at 03:35:27PM +0100, Jan Glauber wrote:
> On Thu, 2010-01-21 at 06:03 -0800, David Miller wrote:
> > From: Blaschka <frank.blaschka@de.ibm.com>
> > Date: Thu, 21 Jan 2010 14:48:45 +0100
> > 
> > > So the qeth driver can not disable qdio IRQs (I guess this is a
> > > major reason why not using NAPI) and poll the data.
> > 
> > Just because you cannot stop the events from coming in
> > doesn't mean you can't just queue them up in software
> > or similar.
> 
> The data is already queued (since qdio stands for queued direct I/O).
> Currently qdio gets the interrupt, does some processing and
> tells qeth which buffers contain the new data.
> 
> So the only question is what needs to be different for NAPI
> regarding the event signaling.
> 
> --Jan
> 
Hi Jan,
with some qdio changes we may be able to support NAPI. Let's
checkout what we can do ...

Dave, thanks for the feedback

  Frank

> > The important bits you get are:
> > 
> > 1) RX ring depletion and packet processing all from software
> >    interrupt context
> > 
> > 2) transparent GRO support, without the generic code having
> >    to disclose most of the GRO internals to drivers
> > 
> > I think it can be done.
> > 
> > I have a similar issue as your's with the Sun virtualized network
> > driver (I can't really stop the hypervisor events from pouring in) on
> > sparc64 and I plan to add NAPI support to it.
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-s390" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-s390" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
