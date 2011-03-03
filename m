From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] VPN broken in net-next
Date: Wed, 02 Mar 2011 16:54:21 -0800 (PST)
Message-ID: <20110302.165421.258093056.davem@davemloft.net>
References: <20110302.164333.116393112.davem@davemloft.net>
	<20110302164637.6651b34f@nehalam>
	<20110302.165009.200353108.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58194
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752608Ab1CCAxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 19:53:44 -0500
In-Reply-To: <20110302.165009.200353108.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 02 Mar 2011 16:50:09 -0800 (PST)

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 2 Mar 2011 16:46:37 -0800
> 
>> The addresses (that matter) when VPN is up are:
> 
> I really need to know what addresses interfaces have the time of the
> __ip_dev_find() call which, if I'm not mistaken, is before the VPN is
> up.

Looking at pptp_connect(), it seems to be trying to do a route lookup
using the source address, before it registers the PPP channel and that
even gets brought up.

I suspect that was working by luck previously, and it was getting the
default route out perhaps another interface.  If that is the case,
removing the explicit "fl4_src" source address specification in the lookup
flow pptp_connect() uses should fix the problem.
