From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next.git 5/7] stmmac: add sysFs support
Date: Mon, 3 Sep 2012 16:09:17 +0100
Message-ID: <1346684957.2688.15.camel@bwh-desktop.uk.solarflarecom.com>
References: <1346658422-1925-1-git-send-email-peppe.cavallaro@st.com>
	  <1346658422-1925-6-git-send-email-peppe.cavallaro@st.com>
	 <1346676267.7787.82.camel@deadeye.wl.decadent.org.uk>
	 <5044B245.5050703@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17813 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753364Ab2ICPJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2012 11:09:24 -0400
In-Reply-To: <5044B245.5050703@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-03 at 15:36 +0200, Giuseppe CAVALLARO wrote:
> Hello Ben,
> 
> On 9/3/2012 2:44 PM, Ben Hutchings wrote:
> > On Mon, 2012-09-03 at 09:47 +0200, Giuseppe CAVALLARO wrote:
> >> This patch adds the sysFs support.
> >> Some internal driver parameters can be tuned by using some
> >> entries exposed via sysFS. There parameter currently are,
> >> for example, for internal timers used to mitigate the rx/tx
> >> interrupts or for EEE.
> > [...]
> > 
> > Why are you not exposing these through the standard ethtool operations?
> > 
> > Ben.
> 
> yes I want to expose them via ethtool and I'll do this as soon as I have
> clear with ethtool parameters have to be used (
> http://marc.info/?l=linux-netdev&m=134561966226677&w=2 ).

Sorry, I meant to reply to that but didn't get round to it.

> For the reception side, I have the RI Watchdog Timer count field and I
> do not know what is the appropriate ethtool parameter to use.
> From the Synopsys databook, the RI Watchdog Timer count indicates the
> number of system clock cycles. When the it runs out, the receive
> interrupt bit is set and the timer is stopped.
> No idea if it can be actually covered, for example, with
> rx_coalesce_usecs_irq.

As I understand it, interrupt moderation time is supposed to be the
minimum time between completion IRQs, not a minimum delay from
completion-with-IRQ-armed to assertion of the IRQ.  The timer should
start running again immediately after the associated IRQ is asserted.
But I don't know whether it's universally implemented this way.

The field names including '_irq' are to be used if the hardware can use
a different moderation time while the IRQ is still masked (i.e. NAPI or
hard interrupt handler is still running).  I think most hardware doesn't
support this.

> For the transmission I have a SW timer that periodically calls the tx
> function (stmmac_tx) and a threshold to also set the "Interrupt on
> completion" bit in the TDES when a frame is transmitted.
> I wonder (but not sure) if in this case I could be: tx_coalesce_usec and
> tx_mac_coalesced_frames.
> From the kernel documentation IIUC these seem to have other meaning.

The semantics don't seem to match the documentation exactly but I think
this is probably close enough.

Ben.

> No problem, to extend ethtool to cover these kind of parameters if
> necessary.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
