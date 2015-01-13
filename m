From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/8] net: dsa: make module builds work
Date: Tue, 13 Jan 2015 14:27:19 -0800
Message-ID: <54B59BC7.10405@gmail.com>
References: <1421099866-3184-1-git-send-email-f.fainelli@gmail.com>	<1421099866-3184-3-git-send-email-f.fainelli@gmail.com> <20150113.163853.1503595006355422756.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, buytenh@wantstofly.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:44057 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753933AbbAMW10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 17:27:26 -0500
Received: by mail-pd0-f181.google.com with SMTP id v10so5786049pde.12
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 14:27:25 -0800 (PST)
In-Reply-To: <20150113.163853.1503595006355422756.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/01/15 13:38, David Miller wrote:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Mon, 12 Jan 2015 13:57:40 -0800
> 
>> Building any DSA driver as a module will work from a compilation/linking
>> perspective, but the resulting modules produced are not functional.
>>
>> Any DSA driver references register_switch_driver and
>> unregister_switch_driver which are provided by net/dsa/dsa.c, so loading
>> any of these modules prior to dsa_core.ko being loaded will faill.
>>
>> Unfortunately, loading dsa_core.ko will make us call dsa_switch_probe()
>> which will find no DSA switch driver and return an error so we are stuck
>> there because there is no switch driver available. So this is getting us
>> nowhere.
>>
>> This patch introduces a separate module, named dsa_lib which contains
>> register_switch_driver, unregister_switch_driver and dsa_switch_probe
>> (to avoid exposing the list and mutex used for walking switch drivers),
>> such that the following can be done:
>>
>> - load dsa_lib
>> - load the dsa switch driver, e.g: mv88e6060, bcm_sf2
>> - load the dsa_core module
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> This looks worse to me.
> 
> Really, the match table and probing should not be in dsa_core at all.
> 
> It should only be done in individual drivers.

Right, I guess enough procrastination on my side is enough, time to get
this plan submitted: http://marc.info/?t=141038714600002&r=1&w=2.
-- 
Florian
