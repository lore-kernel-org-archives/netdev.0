From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 1/3] drivers/net: Convert compare_ether_addr to
 ether_addr_equal
Date: Thu, 31 May 2012 11:49:13 -0700
Message-ID: <1338490153.5861.5.camel@joe2Laptop>
References: <7c9881a67c52c2f218480b6742155b6d6928122d.1336618708.git.joe@perches.com>
	 <20120510173201.16131du3cg90nybo@www.81.fi>
	 <1336666288.22495.14.camel@joe2Laptop>
	 <20120510.123353.1458740731067514606.davem@davemloft.net>
	 <20120531150124.119853l3a0cbvj40@www.81.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120531150124.119853l3a0cbvj40-tzMWlZeEOor1KXRcyAk9cg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-05-31 at 15:01 +0300, Jussi Kivilinna wrote:
> Quoting David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>:
> > From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
> > Date: Thu, 10 May 2012 09:11:28 -0700
> >> On Thu, 2012-05-10 at 17:32 +0300, Jussi Kivilinna wrote:
> >>> Quoting Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>:
> >>> > Use the new bool function ether_addr_equal to add
> >>> > some clarity and reduce the likelihood for misuse
> >>> > of compare_ether_addr for sorting.
> >> []
> >>> > diff --git a/drivers/net/wireless/rndis_wlan.c
> >> []
> >>> > @@ -2139,7 +2139,7 @@ resize_buf:
> >>> >  	while (check_bssid_list_item(bssid, bssid_len, buf, len)) {
> >>> >  		if (rndis_bss_info_update(usbdev, bssid) && match_bssid &&
> >>> >  		    matched) {
> >>> > -			if (compare_ether_addr(bssid->mac, match_bssid))
> >>> > +			if (!ether_addr_equal(bssid->mac, match_bssid))
> >>>
> >>> While reviewing this, noticed that above original code is wrong. It
> >>> should be !compare_ether_addr. So do I push patch fixing this through
> >>> wireless-testing althought it will later cause conflict with this patch?
[]
> That line/compare was added as response to hardware bug, where bssid-list does
> not contain BSSID and other information of currently connected AP  
> (spec insists
> that device must provide this information in the list when connected). Lack
> bssid-data on current connection then causes WARN_ON somewhere in cfg80211.
> Workaround was to check if bssid-list returns current bssid and if it  
> does not,
> manually construct bssid information in other ways. And this  
> workaround worked,
> with inverse check. Which must mean that when hardware is experiencing the
> problem, it's actually returning empty bssid-list.
> 
> Inverse check causes workaround be activated when bssid-list returns only
> entry, currently connected BSSID. That does not cause problems in itself, just
> slightly more inaccurate information in scan-list.

Thanks.

That information would be useful in the
eventual commit message.

cheers, Joe

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
