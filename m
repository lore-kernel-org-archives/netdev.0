From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.8.1-mm4 8/11] r8169: Tx checksum offload
Date: Sat, 28 Aug 2004 19:15:26 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4131120E.7010108@pobox.com>
References: <20040823224100.GA14680@electric-eye.fr.zoreil.com> <20040823224425.GA20726@electric-eye.fr.zoreil.com> <20040823224548.GB20726@electric-eye.fr.zoreil.com> <20040823224706.GC20726@electric-eye.fr.zoreil.com> <20040823224813.GD20726@electric-eye.fr.zoreil.com> <20040823224927.GE20726@electric-eye.fr.zoreil.com> <20040823225120.GF20726@electric-eye.fr.zoreil.com> <20040823225335.GG20726@electric-eye.fr.zoreil.com> <20040823225505.GH20726@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040823225505.GH20726@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> +static inline u32 rtl8169_tx_csum(struct sk_buff *skb)
> +{
> +	if (skb->ip_summed == CHECKSUM_HW) {
> +		const struct iphdr *ip = skb->nh.iph;
> +
> +		if (ip->protocol == IPPROTO_TCP)
> +			return IPCS | TCPCS;
> +		else if (ip->protocol == IPPROTO_UDP)
> +			return IPCS | UDPCS;
> +		BUG();
> +	}
> +	return 0;
> +}

I am applying this patch BUT...  BUG() is a bit too "rude" when you can 
obviously return safely.  Prefer WARN_ON() because we don't need to kill 
the machine for this condition.
