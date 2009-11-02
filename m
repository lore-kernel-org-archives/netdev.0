From: Naohiro Ooiwa <nooiwa@miraclelinux.com>
Subject: Re: [PATCH] e1000: the power down when running ifdown command
Date: Mon, 02 Nov 2009 10:28:50 +0900
Message-ID: <4AEE35D2.4000503@miraclelinux.com>
References: <4AEC05E8.40600@miraclelinux.com> <20091031105838.0d4b59a2@nehalam>
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
Received: from mailgw.miraclelinux.com ([122.216.84.157]:47819 "EHLO
	mailgw.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930AbZKBB3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2009 20:29:03 -0500
In-Reply-To: <20091031105838.0d4b59a2@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Sat, 31 Oct 2009 18:39:52 +0900
> Naohiro Ooiwa <nooiwa@miraclelinux.com> wrote:
> 
>> Hi All
>>
>> I resend my patch.
>> Sorry, my previous mail lacked an explanation.
>>
>>
>> The e1000 driver doesn't let the power down when running ifdown command.
>> So, I set to the D3hot state of a PCI device at the end of e1000_close().
>>
>> With this modification, e1000 driver reduces power by ifdown.
>> It's about 6 watts when I measured a total power of one server machine
>> in my environment.
>>
>> I tested this patch. The result is good enough to me.
>>
>> Could you please check my patch ?
>> If I should have other considerations, please tell me.
>>

Hi Stephen

Thank you so much for your reply.

> Does this work with Wake On Lan? 

Yes, it works WOL.
But I worry that my test is enough.

They are following:
  - simple data transmission after ifdown;ifup.
  - enable wol, ifup network device, system shutdown, and make sure wol work.
  - enable wol, ifdown network device, system shutdown, and make sure wol work.
  - while [ 0 ] ; do ifdown eth0 ; ifup eth0 ; done
  - while [ 0 ] ; do modprobe e1000 ; rmmod e1000 ; done


> @@ -1265,6 +1287,7 @@ static int e1000_open(struct net_device *netdev)
>  		goto err_setup_rx;
>
>  	e1000_power_up_phy(adapter);
> +	e1000_reset(adapter);
>
>  	adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
>  	if ((hw->mng_cookie.status &

This code fix problem that e1000 driver doesn't work to auto-negotiation
once in a while.
Maybe, the cause is that set state to D0 just before it.
I found it by repeat of ifup and ifdown.

If you find out other points and any necessary tests from my patch,
please tell me. I will make sure them.

Thanks you.
Naohiro Ooiwa

