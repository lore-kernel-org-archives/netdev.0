From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 4/6] 6lowpan: fix some checkpatch issues
Date: Fri, 21 Feb 2014 08:58:57 -0800
Message-ID: <1393001937.2594.18.camel@joe-AO722>
References: <1392995711-19563-1-git-send-email-alex.aring@gmail.com>
	 <1392995711-19563-5-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	davem@davemloft.net, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, martin.townsend@xsilon.com
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0077.hostedemail.com ([216.40.44.77]:57816 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932849AbaBUQ7C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 11:59:02 -0500
In-Reply-To: <1392995711-19563-5-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-02-21 at 16:15 +0100, Alexander Aring wrote:
> diff --git a/net/ieee802154/6lowpan_rtnl.c b/net/ieee802154/6lowpan_rtnl.c
[]
> @@ -484,8 +475,8 @@ lowpan_skb_fragmentation(struct sk_buff *skb, struct net_device *dev)
>  		err = lowpan_fragment_xmit(skb, head, header_length, len,
>  					   offset, LOWPAN_DISPATCH_FRAGN);
>  		if (err) {
> -			pr_debug("%s unable to send a subsequent FRAGN packet "
> -				 "(tag: %d, offset: %d", __func__, tag, offset);
> +			pr_debug("%s unable to send a FRAGN packet.", __func__);
> +			pr_debug("tag: %d, offset: %d", tag, offset);

No need for 2 pr_debug statements.

Better to coalesce the format pieces into a single string
adding the close parenthesis and a terminating newline.

			pr_debug("%s: unable to send a subsequent FRAGN packet "(tag: %d, offset: %d)\n",
				 __func__, tag, offset);
