From: Chaitanya Lala <clala@riverbed.com>
Subject: Re: [net-next PATCH 1/1] e1000e: Expose MDI-X state via sysfs
Date: Wed, 20 May 2009 10:14:27 -0700
Message-ID: <4A143A73.40504@riverbed.com>
References: <20090519210553.GA2491@clala-laptop> <9929d2390905191455i3103ead3p13c0b4c51be29b5@mail.gmail.com> <4A133126.10608@riverbed.com> <F169D4F5E1F1974DBFAFABF47F60C10A335276C4@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"jgarzik@redhat.com" <jgarzik@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.riverbed.com ([206.169.144.7]:23892 "EHLO
	smtp2.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754861AbZETRN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 13:13:56 -0400
In-Reply-To: <F169D4F5E1F1974DBFAFABF47F60C10A335276C4@orsmsx507.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brandeburg, Jesse wrote:
> Chaitanya Lala wrote:
>   
>> Jeff Kirsher wrote:
>>     
>>> On Tue, May 19, 2009 at 2:05 PM, Chaitanya Lala <clala@riverbed.com>
>>> wrote:
>>>
>>>       
>>>> While debugging network connectivity problems, it is often helpful
>>>> to report the MDI-X state. The is_mdix variable holds the current
>>>> state which we expose on a per-interface basis as a sysfs attribute.
>>>> We use sysfs over methods such as netlink due to the convenience of
>>>> reading a file (using the cat command) as opposed to connecting to a
>>>> netlink socket. If we use a fiber PHY then is_mdix will always be
>>>> zero
>>>> as the mdi-x feature only applies to copper PHYs.
>>>>
>>>> Signed-off-by: Chaitanya Lala <clala@riverbed.com>
>>>> Signed-off-by: Arthur Jones <ajones@riverbed.com>
>>>> ---
>>>>
>>>>         
>>> NAK.  We do not want to be adding sysfs entries for every little
>>> piece
>>> of information in the driver.  Instead, I would suggest looking at
>>> enhancing existing tools like ethtool to get that sort of information
>>> in a more generic way which is not driver specific.
>>>
>>>
>>>       
>> The MDI-X setting is a non-standard piece of information & every
>> driver may or may-not have it. But still this is an important
>> de-bugging tool & we would want to use this information from the
>> drivers that do provide this facility.  So what would be a standard
>> way to do this via something like ethtool ? Any pointers would be
>> helpful.
>>     
>
> how about (psuedo diff)
>
>         Supported ports: [ TP ]
>         Supported link modes:   10baseT/Half 10baseT/Full
>                                 100baseT/Half 100baseT/Full
>                                 1000baseT/Full
>         Supports auto-negotiation: Yes
>         Advertised link modes:  10baseT/Half 10baseT/Full
>                                 100baseT/Half 100baseT/Full
>                                 1000baseT/Full
>         Advertised auto-negotiation: Yes
>         Speed: 1000Mb/s
>         Duplex: Full
>         Port: Twisted Pair
>         PHYAD: 1
>         Transceiver: internal
>         Auto-negotiation: on
> +       MDI-X: on
>         Supports Wake-on: umbg
>         Wake-on: g
>         Current message level: 0x00000003 (3)
>         Link detected: yes
>
> where possible MDI-X values are (on|off)
>
> This way drivers can optionally implement the feature in their 
> get_settings and set_settings handlers.
>   
Thanks for the possible solution. I will work on it and get back.
Thanks,
Chaitanya
