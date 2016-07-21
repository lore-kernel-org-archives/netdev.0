From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH] igb: fix adjusting ptp timestamps for tx/rx latency
Date: Thu, 21 Jul 2016 00:50:33 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81F3837F@ORSMSX101.amr.corp.intel.com>
References: <1468620496-7849-1-git-send-email-kshitiz.gupta@ni.com>
 <1468653825-806-1-git-send-email-kshitiz.gupta@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Kshitiz Gupta <kshitiz.gupta@ni.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Nathan Sullivan <nathan.sullivan@ni.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:54529 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751225AbcGUAue convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 20:50:34 -0400
In-Reply-To: <1468653825-806-1-git-send-email-kshitiz.gupta@ni.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Kshitiz Gupta
> Sent: Saturday, July 16, 2016 12:24 AM
> To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>; Nathan Sullivan
> <nathan.sullivan@ni.com>; Brown, Aaron F <aaron.f.brown@intel.com>
> Cc: intel-wired-lan@lists.osuosl.org; netdev@vger.kernel.org; Kshitiz Gupta
> <kshitiz.gupta@ni.com>
> Subject: [PATCH] igb: fix adjusting ptp timestamps for tx/rx latency
> 
> Fix PHY delay compensation math in igb_ptp_tx_hwtstamp() and
> igb_ptp_rx_rgtstamp. Add PHY delay compensation in
> igb_ptp_rx_pktstamp().
> 
> In the IGB driver, there are two functions that retrieve timestamps
> received by the PHY - igb_ptp_rx_rgtstamp() and igb_ptp_rx_pktstamp().
> The previous commit only changed igb_ptp_rx_rgtstamp(), and the change
> was incorrect.
> 
> There are two instances in which PHY delay compensations should be
> made:
> 
> - Before the packet transmission over the PHY, the latency between
>   when the packet is timestamped and transmission of the packets,
>   should be an add operation, but it is currently a subtract.
> 
> - After the packets are received from the PHY, the latency between
>   the receiving and timestamping of the packets should be a subtract
>   operation, but it is currently an add.
> 
> Signed-off-by: Kshitiz Gupta <kshitiz.gupta@ni.com>
> Fixes: 3f544d2 (igb: adjust ptp timestamps for tx/rx latency)
> ---
>  drivers/net/ethernet/intel/igb/igb_ptp.c | 26 +++++++++++++++++++++++---
>  1 file changed, 23 insertions(+), 3 deletions(-)

I think I was so engrossed in checking the values for 10 / 100 / 1000 delays that I completely missed the reversed add / subtract when looking at 3f544d2.  Thanks for catching that.
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
