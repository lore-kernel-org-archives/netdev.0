From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Should use consistent conditional judgement for
 ip6 fragment between __ip6_append_data and ip6_finish_output
Date: Thu, 29 Dec 2016 11:55:43 -0500 (EST)
Message-ID: <20161229.115543.1762031328572098632.davem@davemloft.net>
References: <1482938626-20151-1-git-send-email-lizheng043@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, james.z.li@ericsson.com
To: lizheng043@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482938626-20151-1-git-send-email-lizheng043@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zheng Li <lizheng043@gmail.com>
Date: Wed, 28 Dec 2016 23:23:46 +0800

> From: Zheng Li <james.z.li@ericsson.com>
> 
> There is an inconsistent conditional judgement between __ip6_append_data
> and ip6_finish_output functions, the variable length in __ip6_append_data
> just include the length of application's payload and udp6 header, don't
> include the length of ipv6 header, but in ip6_finish_output use
> (skb->len > ip6_skb_dst_mtu(skb)) as judgement, and skb->len include the
> length of ipv6 header.
> 
> That causes some particular application's udp6 payloads whose length are
> between (MTU - IPv6 Header) and MTU were fragmented by ip6_fragment even
> though the rst->dev support UFO feature.
> 
> Add the length of ipv6 header to length in __ip6_append_data to keep
> consistent conditional judgement as ip6_finish_output for ip6 fragment.
> 
> Signed-off-by: Zheng Li <james.z.li@ericsson.com>

Applied, thank you.
