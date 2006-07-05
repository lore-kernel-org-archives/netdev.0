From: Patrick McHardy <kaber@trash.net>
Subject: Re: [VLAN]: translate IF_OPER_DORMANT to netif_dormant_on()
Date: Wed, 05 Jul 2006 23:00:07 +0200
Message-ID: <44AC2857.5030706@trash.net>
References: <200603211829.k2LITMNR029085@hera.kernel.org> <44AA3DD3.1090106@trash.net> <200607052057.05526.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:4018 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S965020AbWGEVAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2006 17:00:10 -0400
To: Stefan Rompf <stefan@loplof.de>
In-Reply-To: <200607052057.05526.stefan@loplof.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stefan Rompf wrote:
> Am Dienstag 04 Juli 2006 12:07 schrieb Patrick McHardy:
> 
> 
>>>-	new_dev->state = real_dev->state & VLAN_LINK_STATE_MASK;
>>>+	new_dev->state = real_dev->state & ~(1<<__LINK_STATE_START);
> 
> 
>>This introduced a regression by propagating the __LINK_STATE_XOFF flag,
>>when the queue of the underlying device is stopped it will be stopped
>>for the VLAN device too and never be woken up. Since you changed
>>VLAN_LINK_STATE_MASK, I assume the intention was to just add
>>__LINK_STATE_DORMANT to the propagated flags and keep using it here?
> 
> 
> Hm, I did not hit that bug during tests, even though starfire calls 
> netif_stop_queue() on close. But I don't remember whether I tested added 
> VLANs while the main interface was ifconfig'ed down.

It hits me whenever I boot with sky2, it seems to need a while before
a carrier is detected.

> Anyway, is it good to propagate __LINK_STATE_PRESENT then? The same situation 
> here, add a VLAN while the main interface is "not present", and you are out. 
> Can you try to revert the quoted part of my patch, I'll rethink which flags 
> should be copied on device creation.

I tried both adding LINK_STATE_XOFF to the negated flags and using
VLAN_LINK_STATE_MASK, both as expected solve the problem for me.
I have to admit I was wondering about LINK_STATE_PRESENT as well
(was going to complain about that too until I noticed it is also
set in VLAN_LINK_STATE_MASK). Maybe Ben can tell us the idea behind
this?

