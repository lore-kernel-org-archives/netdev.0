From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH v2.6.26] gianfar: Determine TBIPA value dynamically
Date: Mon, 14 Apr 2008 11:55:11 -0500
Message-ID: <FE7FE117-D88D-4109-AAE3-11597C1AD6F1@freescale.com>
References: <1207870471-3601-1-git-send-email-afleming@freescale.com> <20080411154914.GA19036@windriver.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:47213 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758863AbYDNQzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 12:55:24 -0400
In-Reply-To: <20080411154914.GA19036@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Apr 11, 2008, at 10:49, Paul Gortmaker wrote:

> In message: [PATCH v2.6.26] gianfar: Determine TBIPA value dynamically
> on 10/04/2008 Andy Fleming wrote:
>
>> TBIPA needs to be set to a value (on connected MDIO buses) that  
>> doesn't
>> conflict with PHYs on the bus.  By hardcoding it to 0x1f, we were  
>> preventing
>> boards with PHYs at 0x1f from working properly.  Instead, scan the  
>> bus when
>> it comes up, and find an address that doesn't have a PHY on it.   
>> The TBI PHY
>> configuration code then trusts that the value in TBIPA is either  
>> safe, or
>> doesn't matter (ie - it's not an active bus with other PHYs).
>>
>> Signed-off-by: Andy Fleming <afleming@freescale.com>
>> ---
>>
>> I think this should go in, but I'd like to see some testing first.   
>> I don't
>> have hardware which is affected by this.  I've only confirmed that  
>> it doesn't
>> break current hardware.
>
> I've tested on a board with the primary PHY at 0x1f, and it seems OK.
>
> I'f I'm understanding this correctly, you are explicitly setting TBIPA
> to zero, doing a bus walk but excluding zero, and then assigning the
> found free address, which re-opens zero to be used by a real PHY.


Right.  It's a somewhat lazy scan of the bus.  I'm assuming, here,  
that there will be at least one non-zero address that has no PHY on it.


>
>
> I've made some changes to what you'd sent out, those being:
> 	-changed the "if (i < 0) return -EBUSY to "i == 0"
> 	-remove the now unused TBIPA_VALUE define
> 	-remove the prototypes from gianfar.c now that you've
> 	 added them into gianfar.h
> 	-factor out the code to read the PHY ID so we don't have
> 	 it duplicated in two places.


Excellent.  Print it!  :)

Could you send out the two patches as two separate emails, and add my  
Acked-by: Andy Fleming <afleming@freescale.com> to the first one?  You  
should also change the subject for the first patch so that it has  
[PATCH v2.6.26].

Andy
