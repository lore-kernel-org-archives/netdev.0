From: Martin Devera <devik@cdi.cz>
Subject: Re: [PATCH 0/2] Runtime configuration of HTB's HYSTERESIS option
Date: Thu, 15 Jun 2006 11:49:27 +0200
Message-ID: <44912D27.4010503@cdi.cz>
References: <1150362059.5578.13.camel@ras.pc.brisbane.lube>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@osdl.org>,
	netdev@vger.kernel.org, lartc@mailman.ds9a.nl,
	Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www1.cdi.cz ([194.213.194.49]:15797 "EHLO www1.cdi.cz")
	by vger.kernel.org with ESMTP id S932414AbWFOJuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2006 05:50:23 -0400
To: Russell Stuart <russell-tcatm@stuart.id.au>
In-Reply-To: <1150362059.5578.13.camel@ras.pc.brisbane.lube>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Russell Stuart wrote:
> The HTB qdisc has a compile time option, HTB_HYSTERESIS, 
> that trades accuracy of traffic classification for CPU 
> time.  These patches change hysteresis to be a runtime 
> option under the control of "tc".
> 
> The effects of HYSTERESIS on HTB's accuracy are significant 
> (see chapter 7, section 7.3.1, pp 69-70 in Jesper Brouer's
> thesis: http://www.adsl-optimizer.dk/thesis/ ), whereas 
> HTB's CPU usage on modern machines using broadband links 
> is minimal.  Currently HYSTERESIS is on by default, and 
> requires a kernel re-compile to change.  Altering it to 
> be a runtime option will make life easier for the bulk of 
> its users.

At time of HTB implementation I needed to reach 100MBit speed on 
relatively slow box. The hysteresis was a way. On other side I used 
hand-made TSC based measure tool to compute exact (15%) performance 
gain. Today I'd measure it using oprofile.

When rethinking it again I'd suggest to re-measure real performance 
impact for both flat and deep class hierarchy and consider switching the 
hysteresis off by default (or even to remove the code if the gain is 
negligible). If it is the case then it is the cleanest solution IMHO.

On other side I see no problem with attached patches. Have you tested 
patched kernel with old "tc" tool ?

thanks for your effort,
Martin
