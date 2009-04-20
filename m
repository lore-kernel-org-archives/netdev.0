From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC]: add tracepoint to net_rx_action to note polling
	operations
Date: Mon, 20 Apr 2009 10:00:35 -0400
Message-ID: <20090420140035.GF32254@hmsreliant.think-freely.org>
References: <20090420211729.2218e5e2.nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Mark Smith
	<nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40674 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755054AbZDTOAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 10:00:43 -0400
Content-Disposition: inline
In-Reply-To: <20090420211729.2218e5e2.nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 20, 2009 at 09:17:29PM +0930, Mark Smith wrote:
> Hi,
> 
> (not on list, please CC me)
> 
> "I was thinking about adding an additional tracepoint to
> net_rx_action, right before the call to dev->poll().  One of the things
> thats missing from my dropwatch utility is the ability to detect
> hardware drops, and I was thinking I could implement that by noting
> when devices were being polled by napi, and at that time querying the
> devices stats.
> 
> 	I know however, that adding tracepoints isn't always
> desireable, so I thought I would solicit opinions here to see if anyone
> else would find such a tracepoint usefull, or in the event they had
> strong objectsions to such a point."
> 
> Would that be indicating that the host isn't keeping up with the
> incoming packet rate? If so, I'd think that would be quite useful, as
> it'd be a very obvious indicator that the host needs a performance
> upgrade, should the traffic be valid e.g. not a DoS attack.
> 
Its hard to apply context to it without knowning more.  It could mean that the
napi weight needs to be increased, or the NIC's irq coalescing needs to be
dialed back to reduce latency, or it could simply mean lots of wire errors.  The
only thing we can say for certain is that packets are being dropped, and thats
what dropwatch does.

Of course, theres a downside to this too.  Adding a tracepoint provides the
opportunity for others to hook into that point in the receive path, and
depending on how and what they hook, they can really mess things up, which is a
debugging nightmare.  And so tracepoints in this area are treated suspiciously.

I'm soliciting for opinions as to weather the benefit outweighs the risk/cost.

Neil

> Regards,
> Mark.
> 
> 
