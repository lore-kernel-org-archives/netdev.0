From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: NAPI poll behavior in various Intel drivers
Date: Mon, 7 Jan 2008 09:24:13 +0100
Message-ID: <20080107082413.GA1761@ff.dom.local>
References: <20080104.034036.160194618.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, auke-jan.h.kok@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:27267 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754063AbYAGISK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 03:18:10 -0500
Received: by ug-out-1314.google.com with SMTP id z38so3116424ugc.16
        for <netdev@vger.kernel.org>; Mon, 07 Jan 2008 00:18:08 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080104.034036.160194618.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04-01-2008 12:40, David Miller wrote:
...
> That "tx_cleaned" thing clouds the logic in all of these driver's
> poll routines.
> 
> The one necessary precondition is that when work_done < budget
> we exit polling and return a value less than budget.
> 
> If the ->poll() returns a value less than budget, net_rx_action()
> assumes that the device has been removed from the poll() list.
> 
> 		/* Drivers must not modify the NAPI state if they
> 		 * consume the entire weight.  In such cases this code
> 		 * still "owns" the NAPI instance and therefore can
> 		 * move the instance around on the list at-will.
> 		 */
> 		if (unlikely(work == weight))
> 			list_move_tail(&n->poll_list, list);
> 

Probably it's because of this clouded logic, but IMHO: "Drivers must
not modify the NAPI state if..." doesn't imply: drivers must modify
the NAPI state otherwise. (But it seems I must have missed the real
reason for this quote here.)

Regards,
Jarek P.
