From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next] tc: cls_bpf: make ingress and egress qdiscs
 consistent
Date: Tue, 07 Apr 2015 14:51:50 -0400 (EDT)
Message-ID: <20150407.145150.1058933089890438367.davem@davemloft.net>
References: <1428095784-7091-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1428095784-7091-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Date: Fri,  3 Apr 2015 14:16:24 -0700

> +		if (skb_headroom(skb) < ETH_HLEN)
> +			return -1;
> +		__skb_push(skb, ETH_HLEN);
 ...
> +	if (tp->q->flags & TCQ_F_INGRESS)
> +		__skb_pull(skb, ETH_HLEN);

Please use the actual device's L2 header length, via
dev->hard_header_len, rather than hard coding ethernet.
