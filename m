From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e1000e: New pci-express e1000 driver (currently for ICH9
 devices only)
Date: Mon, 06 Aug 2007 21:25:05 -0700
Message-ID: <46B7F421.1020509@intel.com>
References: <46B79934.8010405@intel.com> <p737io8caai.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	NetDev <netdev@vger.kernel.org>, Andrew Morton <akpm@osdl.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24573 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751014AbXHGEZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2007 00:25:08 -0400
In-Reply-To: <p737io8caai.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> "Kok, Auke" <auke-jan.h.kok@intel.com> writes:
> 
>> All,
>>
>> Another update on e1000e. Many thanks to Jeff for helping out and
>> getting this going forward. The driver is unfortunately still too
>> large to post, so please use the URL's below to review:
> 
> Just some things I noticed; no comprehensive review

thanks, quick reply to one of the issues below, others I'll take into account 
and look into deeper.


> +       mod_timer(&adapter->blink_timer, jiffies + E1000_ID_INTERVAL);
> Should use round_jiffies to avoid wakeups

actually, not here - we don't want the led to blink unreliably. If the timer 
gets stalled beyond 1/2 a second and is irregular, you'll never be able to 
identify the proper adapter port in you data center.

remember, this is only used once the user invokes 'ethtool -p'


Auke
