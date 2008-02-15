From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 2.6.25] igb: fix legacy mode irq issue
Date: Fri, 15 Feb 2008 08:18:18 -0800
Message-ID: <47B5BB4A.7080808@intel.com>
References: <20080214031920.GI856@gospo.usersys.redhat.com> <47B5B5BA.9020807@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:36313 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752771AbYBOQZ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2008 11:25:28 -0500
In-Reply-To: <47B5B5BA.9020807@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> Andy Gospodarek wrote:
>> I booted an igb kernel with the option pci=nomsi and instantly noticed
>> that interrupts no longer worked on my igb device.  I took a look at the
>> interrupt initialization and quickly discovered a comment stating:
>>
>> "DO NOT USE EIAME or IAME in legacy mode"
>>
>> It seemed a bit odd that bits to enable IAM were being set in legacy
>> interrupt mode, so I dropped out the following parts and interrupts
>> began working fine again.
>>
>> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
>> ---
>>
>>  igb_main.c |    3 ---
>>  1 files changed, 3 deletions(-)
>>
>> diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
>> index f3c144d..be5da09 100644
>> --- a/drivers/net/igb/igb_main.c
>> +++ b/drivers/net/igb/igb_main.c
>> @@ -472,9 +471,6 @@ static int igb_request_irq(struct igb_adapter
>> *adapter)
>>          goto request_done;
>>      }
>>  
>> -    /* enable IAM, auto-mask */
>> -    wr32(E1000_IAM, IMS_ENABLE_MASK);
>> -
> 
> ACK from Auke?  (apologies if I missed it...)

you did not miss it yet :)

So, in principle this patch might leave interrupts enabled way too long.
Unfortunately the code to enable IAM is way too complex for upstream-fixes so I
don't want to push that into 2.6.25. I'm scrambling right now to figure out if
this patch doesn't create endless interrupts from the hardware.

Once I'm happy with that answer I'll push/ack it

Auke


