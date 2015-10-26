From: Toshiaki Makita <makita.toshiaki-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH v2] net: tso: add support for IPv6
Date: Mon, 26 Oct 2015 13:03:11 +0900
Message-ID: <562DA5FF.6040307@lab.ntt.co.jp>
References: <1445803107-18513-1-git-send-email-emmanuel.grumbach@intel.com>
 <1445803371-19778-1-git-send-email-emmanuel.grumbach@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1445803371-19778-1-git-send-email-emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2015/10/26 5:02, Emmanuel Grumbach wrote:
> Adding IPv6 for the TSO helper API is trivial:
> * Don't play with the id (which doesn't exist in IPv6)
> * Correctly update the payload_len (don't include the
>   length of the IP header itself)
...
>  	memcpy(hdr, skb->data, hdr_len);
> -	iph = (struct iphdr *)(hdr + mac_hdr_len);
> -	iph->id = htons(tso->ip_id);
> -	iph->tot_len = htons(size + hdr_len - mac_hdr_len);
> +	if (skb->protocol == htons(ETH_P_IP)) {

I guess this should be vlan_get_protocol(skb).

> +		struct iphdr *iph = (void *)(hdr + mac_hdr_len);
> +
> +		iph->id = htons(tso->ip_id);
> +		iph->tot_len = htons(size + hdr_len - mac_hdr_len);
> +		tso->ip_id++;
> +	} else if (skb->protocol == htons(ETH_P_IPV6)) {

Likewise.

Toshiaki Makita

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
