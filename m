From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: 2.6.23-rc4-mm1: e1000e napi lockup
Date: Fri, 07 Sep 2007 09:24:33 -0700
Message-ID: <46E17B41.4060200@intel.com>
References: <46E0FB82.2040000@gmail.com> <20070907.010338.41638771.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>, jirislaby@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:43758 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757697AbXIGQYp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2007 12:24:45 -0400
In-Reply-To: <20070907.010338.41638771.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Jiri Slaby <jirislaby@gmail.com>
> Date: Fri, 07 Sep 2007 09:19:30 +0200
> 
>> I found a regression in 2.6.23-rc4-mm1 (since -rc3-mm1) in e1000e driver.
>> napi_disable(&adapter->napi) in e1000_probe freezes the kernel on boot.
> 
> Yes, the semantics changed slightly in the net-2.6.24 tree the
> other week and someone needs to fix it up.
> 
> The netif_napi_add() implicitly does a napi_disable() call.  Device
> open must explicitly napi_enable() and device close must explicitly
> napi_disable(), and if done elsewhere these calls must be strictly
> balanced.

I'll fix it... it's my patch that adds the new napi code to it and I need to get 
it ready for the merge window anyway.

thanks for testing.

Auke
