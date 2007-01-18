From: Russell Stuart <russell-tcatm@stuart.id.au>
Subject: Re: [PATCH REPOST 1/2]
	NET:	Accurate	packet	scheduling	for	ATM/ADSL (kernel)
Date: Thu, 18 Jan 2007 16:16:10 +1000
Message-ID: <1169100970.21535.18.camel@ras>
References: <1161041677.6247.1.camel@ras.pc.brisbane.lube>
	 <1161090444.5555.13.camel@jzny2>  <45378DE3.8080700@trash.net>
	 <1161602527.5502.155.camel@ras.pc.stuart.local>
	 <453CB801.4010902@trash.net>
	 <1161640444.5502.214.camel@ras.pc.stuart.local> <453E3CFC.80007@trash.net>
	 <1161733596.3829.91.camel@ras.pc.brisbane.lube>
	 <456ED79E.2070707@trash.net> <1169075223.7560.15.camel@ras>
	 <45AEF219.2060304@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from [169.222.11.117] ([169.222.11.117]:38783 "EHLO
	localhost.localdomain" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S932578AbXARWMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jan 2007 17:12:37 -0500
To: hadi@cyberus.ca, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>
In-Reply-To: <45AEF219.2060304@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-01-18 at 05:05 +0100, Patrick McHardy wrote:
> > Yesterday I was chatting about this at LCA 2007, and 
> > it dawned on me that there is a problem with the dual
> > RTAB/STAB approach.
> > 
> > Currently the lookup in the kernel is
> >   time_to_transmit_a_packet = RTAB[packet_length_seen_by_kernel]
> > 
> > As I understand it, you are proposing to change that to
> >   time_to_transmit_a_packet
> >     = RTAB[STAB[packet_length_seen_by_kernel]]
> >     = RTAB[packet_length_seen_on_the_wire]
> > 
> > Given RTAB is the same in both cases the results of the
> > calculation will be different (and ergo wrong in one case
> > or the other).  RTAB can't change and remain compatible 
> > with old kernels.  Ergo this approach breaks backward 
> > compatibility.
> 
> RTABs don't change, they continue to work as before. But when
> an STAB is present the lookup is based on the STAB size mapping.
> Neither one is wrong, RTABs calculate the transmission time based
> only on the specified rate, RTABs + STABs calculate the
> transmission time based on the rate, but include external overhead.

No argument with "RTAB works as before".  But aren't
you proposing to feed it the accurate packet lengths
calculated STAB?  For example, if the VOIP IP datagram
is 60 bytes, older kernels will index RTAB by 
(60 + ethernet_header_size), STAB kernels will index
it by 159 bytes (3 ATM cells - say).  If "tc" doesn't
do a uname call or something, then it will send the
same RTAB to both kernels.  Obviously the results
returned by the RTAB lookup will be different.

If you aren't proposing to feed the RTAB lookup with
the output of STAB, then I still don't understand
why the current ATM patch isn't needed.

Or are you proposing tc behave differently on different
kernel versions.  (I have no problem with that, but
isn't it officially frowned upon?)

