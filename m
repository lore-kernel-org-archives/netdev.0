From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 3/6] sky2: reorganize chip revision features
Date: Wed, 19 Sep 2007 16:27:26 -0700
Message-ID: <46F1B05E.9010209@hp.com>
References: <20070919223641.860189786@linux-foundation.org> <20070919223746.612168285@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzk <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:48597 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751199AbXISX16 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 19:27:58 -0400
In-Reply-To: <20070919223746.612168285@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> This patch should cause no functional changes in driver behaviour.
> There are (too) many revisions of the Yukon 2 chip now. Instead of
> adding more conditionals based on chip revision; rerganize into a
> set of feature flags so adding new versions is less problematic.


> @@ -311,10 +310,8 @@ static void sky2_phy_init(struct sky2_hw
>  	struct sky2_port *sky2 = netdev_priv(hw->dev[port]);
>  	u16 ctrl, ct1000, adv, pg, ledctrl, ledover, reg;
>  
> -	if (sky2->autoneg == AUTONEG_ENABLE
> -	    && !(hw->chip_id == CHIP_ID_YUKON_XL
> -		 || hw->chip_id == CHIP_ID_YUKON_EC_U
> -		 || hw->chip_id == CHIP_ID_YUKON_EX)) {
> +	if (sky2->autoneg == AUTONEG_ENABLE &&
> +	    !(hw->flags & SKY2_HW_NEWER_PHY)) {

Will something like SKY2_HW_NEWER_PHY age well?  Won't that leave things 
vulnerable to needing a SKY2_HW_NEWER_NEWER_PHY?

> @@ -1436,13 +1428,15 @@ static int sky2_xmit_frame(struct sk_buf
>  	/* Check for TCP Segmentation Offload */
>  	mss = skb_shinfo(skb)->gso_size;
>  	if (mss != 0) {
> -		if (hw->chip_id != CHIP_ID_YUKON_EX)
> +
> +		if (!(hw->flags & SKY2_HW_NEW_LE))
>  			mss += ETH_HLEN + ip_hdrlen(skb) + tcp_hdrlen(skb);

Might the same thing apply with SKY2_HW_NEW_LE?

rick jones
