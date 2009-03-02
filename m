From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH] iptables: new strict host model match
Date: Mon, 2 Mar 2009 14:42:33 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0903021427570.27363@ask.diku.dk>
References: <20090226175247.5e56910f@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090226175247.5e56910f@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 26 Feb 2009, Stephen Hemminger wrote:

> This is a simple little iptables match that can be used to create the Strong
> End System model, that router and other non-Linux customers expect. There
> are management and other applications that use ping and expect to only get
> a response when the interface with that address is up. Normally, a Linux
> system will respond to a packet that arrives for any of the system addresses
> independent of which link it arrives on.

Is this no almost the same as:

  echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore



> +static bool strict_mt(const struct sk_buff *skb, const struct xt_match_param *par)
> +{
> +	struct in_device *in_dev;
> +	bool ret;
> +
> +	rcu_read_lock();
> +	in_dev = __in_dev_get_rcu(skb->dev);
> +	ret = (in_dev && inet_addr_onlink(in_dev, ip_hdr(skb)->daddr, 0));

inet_addr_onlink() will call
  -> inet_ifa_match(ip_hdr(skb)->daddr, ifa)

arp_ignore = 1
  -> inet_confirm_addr(in_dev, 0, tip, RT_SCOPE_HOST)
     -> inet_ifa_match(tip, ifa)


Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
