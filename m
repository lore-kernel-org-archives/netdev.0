From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: Re: [PATCH 1/3] drivers/net: Convert compare_ether_addr to
 ether_addr_equal
Date: Thu, 31 May 2012 15:01:24 +0300
Message-ID: <20120531150124.119853l3a0cbvj40@www.81.fi>
References: <7c9881a67c52c2f218480b6742155b6d6928122d.1336618708.git.joe@perches.com>
 <20120510173201.16131du3cg90nybo@www.81.fi>
 <1336666288.22495.14.camel@joe2Laptop>
 <20120510.123353.1458740731067514606.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=ISO-8859-1;
 DelSp="Yes";
 format="flowed"
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120510.123353.1458740731067514606.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting David Miller <davem@davemloft.net>:

> From: Joe Perches <joe@perches.com>
> Date: Thu, 10 May 2012 09:11:28 -0700
>
>> (cc's trimmed)
>>
>> On Thu, 2012-05-10 at 17:32 +0300, Jussi Kivilinna wrote:
>>> Quoting Joe Perches <joe@perches.com>:
>>> > Use the new bool function ether_addr_equal to add
>>> > some clarity and reduce the likelihood for misuse
>>> > of compare_ether_addr for sorting.
>> []
>>> > diff --git a/drivers/net/wireless/rndis_wlan.c
>> []
>>> > @@ -2139,7 +2139,7 @@ resize_buf:
>>> >  	while (check_bssid_list_item(bssid, bssid_len, buf, len)) {
>>> >  		if (rndis_bss_info_update(usbdev, bssid) && match_bssid &&
>>> >  		    matched) {
>>> > -			if (compare_ether_addr(bssid->mac, match_bssid))
>>> > +			if (!ether_addr_equal(bssid->mac, match_bssid))
>>>
>>> While reviewing this, noticed that above original code is wrong. It
>>> should be !compare_ether_addr. So do I push patch fixing this through
>>> wireless-testing althought it will later cause conflict with this patch?
>>>
>>> -Jussi
>>>
>>> >  				*matched = true;
>>> >  		}
>>> >
>>
>> Up to John.
>>
>> Here's the patch I would send against net-next
>> updating the test and the style a little.
>
> I think in this specific case it's better to push this one directly
> through net-next.  But yes, it's up to John.
>

It's been some time now, and I think it's ok to wait until  
wireless-testing has
this patch merged and then fix it there.

That line/compare was added as response to hardware bug, where bssid-list does
not contain BSSID and other information of currently connected AP  
(spec insists
that device must provide this information in the list when connected). Lack
bssid-data on current connection then causes WARN_ON somewhere in cfg80211.
Workaround was to check if bssid-list returns current bssid and if it  
does not,
manually construct bssid information in other ways. And this  
workaround worked,
with inverse check. Which must mean that when hardware is experiencing the
problem, it's actually returning empty bssid-list.

Inverse check causes workaround be activated when bssid-list returns only
entry, currently connected BSSID. That does not cause problems in itself, just
slightly more inaccurate information in scan-list.

-Jussi
