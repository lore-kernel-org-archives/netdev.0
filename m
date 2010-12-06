From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] mark devices with broken LRO implementation
Date: Mon, 06 Dec 2010 09:28:55 -0800 (PST)
Message-ID: <20101206.092855.193714367.davem@davemloft.net>
References: <4CFD15F6.7040609@linux.vnet.ibm.com>
	<20101206091010.036cd78b@nehalam>
	<20101206171816.GA25568@lixom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, leitao@linux.vnet.ibm.com,
	eli@dev.mellanox.co.il, netdev@vger.kernel.org
To: olof@lixom.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35892
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752166Ab0LFR22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 12:28:28 -0500
In-Reply-To: <20101206171816.GA25568@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Olof Johansson <olof@lixom.net>
Date: Mon, 6 Dec 2010 11:18:16 -0600

> On Mon, Dec 06, 2010 at 09:10:10AM -0800, Stephen Hemminger wrote:
>> The kernel uses dev_disable_lro to disable Large Receive Offload
>> for cases where it is inappropriate. But several drivers do not implement
>> the required hook.  This is a "penalty box" patch to encourage those
>> drivers to add support for the necessary ethtool set_flags.
>> 
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> pasemi_mac:
> 
> Acked-by: Olof Johansson <olof@lixom.net>
> 
>> I only found three drivers that are broken. Normally, I would just fix
>> them; but since changing state in the device is hardware specific, and
>> I don't have the hardware or specs to do anything useful to fix it.
> 
> Thanks. All my hardware is currently in storage due to my relocation, but
> I'll take a look at it when I have something to run on back. :-)

I don't think we can do what this patch does.

It serves no purpose, as it just means the user is going to have an
extra headache to turn their driver on.

And %99 of them won't see it, the distribution folks will.

So this is all for nothing.

Better to just work on fixing the problem in the few drivers for
which the issue exists.

And I'm always happy to receive patches that just plain rip LRO
support out of such drivers.  That's a real legitimate patch unlike
this one because it keeps the user able to get their driver enabled
with no fuss and it removes only the improperly functioning feature.
