From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: [BUG] oops in net_rx_action on 64-bit powerpc
Date: Fri, 24 Oct 2008 23:42:48 -0600
Message-ID: <4902B1D8.8070800@nortel.com>
References: <F169D4F5E1F1974DBFAFABF47F60C10A069DFCEF@orsmsx507.amr.corp.intel.com> <20081023.171614.72881694.davem@davemloft.net>	<49025C94.60406@nortel.com> <20081024.164128.113131091.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, romieu@fr.zoreil.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kn.nortel.com ([47.140.192.55]:39026 "EHLO
	zrtps0kn.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbYJYFnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2008 01:43:35 -0400
In-Reply-To: <20081024.164128.113131091.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: "Chris Friesen" <cfriesen@nortel.com>
> Date: Fri, 24 Oct 2008 17:39:00 -0600
> 
>> So...it would appear that the NAPI code is somehow buggy, and
>> 6ba33ac should probably be reverted until the problem is found and
>> fixed.
> 
> No I think the problem is simple enough that someone should study the
> ->poll() routine quickly and audit it's return values.

Assuming that amd8111e_rx_poll() is the proper routine, there is only one exit 
point, and it returns "num_rx_pkt".  This variable is initialized to zero and 
increments for each packet sent up the stack.

Chris
