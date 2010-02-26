From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] IPv6: fix anycast address ref count leakage
Date: Thu, 25 Feb 2010 16:54:52 -0800
Message-ID: <20100225165452.0ae3774c@nehalam>
References: <20100225155707.779c582a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39184 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934786Ab0BZAzH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2010 19:55:07 -0500
In-Reply-To: <20100225155707.779c582a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Feb 2010 15:57:07 -0800
Stephen Hemminger <shemminger@vyatta.com> wrote:

> The recent change in net-next to keep IPv6 address can lead to device
> hanging with unresolved refcount on removal. The issue is that the conversion
> of address from permanent to temporary needs to notify the anycast list
> code to clean up it's ref count. Also, want to tell other uses of IPv6
> (bonding/sctp) that the address is no longer available.
> 
> The fix is to notify like a regular delete.  When link comes back, DAD
> runs and will notify with NETDEV_UP that address is back.
> 
> The decrement of idev refcount when cleaning up addrconf_hash, should
> never cause address to be freed; therefore it can use __in6_ifa_put.
> 
> The timer cleanup should be done when address deletion is done
> in second loop.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 

Wait till I split/revise this one; it has a problem.


-- 
