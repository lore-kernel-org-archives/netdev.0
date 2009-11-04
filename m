From: Naohiro Ooiwa <nooiwa@miraclelinux.com>
Subject: Re: [PATCH] e1000: the power down when running ifdown command
Date: Wed, 04 Nov 2009 19:23:43 +0900
Message-ID: <4AF1562F.8010401@miraclelinux.com>
References: <4AEC05E8.40600@miraclelinux.com> <20091031105838.0d4b59a2@nehalam> <4AEE35D2.4000503@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com,
	davem@davemloft.net, Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, svaidy@linux.vnet.ibm.com,
	e1000-devel@lists.sourceforge.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw.miraclelinux.com ([122.216.84.157]:31110 "EHLO
	mailgw.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753377AbZKDKXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 05:23:38 -0500
In-Reply-To: <4AEE35D2.4000503@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Naohiro Ooiwa wrote:
> Stephen Hemminger wrote:
>> On Sat, 31 Oct 2009 18:39:52 +0900
>> Naohiro Ooiwa <nooiwa@miraclelinux.com> wrote:
>>
>> Does this work with Wake On Lan? 
> 
> Yes, it works WOL.

Sorry, I made a mistake.
The WOL doesn't work when my patch applied to kernel.
I wasn't myself.

I consider the WOL and I will resent the patch.
Thank you for your point.


thanks,
Naohiro Ooiwa


> But I worry that my test is enough.
> 
> They are following:
>   - simple data transmission after ifdown;ifup.
>   - enable wol, ifup network device, system shutdown, and make sure wol work.
>   - enable wol, ifdown network device, system shutdown, and make sure wol work.
>   - while [ 0 ] ; do ifdown eth0 ; ifup eth0 ; done
>   - while [ 0 ] ; do modprobe e1000 ; rmmod e1000 ; done
> 
> 
>> @@ -1265,6 +1287,7 @@ static int e1000_open(struct net_device *netdev)
>>  		goto err_setup_rx;
>>
>>  	e1000_power_up_phy(adapter);
>> +	e1000_reset(adapter);
>>
>>  	adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
>>  	if ((hw->mng_cookie.status &
> 
> This code fix problem that e1000 driver doesn't work to auto-negotiation
> once in a while.
> Maybe, the cause is that set state to D0 just before it.
> I found it by repeat of ifup and ifdown.
> 
> If you find out other points and any necessary tests from my patch,
> please tell me. I will make sure them.
> 
> Thanks you.
> Naohiro Ooiwa
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

