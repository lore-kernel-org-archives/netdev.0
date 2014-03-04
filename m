From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 08/12] r8152: support TSO
Date: Tue, 04 Mar 2014 08:11:16 -0800
Message-ID: <1393949476.26794.118.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
	 <1393934464-23675-9-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:42828 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754354AbaCDQLU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 11:11:20 -0500
In-Reply-To: <1393934464-23675-9-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-04 at 20:01 +0800, Hayes Wang wrote:

> +static u32 r8152_xmit_frags(struct r8152 *tp, struct sk_buff *skb, u8 *data)
> +{
> +	struct skb_shared_info *info = skb_shinfo(skb);
> +	unsigned int cur_frag;
> +	u32 total = skb_headlen(skb);
> +
> +	memcpy(data, skb->data, total);
> +	data += total;
> +
> +	for (cur_frag = 0; cur_frag < info->nr_frags; cur_frag++) {
> +		const skb_frag_t *frag = info->frags + cur_frag;
> +		void *addr;
> +		u32 len;
> +
> +		len = skb_frag_size(frag);
> +		addr = skb_frag_address(frag);
> +		memcpy(data, addr, len);
> +		data += len;
> +		total += len;
>  	}
> +
> +	return total;
>  }
>  

I would rather use skb_copy_bits(), because it correctly handles
kmap() case. (If a frag resides in high memory)
