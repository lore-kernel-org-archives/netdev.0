From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] net: napi fix
Date: Thu, 13 Dec 2007 10:22:33 -0800
Message-ID: <20071213102233.3727e9a0@freepuppy.rosehill>
References: <47602B77.2090202@intel.com>
	<b25c3fa70712122341q3ba282cdqda3fa56901b14484@mail.gmail.com>
	<47613E22.6060705@myri.com>
	<20071213.061938.86541759.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gallatin@myri.com, joonwpark81@gmail.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, jesse.brandeburg@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35769 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752611AbXLMSaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 13:30:13 -0500
In-Reply-To: <20071213.061938.86541759.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Dec 2007 06:19:38 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Andrew Gallatin <gallatin@myri.com>
> Date: Thu, 13 Dec 2007 09:13:54 -0500
> 
> > If the netif_running() check is indeed required to make a device break
> > out of napi polling and respond to an ifconfig down, then I think the
> > netif_running() check should be moved up into net_rx_action() to avoid
> > potential for driver complexity and bugs like the ones you found.
> 
> That, or something like it, definitely sounds reasonable and much
> better than putting the check into every driver :-)
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

It is not possible to do netif_running() check in generic code as currently
written because of the case of devices where a single NAPI object is
being used to handle two devices. The association between napi and netdevice
is M to N.  There are cases like niu that have multiple NAPI's and one
netdevice; and devices like sky2 that can have one NAPI and 2 netdevice's.

The existing pointer from napi to netdevice is only used by netconsole
now. For devices like sky2 it means that netconsole can't work on the the
second port which is a not a big problem. But adding a netif_running()
check would be a big issue.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
