From: Jean-Mickael Guerin <jean-mickael.guerin@6wind.com>
Subject: Re: drivers/net/wireless/d80211: Check configuration type in hw->config_interface.
Date: Thu, 20 Jul 2006 00:05:37 +0200
Message-ID: <44BEACB1.70900@6wind.com>
References: <44BE958C.4030401@6wind.com> <a32f33a40607191413k5cab2766u4fc4ee8b4f6c4088@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:53517 "EHLO
	proxy.6wind.com") by vger.kernel.org with ESMTP id S932486AbWGSWFl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jul 2006 18:05:41 -0400
To: Ivo Van Doorn <ivdoorn@gmail.com>
In-Reply-To: <a32f33a40607191413k5cab2766u4fc4ee8b4f6c4088@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>
> When submitting a patch, please state what drivers you are really 
> changing,
> your mail subject suggested a change to the dscape stack itself.
> Since I look at those patches at an irregular basis, while I am always
> checking for rt2x00 related patches I could have missed this one.
> Especially when you don't CC the driver maintainers about the patch
> for their drivers.

> Also I think most people would prefer if you split up patches when it
> affects multiple drivers,
> in this case rt2x00 and adm8211.
what I meant with this title is this patch is for all d80211-based 
current drivers of Linville's wireless-dev,
but I see your point...

>
>> diff --git a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
>> b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
>> index 946cf86..1d45851 100644
>> --- a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
>> +++ b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
>> @@ -1877,7 +1877,9 @@ rt2400pci_config_interface(struct net_de
>>      if (rt2x00pci->type == IEEE80211_IF_TYPE_MNTR)
>>          return 0;
>>
>> -    rt2400pci_config_bssid(rt2x00pci, conf->bssid);
>> +    if (conf->type == IEEE80211_IF_TYPE_STA ||
>> +        conf->type == IEEE80211_IF_TYPE_IBSS)
>> +        rt2400pci_config_bssid(rt2x00pci, conf->bssid);
>
> Should rt2400pci_config_bssid not simply run a check to see if the
> bssid argument is valid?
> This would prevent the risk of having a similar problem when the
> function is called from somewhere else as well.
>
I was thinking a function named xxx_config_bssid() assumes a valid bssid 
pointer,
- I would even add BUG_ON(conf->bssid==NULL) in xxx_config_bssid().
And hw->interface already already some tests with conf->type.
And net/d80211 uses same kind of test before setting conf->bssid.

anyway I don't mind you make the patch the other way.
> Same comment applies for rt2500pci and rt61pci.
>
> Any particular reason why you applied this change to PCI drivers in
> rt2x00 only and not to the USB drivers?
>
likely because I have only a pci card :-)
USB drivers needs same change too.

Thanks,

Jean-Mickael
