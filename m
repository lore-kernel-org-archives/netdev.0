From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH RFC] r8169: straighten out overlength frame detection (v3)
Date: Tue, 5 Jan 2010 16:38:56 -0500
Message-ID: <20100105213856.GB24245@hmsreliant.think-freely.org>
References: <20091228194834.GA18422@hmsreliant.think-freely.org>
 <20100105135732.GA24245@hmsreliant.think-freely.org>
 <4B4357A9.5010507@gmail.com>
 <20100105.124040.192660261.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	romieu@fr.zoreil.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36262 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755081Ab0AEVjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 16:39:08 -0500
Content-Disposition: inline
In-Reply-To: <20100105.124040.192660261.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 05, 2010 at 12:40:40PM -0800, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 05 Jan 2010 16:15:53 +0100
> 
> > If hardware is buggy, driver should focus on security first,
> > performance doesnt matter in this case.
> 
> Copying every packet is way too much of a performance hit to
> accept.
> 
> Things are not so black and white, there are shades of grey.
> 
> We can fix this without making things so slow, try harder...
I think thats what I've done in my third version of the patch here.  By raising
the copybreak value, and setting an initial allocation size of 16k, we:

1) close the security hole by default
2) allow for smaller allocations during run time (allocations of the recevied
frame size, rather than 16k every time)
3) Give the user an out if they need the added performance. They have a module
option to lower the copybreak thrshold, and changing the mtu to a different
value will reset the rx allocation size, and frame filter value (and issue a big
warning that doing so may be dangerous)

As we determine which hardware id's are buggy, we can start blacklisting them
specifically, ejoining them from making mtu changes at all, and when we are
confident we have identified all the buggy hardware, we can flip the default
behavior to allocate a resonable frame size and set a good copybreak threshold
for anything not on the blacklist.

Regards
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
