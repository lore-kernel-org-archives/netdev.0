From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH	REPOST	1/2]	NET:	Accurate	packet	scheduling	for	ATM/ADSL
 (kernel)
Date: Thu, 25 Jan 2007 01:06:26 +0100
Message-ID: <45B7F482.7040703@trash.net>
References: <1161041677.6247.1.camel@ras.pc.brisbane.lube>	 <1161090444.5555.13.camel@jzny2>  <45378DE3.8080700@trash.net>	 <1161602527.5502.155.camel@ras.pc.stuart.local>	 <453CB801.4010902@trash.net>	 <1161640444.5502.214.camel@ras.pc.stuart.local> <453E3CFC.80007@trash.net>	 <1161733596.3829.91.camel@ras.pc.brisbane.lube>	 <456ED79E.2070707@trash.net> <1169075223.7560.15.camel@ras>	 <45AEF219.2060304@trash.net> <1169100970.21535.18.camel@ras>	 <45AF5C02.1010005@trash.net> <1169176280.1118.8.camel@ras>	 <45B0B744.7070800@trash.net> <1169263517.11507.14.camel@ras>	 <45B1D715.8010609@trash.net> <1169365528.3866.71.camel@ras.pc.stuart.local>	 <45B78B8F.9090106@trash.net> <1169677979.5776.150.camel@ras.pc.brisbane.lube>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	Jesper Dangaard Brouer <hawk@diku.dk>
To: Russell Stuart <russell-tcatm@stuart.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33599 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932884AbXAYAG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 19:06:29 -0500
In-Reply-To: <1169677979.5776.150.camel@ras.pc.brisbane.lube>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Russell Stuart wrote:
> Yuk!  Now the user has to say whether he wants to use
> STAB's or not?  Currently, apart from some debugging
> params to tc, the user isn't even aware that the 
> traffic control is implemented in terms of RTAB's.  
> That is how it should be - it is an implementation 
> detail.

Of course he has to, just like your "atm" parameter. In case
of stabs it would be something like "stab atm".

>>I think this is a different problem. If you replace RTABs
>>by STABs you again can't use it for anything that is only
>>interested in the size, not the transmission time (HFSC,
>>SFQ, ...).
> 
> 
> I was a little too brief.
> 
> The comment stems from the observation that in all
> current implementations:
> 
>    const A_CONSTANT;
>    for (i = 0; i < 256; i += 1)
>      assert(RTAB[i] == STAB[i] * A_CONSTANT);
> 
> Ergo, if in addition to implementing STAB as you
> plan to, A_CONSTANT was shipped to the kernel then
> RTAB could be replaced.

At least look at the patch I sent. STAB mapping is _not_ a
multiplication by a constant (which wouldn't be able to
express minimum packet size or padding to multiples of cell
sizes).
