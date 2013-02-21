From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: why is it not allowed to add a new socket protocol family as
 an external module?
Date: Thu, 21 Feb 2013 10:19:23 -0600
Message-ID: <5126490B.4020206@genband.com>
References: <5125002D.9080008@genband.com>	<20130220152325.64c57d55@samsung-9>	<51256E02.4080509@genband.com>	<1361410797.17413.3.camel@edumazet-glaptop>	<51264195.9060800@genband.com> <20130221080425.72e36f6d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og112.obsmtp.com ([64.18.2.177]:46629 "EHLO
	exprod7og112.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753685Ab3BUQUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 11:20:37 -0500
In-Reply-To: <20130221080425.72e36f6d@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/21/2013 10:04 AM, Stephen Hemminger wrote:

> It is not impossible to make this dynamic, you would need to make the table an allocated
> object and use proper locking like RCU. Oh, and because it is using GPL, the symbols
> would have to be EXPORT_SYMBOL_GPL(), so any dream of proprietary stacks there would
> be skating on even thinner ice.
> The lockdep stuff makes it more complicated but not impossible.

I'm not even thinking about closed-source stacks.  In our particular 
case the use-case is highly proprietary (not to mention legacy and 
obscure) but GPL-compliant.

> The bigger issue is how would you manage statically assigned id's which
> are not visible int headers or kernel source. How would you keep AF_VENDOR_PROTOCOL1 from
> not colliding with AF_VENDOR_PROTOCOL2?

I wouldn't expect many people to have multiple dynamic protocols loaded, 
so I'm not sure this would be a big problem.

For a fully generic solution I think we'd need to do dynamic numbering 
and export the mapping somewhere like /sys/class/net or 
/proc/sys/net/core/.  This would makes things a bit non-standard for the 
userspace code, but would allow arbitrary numbers of dynamic protocols 
without collision.

Or maybe we get really crazy and do protocol namespaces. :)

Chris
