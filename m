From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next 4/6] net: hip04: Don't free the tx skb when the buffer is not ready for xmit
Date: Wed, 15 Apr 2015 16:19:59 +0200
Message-ID: <2218546.M1hzu1bzfh@wuerfel>
References: <1429101008-9464-1-git-send-email-dingtianhong@huawei.com> <1429101008-9464-5-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, grant.likely@linaro.org,
	sergei.shtylyov@cogentembedded.com,
	linux-arm-kernel@lists.infradead.org, eric.dumazet@gmail.com,
	zhangfei.gao@linaro.org, joe@perches.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux@arm.linux.org.uk
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:59318 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753450AbbDOOUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 10:20:10 -0400
In-Reply-To: <1429101008-9464-5-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 15 April 2015 20:30:06 Ding Tianhong wrote:
> @@ -489,6 +487,8 @@ static int hip04_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>  
>         /* Ensure tx_head update visible to tx reclaim */
>         smp_wmb();
> +       count++;
> +       priv->tx_head = TX_NEXT(tx_head);
>  
> 

Something is wrong here, the comment does not match the code any more, because
the smp_wmb() won't actually make the tx_head update visible.

	Arnd
