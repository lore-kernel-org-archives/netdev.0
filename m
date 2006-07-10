From: Ben Greear <greearb@candelatech.com>
Subject: Re: [VLAN]: translate IF_OPER_DORMANT to netif_dormant_on()
Date: Mon, 10 Jul 2006 10:02:04 -0700
Message-ID: <44B2880C.9040801@candelatech.com>
References: <200603211829.k2LITMNR029085@hera.kernel.org>	<44AE2FCC.6020207@trash.net>	<20060707143314.67bf07ff@dxpl.pdx.osdl.net>	<200607091049.31628.stefan@loplof.de> <20060710095603.0b197eec@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stefan Rompf <stefan@loplof.de>, Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:56024 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1422701AbWGJRCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2006 13:02:14 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060710095603.0b197eec@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Sun, 9 Jul 2006 10:49:31 +0200
> Stefan Rompf <stefan@loplof.de> wrote:
> 
> 
>>Am Freitag, 7. Juli 2006 23:33 schrieb Stephen Hemminger:
>>
>>
>>>Not really. The flag code last major change was to do the dormant
>>>stuff that HDLC wanted.
>>
>>... and where the maintainer doesn't seem to care to use it now that the 
>>infrastructure is there. Sigh.
>>
>>
>>>IMHO VLAN device's should mirror the state of the underlying physical
>>>device.
>>>
>>>I can't really follow the thread well. What is broken?
>>
>>The thread is still quite short and describes the problem, look at 
>>http://marc.theaimsgroup.com/?t=115200782600004&r=1&w=2
>>
>>Stefan
> 
> 
> 
> Okay, going back to the original problem, before the current round
> of name calling. This bug shows a lot of problems with the existing
> VLAN device state management.
> 
> 1. I think vlan code should never be using the state bits directly at all.
> It makes the code error prone if the bits ever change, and it means
> that the proper callbacks are not being done. The existing vlan_transfer_operstate
> does what you want. VLAN_LINK_STATE_MASK etc, should go.
> 
> 2. The vlan device should not be marked as up when it
> is registered.  Couldn't it wait for the user to bring it up?
> If you want to automagically bring the device up, you need to call
> dev_open() so that all the proper notifier's get called.

This sounds good to me.

> 3. All checks for IFF_UP should be using netif_running instead.
> IFF_UP is a leftover BSDism.

That also sounds good.

> 
> Instead of:
> 
> int vlan_dev_open(struct net_device *dev)
> {
> 	if (!(VLAN_DEV_INFO(dev)->real_dev->flags & IFF_UP))
> 		return -ENETDOWN;
> 
> 	return 0;
> }
> 
> Use:
> int vlan_dev_open(struct net_device *dev)
> {
> 	return netif_running(VLAN_DEV_INFO(dev)->real_dev) ? 0 : -ENETDOWN;
> }
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

