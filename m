From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/3] drivers/net: Convert compare_ether_addr to
 ether_addr_equal
Date: Thu, 10 May 2012 09:11:28 -0700
Message-ID: <1336666288.22495.14.camel@joe2Laptop>
References: <cover.1336618707.git.joe@perches.com>
	 <7c9881a67c52c2f218480b6742155b6d6928122d.1336618708.git.joe@perches.com>
	 <20120510173201.16131du3cg90nybo@www.81.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:36442 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752480Ab2EJQLa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2012 12:11:30 -0400
In-Reply-To: <20120510173201.16131du3cg90nybo@www.81.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(cc's trimmed)

On Thu, 2012-05-10 at 17:32 +0300, Jussi Kivilinna wrote:
> Quoting Joe Perches <joe@perches.com>:
> > Use the new bool function ether_addr_equal to add
> > some clarity and reduce the likelihood for misuse
> > of compare_ether_addr for sorting.
[]
> > diff --git a/drivers/net/wireless/rndis_wlan.c
[]
> > @@ -2139,7 +2139,7 @@ resize_buf:
> >  	while (check_bssid_list_item(bssid, bssid_len, buf, len)) {
> >  		if (rndis_bss_info_update(usbdev, bssid) && match_bssid &&
> >  		    matched) {
> > -			if (compare_ether_addr(bssid->mac, match_bssid))
> > +			if (!ether_addr_equal(bssid->mac, match_bssid))
> 
> While reviewing this, noticed that above original code is wrong. It  
> should be !compare_ether_addr. So do I push patch fixing this through  
> wireless-testing althought it will later cause conflict with this patch?
> 
> -Jussi
> 
> >  				*matched = true;
> >  		}
> >

Up to John.

Here's the patch I would send against net-next
updating the test and the style a little.

diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index dcf0e7e..29cccc5 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -2137,11 +2137,10 @@ resize_buf:
 	 * received 'num_items' and walking through full bssid buffer instead.
 	 */
 	while (check_bssid_list_item(bssid, bssid_len, buf, len)) {
-		if (rndis_bss_info_update(usbdev, bssid) && match_bssid &&
-		    matched) {
-			if (!ether_addr_equal(bssid->mac, match_bssid))
-				*matched = true;
-		}
+		if (rndis_bss_info_update(usbdev, bssid) &&
+		    match_bssid && matched &&
+		    ether_addr_equal(bssid->mac, match_bssid))
+			*matched = true;
 
 		real_count++;
 		bssid = next_bssid_list_item(bssid, &bssid_len, buf, len);
