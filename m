From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: net_rx_action/NAPI oops [PATCH]
Date: Tue, 27 Nov 2007 14:34:44 -0800
Message-ID: <474C9B84.5090103@intel.com>
References: <18252.26472.319078.165019@robur.slu.se> <20071127140904.20c4cba8@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:43160 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752082AbXK0WfK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 17:35:10 -0500
In-Reply-To: <20071127140904.20c4cba8@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Tue, 27 Nov 2007 19:52:24 +0100
> Robert Olsson <Robert.Olsson@data.slu.se> wrote:
> 
>> Hello!
>>
>> I've discovered a bug while testing the new multiQ NAPI code. In hi-load 
>> situations when we take down an interface we get a kernel panic. The
>> oops is below.
>>
>> From what I see this happens when driver does napi_disable() and clears
>> NAPI_STATE_SCHED. In net_rx_action there is a check for work == weight 
>> a sort indirect test but that's now not enough to cover the load situation. 
>> where we have NAPI_STATE_SCHED cleared by e1000_down in my case and still 
>> full quota. Latest git but I'll guess the is the same in all later kernels.
>> There might be different solutions... one variant is below:
> 
> It is considered a driver bug in 2.6.24 to call netif_rx_complete (clear NAPI_STATE_SCHED)
> and do a full quota. That bug already had to be fixed in other drivers,
> look like e1000 has same problem.

Stephen,

please enlighten me, can you e.g. show me a commit of other drivers where you
fixed this up?

Thanks,

Auke
