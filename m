From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: Best way to set kernel thread affinity for handling a socket?
Date: Thu, 23 Aug 2012 11:56:16 -0600
Message-ID: <50366EC0.2060004@genband.com>
References: <CAG4TOxNMRR_-bYJV1a_je2HKrpmVuGubH9ks4GdG8Shwa92K0w@mail.gmail.com> <1345652493.2709.36.camel@bwh-desktop.uk.solarflarecom.com> <CAG4TOxOdTiahqVo6+cD=mCN5Ov_hLa_m5gBTuj5sUYsM+GgnYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Roland Dreier <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og111.obsmtp.com ([64.18.2.175]:55122 "EHLO
	exprod7og111.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759156Ab2HWR4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 13:56:45 -0400
In-Reply-To: <CAG4TOxOdTiahqVo6+cD=mCN5Ov_hLa_m5gBTuj5sUYsM+GgnYw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/2012 11:04 AM, Roland Dreier wrote:
> On Wed, Aug 22, 2012 at 9:21 AM, Ben Hutchings
> <bhutchings@solarflare.com>  wrote:
>> With RFS we try to do the reverse: move the packets to match the socket
>> user.   But it's not (yet) turned on by default.  See
>> Documentation/networking/scaling.txt
>
> Fair enough.  However I think at least in this case it sounds like extra
> overhead: it should be easy for us to do everything on the CPU where
> the packets are being received.

In the general case though RFS can be useful.  We have a server with one 
application instance per core.  It's beneficial to be able to steer 
packets destined for a given instance to an eth driver queue whose 
interrupt is handled by the cpu running that instance.

Depending on the hardware being used, it may be possible to do this more 
efficiently.  The ixgbe driver (if the feature is enabled) will 
periodically look at the outgoing tcp traffic and set up hardware flow 
filtering rules to direct incoming traffic for that connection to the 
queue that sent out the messages.

Chris
