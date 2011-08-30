From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 2/5] qlcnic: Change debug messages in loopback
 path
Date: Mon, 29 Aug 2011 20:00:37 -0700
Message-ID: <1314673237.6852.53.camel@Joe-Laptop>
References: <1314658231-30735-1-git-send-email-sony.chacko@qlogic.com>
	 <1314658231-30735-2-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish chopra <Manish.Chopra@qlogic.com>
To: Sony Chacko <sony.chacko@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:56956 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751127Ab1H3DAj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Aug 2011 23:00:39 -0400
In-Reply-To: <1314658231-30735-2-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-08-29 at 15:50 -0700, Sony Chacko wrote:
> From: Manish chopra <Manish.Chopra@qlogic.com>
> Added more debug messages while loopback test in progress
[]
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
[]
> @@ -736,13 +736,18 @@ static int qlcnic_do_lb_test(struct qlcnic_adapter *adapter)
[]
> +		if (mode != QLCNIC_ILB_MODE) {
> +			dev_warn(&adapter->pdev->dev,
> +				"WARNING: Please make sure external"
> +				"loopback connector is plugged in\n");

It's better to avoid splitting format strings.
This emits "externalloopback" instead of "external loopback".

> -static void dump_skb(struct sk_buff *skb)
> +static void dump_skb(struct sk_buff *skb, struct qlcnic_adapter *adapter)
>  {
>  	int i;
>  	unsigned char *data = skb->data;
>  
>  	printk(KERN_INFO "\n");
>  	for (i = 0; i < skb->len; i++) {
> -		printk(KERN_INFO "%02x ", data[i]);
> +		QLCDB(adapter, DRV, "%02x ", data[i]);

print_hex_dump
