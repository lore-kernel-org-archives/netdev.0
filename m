From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] r8152: drop the tx packet with invalid length
Date: Fri, 19 Dec 2014 09:36:43 -0800
Message-ID: <1419010603.9773.84.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1417020748.29427.59.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141126.120658.498602780456343676.davem@davemloft.net>
	 <1417027459.29427.63.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141126.153356.461494573591656082.davem@davemloft.net>
	 <0835B3720019904CB8F7AA43166CEEB2ED585A@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>,
	Tom Herbert <therbert@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2ED585A@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-12-19 at 06:42 +0000, Hayes Wang wrote:

> Excuse me. I try to implement ndo_gso_check() with kernel 3.18.
> However, I still get packets with gso and their skb lengths are more
> than the acceptable one. Do I miss something?
> 
> +static bool rtl8152_gso_check(struct sk_buff *skb, struct net_device *dev)
> +{
> +	if ((skb->len + sizeof(struct tx_desc)) > agg_buf_sz)
> +		return false;
> +
> +	return true;
> +}
>  
> @@ -5861,6 +5876,9 @@ static const struct net_device_ops rtl8152_netdev_ops = {
>  	.ndo_set_mac_address	= rtl8152_set_mac_address,
>  	.ndo_change_mtu		= rtl8152_change_mtu,
>  	.ndo_validate_addr	= eth_validate_addr,
> +	.ndo_gso_check		= rtl8152_gso_check,
>  };

You are right, it seems ndo_gso_check() is buggy at this moment.

Presumably this method should alter %features so that we really segment
the packets in software.

features &= ~NETIF_F_GSO_MASK;
