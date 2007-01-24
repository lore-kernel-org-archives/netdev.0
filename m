From: Russell Stuart <russell-tcatm@stuart.id.au>
Subject: Re:
	[PATCH	REPOST	1/2]	NET:	Accurate	packet	scheduling	for	ATM/ADSL (kernel)
Date: Thu, 25 Jan 2007 08:32:59 +1000
Message-ID: <1169677979.5776.150.camel@ras.pc.brisbane.lube>
References: <1161041677.6247.1.camel@ras.pc.brisbane.lube>
	 <1161090444.5555.13.camel@jzny2>  <45378DE3.8080700@trash.net>
	 <1161602527.5502.155.camel@ras.pc.stuart.local>
	 <453CB801.4010902@trash.net>
	 <1161640444.5502.214.camel@ras.pc.stuart.local> <453E3CFC.80007@trash.net>
	 <1161733596.3829.91.camel@ras.pc.brisbane.lube>
	 <456ED79E.2070707@trash.net> <1169075223.7560.15.camel@ras>
	 <45AEF219.2060304@trash.net> <1169100970.21535.18.camel@ras>
	 <45AF5C02.1010005@trash.net> <1169176280.1118.8.camel@ras>
	 <45B0B744.7070800@trash.net> <1169263517.11507.14.camel@ras>
	 <45B1D715.8010609@trash.net> <1169365528.3866.71.camel@ras.pc.stuart.local>
	 <45B78B8F.9090106@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	Jesper Dangaard Brouer <hawk@diku.dk>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 58.105.229.78.optusnet.com.au ([58.105.229.78]:51286 "EHLO
	adsl-kenny.stuart.id.au" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S932831AbXAXWgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 17:36:40 -0500
In-Reply-To: <45B78B8F.9090106@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-01-24 at 17:38 +0100, Patrick McHardy wrote:
> > The two RTAB's are different.  Thus you must send 
> > different RTAB's to pre-STAB and post-STAB kernels.  
> > How is "tc" to decide which one to send?  I did add 
> > code that checked uname once to solve a very 
> > similar problem in "tc", but that got my wrist 
> > slapped.
> 
> If the users asks to use STABs, send the modified RTAB.
> If the kernel doesn't support STABs it will return an error,
> which is good enough.

Yuk!  Now the user has to say whether he wants to use
STAB's or not?  Currently, apart from some debugging
params to tc, the user isn't even aware that the 
traffic control is implemented in terms of RTAB's.  
That is how it should be - it is an implementation 
detail.

> I think this is a different problem. If you replace RTABs
> by STABs you again can't use it for anything that is only
> interested in the size, not the transmission time (HFSC,
> SFQ, ...).

I was a little too brief.

The comment stems from the observation that in all
current implementations:

   const A_CONSTANT;
   for (i = 0; i < 256; i += 1)
     assert(RTAB[i] == STAB[i] * A_CONSTANT);

Ergo, if in addition to implementing STAB as you
plan to, A_CONSTANT was shipped to the kernel then
RTAB could be replaced.  A_CONSTANT could be set
so the calculation would return the time it would
take to send a packet in micro seconds, say (a
figure I just pulled out of the air).  This is 
1000 times more precise than the kernel can do 
now.

It wouldn't be perfect - the kernel would send the
packets in bursts.  But it would be good enough
to solve my problem with VOIP, I think.

