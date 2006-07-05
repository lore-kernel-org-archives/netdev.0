From: Ben Greear <greearb@candelatech.com>
Subject: Re: [VLAN]: translate IF_OPER_DORMANT to netif_dormant_on()
Date: Wed, 05 Jul 2006 14:17:00 -0700
Message-ID: <44AC2C4C.9060001@candelatech.com>
References: <200603211829.k2LITMNR029085@hera.kernel.org> <44AA3DD3.1090106@trash.net> <200607052057.05526.stefan@loplof.de> <44AC2857.5030706@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stefan Rompf <stefan@loplof.de>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:63953 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S964989AbWGEVRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2006 17:17:13 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44AC2857.5030706@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Stefan Rompf wrote:
> 
>>Am Dienstag 04 Juli 2006 12:07 schrieb Patrick McHardy:
>>
>>
>>
>>>>-	new_dev->state = real_dev->state & VLAN_LINK_STATE_MASK;
>>>>+	new_dev->state = real_dev->state & ~(1<<__LINK_STATE_START);

This change looks funky because it ignores the link state mask.

>>Anyway, is it good to propagate __LINK_STATE_PRESENT then? The same situation 
>>here, add a VLAN while the main interface is "not present", and you are out. 
>>Can you try to revert the quoted part of my patch, I'll rethink which flags 
>>should be copied on device creation.
> 
> 
> I tried both adding LINK_STATE_XOFF to the negated flags and using
> VLAN_LINK_STATE_MASK, both as expected solve the problem for me.
> I have to admit I was wondering about LINK_STATE_PRESENT as well
> (was going to complain about that too until I noticed it is also
> set in VLAN_LINK_STATE_MASK). Maybe Ben can tell us the idea behind
> this?

I believe this link-state logic was added by someone else.  I'm not
sure exactly what these flags are supposed to do, so I am not sure if they
should be propagated to the VLAN or not.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

