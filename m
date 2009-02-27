From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iptables: new strict host model match
Date: Thu, 26 Feb 2009 19:23:53 -0800
Message-ID: <20090226192353.2b6dea9f@nehalam>
References: <20090226175247.5e56910f@nehalam>
	<alpine.LSU.2.00.0902270414290.14912@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.00.0902270414290.14912@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 27 Feb 2009 04:16:19 +0100 (CET)
Jan Engelhardt <jengelh@medozas.de> wrote:

> 
> On Friday 2009-02-27 02:52, Stephen Hemminger wrote:
> >+static bool strict_mt(const struct sk_buff *skb, const struct xt_match_param *par)
> >+{
> >+	struct in_device *in_dev;
> >+	bool ret;
> >+
> >+	rcu_read_lock();
> >+	in_dev = __in_dev_get_rcu(skb->dev);
> >+	ret = (in_dev && inet_addr_onlink(in_dev, ip_hdr(skb)->daddr, 0));
> >+	rcu_read_unlock();
> >+
> >+	return ret;
> >+}
> 
> This looks easy enough to also do for IPv6. Would you?

IPV6 already does this.

> 
> >+static struct xt_match strict_mt_reg __read_mostly = {
> >+	.name		= "strict",
> >+	.family		= NFPROTO_IPV4,
> >+	.match		= strict_mt,
> >+	.matchsize	= 0,
> >+	.me		= THIS_MODULE,
> >+};
> 
> The match seems to make the most sense where an input device
> is available, so
> 
> 	.hooks = (1 << NF_INET_PRE_ROUTING) | (1 << NF_INET_LOCAL_IN) |
> 	         (1 << NF_INET_FORWARD)
> 
> should probably be added.

Then routing wouldn't work...
