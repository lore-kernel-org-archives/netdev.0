From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: [PATCH] e1000e: New pci-express e1000 driver (currently for ICH9
 devices only)
Date: Mon, 06 Aug 2007 22:37:38 -0700
Message-ID: <46B80522.70202@linux.intel.com>
References: <46B79934.8010405@intel.com> <p737io8caai.fsf@bingen.suse.de> <46B7F421.1020509@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, Jeff Garzik <jgarzik@pobox.com>,
	NetDev <netdev@vger.kernel.org>, Andrew Morton <akpm@osdl.org>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:4342 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753502AbXHGFj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 01:39:57 -0400
In-Reply-To: <46B7F421.1020509@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Andi Kleen wrote:
>> "Kok, Auke" <auke-jan.h.kok@intel.com> writes:
>>
>>> All,
>>>
>>> Another update on e1000e. Many thanks to Jeff for helping out and
>>> getting this going forward. The driver is unfortunately still too
>>> large to post, so please use the URL's below to review:
>>
>> Just some things I noticed; no comprehensive review
> 
> thanks, quick reply to one of the issues below, others I'll take into 
> account and look into deeper.
> 
> 
>> +       mod_timer(&adapter->blink_timer, jiffies + E1000_ID_INTERVAL);
>> Should use round_jiffies to avoid wakeups
> 
> actually, not here - we don't want the led to blink unreliably. If the 
> timer gets stalled beyond 1/2 a second and is irregular, you'll never be 
> able to identify the proper adapter port in you data center.
> 
> remember, this is only used once the user invokes 'ethtool -p'

round_jiffies is regular, except for the first time..

(it's a whole-second only though)
