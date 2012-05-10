From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] drivers/net: Convert compare_ether_addr to
 ether_addr_equal
Date: Thu, 10 May 2012 12:33:53 -0400 (EDT)
Message-ID: <20120510.123353.1458740731067514606.davem@davemloft.net>
References: <7c9881a67c52c2f218480b6742155b6d6928122d.1336618708.git.joe@perches.com>
	<20120510173201.16131du3cg90nybo@www.81.fi>
	<1336666288.22495.14.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jussi.kivilinna@mbnet.fi, linville@tuxdriver.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1336666288.22495.14.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Thu, 10 May 2012 09:11:28 -0700

> (cc's trimmed)
> 
> On Thu, 2012-05-10 at 17:32 +0300, Jussi Kivilinna wrote:
>> Quoting Joe Perches <joe@perches.com>:
>> > Use the new bool function ether_addr_equal to add
>> > some clarity and reduce the likelihood for misuse
>> > of compare_ether_addr for sorting.
> []
>> > diff --git a/drivers/net/wireless/rndis_wlan.c
> []
>> > @@ -2139,7 +2139,7 @@ resize_buf:
>> >  	while (check_bssid_list_item(bssid, bssid_len, buf, len)) {
>> >  		if (rndis_bss_info_update(usbdev, bssid) && match_bssid &&
>> >  		    matched) {
>> > -			if (compare_ether_addr(bssid->mac, match_bssid))
>> > +			if (!ether_addr_equal(bssid->mac, match_bssid))
>> 
>> While reviewing this, noticed that above original code is wrong. It  
>> should be !compare_ether_addr. So do I push patch fixing this through  
>> wireless-testing althought it will later cause conflict with this patch?
>> 
>> -Jussi
>> 
>> >  				*matched = true;
>> >  		}
>> >
> 
> Up to John.
> 
> Here's the patch I would send against net-next
> updating the test and the style a little.

I think in this specific case it's better to push this one directly
through net-next.  But yes, it's up to John.
