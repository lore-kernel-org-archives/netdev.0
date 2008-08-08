From: Nathan Lynch <ntl@pobox.com>
Subject: Re: Strange tg3 regression with UMP fw. link reporting
Date: Fri, 8 Aug 2008 16:25:58 -0500
Message-ID: <20080808212558.GL6967@localdomain>
References: <1218180939.24157.332.camel@pasglop>
 <31233EB5-037E-4615-95C9-7C816E510752@kernel.crashing.org>
 <1218187111.24157.336.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Segher Boessenkool <segher@kernel.crashing.org>,
	mcarlson@broadcom.com, linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a-sasl-fastnet.sasl.smtp.pobox.com ([207.106.133.19]:54127 "EHLO
	sasl.smtp.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754661AbYHHV0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 17:26:08 -0400
Content-Disposition: inline
In-Reply-To: <1218187111.24157.336.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin Herrenschmidt wrote:
> On Fri, 2008-08-08 at 10:58 +0200, Segher Boessenkool wrote:
> > > I don't know yet for sure what happens, but a quick look at the commit
> > > seems to show that the driver synchronously spin-waits for up to 2.5ms
> > 
> > That's what the comment says, but the code says 2.5 _seconds_:
> > 
> > +       /* Wait for up to 2.5 milliseconds */
> > +       for (i = 0; i < 250000; i++) {
> > +               if (!(tr32(GRC_RX_CPU_EVENT) & GRC_RX_CPU_DRIVER_EVENT))
> > +                       break;
> > +               udelay(10);
> > +       }
> > 
> > (not that milliseconds wouldn't be bad already...)
> 
> Right, indeed. I think we have a good candidate for the problem :-)

I put a printk in tg3_wait_for_event_ack and I can confirm that it's
timing out frequently (every few seconds) on my system.  Changing the
number of loop iterations to 250 alleviates the problem.
