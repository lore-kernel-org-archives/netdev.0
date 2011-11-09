From: Maris Paupe <marisp@mt.lv>
Subject: Re: [PATCH]  flow_cache_flush soft lockup with heavy ipsec traffic
Date: Wed, 09 Nov 2011 16:41:04 +0200
Message-ID: <4EBA9100.3010202@mt.lv>
References: <4EBA7038.4050702@mt.lv> <1320844564.3916.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20111109134348.GD10138@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bute.mt.lv ([159.148.172.195]:33282 "EHLO bute.mt.lv"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753679Ab1KIOlL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Nov 2011 09:41:11 -0500
In-Reply-To: <20111109134348.GD10138@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think i found the correct fix for my problem here 
http://patchwork.ozlabs.org/patch/114330/
The scenario sounds the same, i will test it, thanks.


On 11/09/11 15:43, Steffen Klassert wrote:
> On Wed, Nov 09, 2011 at 02:16:04PM +0100, Eric Dumazet wrote:
>>
>> Sorry, I dont understand your patch.
>>
>> BH are disabled by the spin_lock_bh() call.
>>
>> Once flow_cache_entry are in garbage list, nothing but garbage collector
>> can access them. I see no possible deadlock. Or there is a bug somewhere
>> and your patch avoid it.
>>
>> Whole point of using a work queue to perform garbage collect was to not
>> hold BH too long (allowing sotirq to process incoming packets), so you
>> basically remove what was done in commit 8e4795605d.
>>
>
> I guess this tries to address a problem that was already discussed here:
>
> http://patchwork.ozlabs.org/patch/116457/
>
