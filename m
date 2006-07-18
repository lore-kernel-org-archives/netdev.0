From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [RFC PATCH 32/33] Add the Xen virtual network device driver.
Date: Tue, 18 Jul 2006 12:27:57 +0200
Message-ID: <1153218477.3038.46.camel@laptopd505.fenrus.org>
References: <20060718091807.467468000@sous-sol.org>
	 <20060718091958.414414000@sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, virtualization@lists.osdl.org,
	xen-devel@lists.xensource.com,
	Jeremy Fitzhardinge <jeremy@goop.org>, Andi Kleen <ak@suse.de>,
	Andrew Morton <akpm@osdl.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Zachary Amsden <zach@vmware.com>,
	Ian Pratt <ian.pratt@xensource.com>,
	Christian Limpach <Christian.Limpach@cl.cam.ac.uk>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [216.208.38.107] ([216.208.38.107]:60800 "EHLO
	OTTLS.pngxnet.com") by vger.kernel.org with ESMTP id S932121AbWGRK25
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 06:28:57 -0400
To: Chris Wright <chrisw@sous-sol.org>
In-Reply-To: <20060718091958.414414000@sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-07-18 at 00:00 -0700, Chris Wright wrote:
> +
> +/** Send a packet on a net device to encourage switches to learn the
> + * MAC. We send a fake ARP request.
> + *
> + * @param dev device
> + * @return 0 on success, error code otherwise
> + */
> +static int send_fake_arp(struct net_device *dev)
> +{
> +	struct sk_buff *skb;
> +	u32             src_ip, dst_ip;
> +
> +	dst_ip = INADDR_BROADCAST;
> +	src_ip = inet_select_addr(dev, dst_ip, RT_SCOPE_LINK);
> +
> +	/* No IP? Then nothing to do. */
> +	if (src_ip == 0)
> +		return 0;
> +
> +	skb = arp_create(ARPOP_REPLY, ETH_P_ARP,
> +			 dst_ip, dev, src_ip,
> +			 /*dst_hw*/ NULL, /*src_hw*/ NULL,
> +			 /*target_hw*/ dev->dev_addr);
> +	if (skb == NULL)
> +		return -ENOMEM;
> +
> +	return dev_queue_xmit(skb);
> +}

Hi,

Hmmm maybe it's me, but something bugs me if a NIC driver is going to
send IP level ARP packets... that just feels very very wrong and is a
blatant layering violation.... shouldn't the ifup/ifconfig scripts just
be fixed instead if this is critical behavior?

Greetings,
   Arjan van de Ven



