From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: net_rx_action/NAPI oops [PATCH]
Date: Tue, 27 Nov 2007 14:09:04 -0800
Message-ID: <20071127140904.20c4cba8@freepuppy.rosehill>
References: <18252.26472.319078.165019@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Robert.Olsson@data.slu.se, Auke Kok <sofar@foo-projects.org>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50001 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758667AbXK0WJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 17:09:55 -0500
In-Reply-To: <18252.26472.319078.165019@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Nov 2007 19:52:24 +0100
Robert Olsson <Robert.Olsson@data.slu.se> wrote:

> 
> Hello!
> 
> I've discovered a bug while testing the new multiQ NAPI code. In hi-load 
> situations when we take down an interface we get a kernel panic. The
> oops is below.
> 
> From what I see this happens when driver does napi_disable() and clears
> NAPI_STATE_SCHED. In net_rx_action there is a check for work == weight 
> a sort indirect test but that's now not enough to cover the load situation. 
> where we have NAPI_STATE_SCHED cleared by e1000_down in my case and still 
> full quota. Latest git but I'll guess the is the same in all later kernels.
> There might be different solutions... one variant is below:

It is considered a driver bug in 2.6.24 to call netif_rx_complete (clear NAPI_STATE_SCHED)
and do a full quota. That bug already had to be fixed in other drivers,
look like e1000 has same problem.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
