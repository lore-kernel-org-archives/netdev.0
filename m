From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Deliver skbs to intermediate interfaces, when using cascaded
 rx-handlers
Date: Fri, 21 Feb 2014 11:26:26 +0100
Message-ID: <20140221102626.GC2870@minipsycho.orion>
References: <20140221100158.GA19594@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tobias Waldekranz <tobias@waldekranz.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:39708 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754411AbaBUK03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 05:26:29 -0500
Received: by mail-ee0-f52.google.com with SMTP id c41so633377eek.39
        for <netdev@vger.kernel.org>; Fri, 21 Feb 2014 02:26:28 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140221100158.GA19594@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Feb 21, 2014 at 11:01:58AM CET, tobias@waldekranz.com wrote:
>I have a system with the following configuration:
>
>   * eth0 is a regular Ethernet MAC, connected to a hardware switch.
>   * port[1-4] are the in-kernel representation of the switch.
>   * team0 is a regular team-interface which bonds port1 and port2.
>
>      +-------+
>      | team0 |
>      +---+---+
>          |
>     +----+----+
>     |         |
> +---+---+ +---+---+ +-------+ +-------+
> | port1 | | port2 | | port3 | | port4 | 
> +---+---+ +---+---+ +---+---+ +---+---+
>     |         |         |         |
>     +---------+----+----+---------+
>                    |
>                +---+---+
>                | eth0  |
>                +-------+
>
>Both the switch and the team driver attaches rx-handlers to their
>lower layers. The problem is that team expects LACP frames that
>are intercepted by team0, to also be delivered to the port interface
>by __netif_receive_skb_core (in the final iteration of the registered
>protocols). However in this case, when two rx-handlers are cascaded,
>the skb will be delivered to eth0, since that is the original device
>(orig_dev).
>
>There are a few ways this can be solved as far as i can see:
>
>   1. Introduce a new rx-handler return code that specifies that
>   skb->dev has been altered, like RX_HANDLER_ANOTHER, and that we
>   also want to change orig_dev to this new device.
>
>   2. Change the switch driver to return RX_HANDLER_CONSUMED and then
>   queue the skb all over again, though I am afraid that this will eat
>   some cycles.

What "switch driver" are you reffering to?



>
>   3. Keep track of all traversed interfaces and change the final
>   protocol iteration to deliver the skb to all intermediate devices.
>
>What would be your suggestion?
>
>-- 
>Thanks
> - wkz
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
