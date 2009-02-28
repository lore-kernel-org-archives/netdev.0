From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] iptables: new strict host model match
Date: Sat, 28 Feb 2009 09:27:04 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0902280923090.7746@fbirervta.pbzchgretzou.qr>
References: <20090226175247.5e56910f@nehalam> <alpine.LSU.2.00.0902270414290.14912@fbirervta.pbzchgretzou.qr> <20090226192353.2b6dea9f@nehalam> <alpine.LSU.2.00.0902280253030.20614@fbirervta.pbzchgretzou.qr> <20090227181009.5b53f4c8@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090227181009.5b53f4c8@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Saturday 2009-02-28 03:10, Stephen Hemminger wrote:
>> On Friday 2009-02-27 04:23, Stephen Hemminger wrote:
>> >> >+static struct xt_match strict_mt_reg __read_mostly = {
>> >> >+	.name		= "strict",
>> >> >+	.family		= NFPROTO_IPV4,
>> >> >+	.match		= strict_mt,
>> >> >+	.matchsize	= 0,
>> >> >+	.me		= THIS_MODULE,
>> >> >+};
>> >> 
>> >> The match seems to make the most sense where an input device
>> >> is available, so
>> >> 
>> >> 	.hooks = (1 << NF_INET_PRE_ROUTING) | (1 << NF_INET_LOCAL_IN) |
>> >> 	         (1 << NF_INET_FORWARD)
>> >> 
>> >> should probably be added.
>> >
>> >Then routing wouldn't work...
>> 
>I suppose it could be useful to to different chains for routed vs non-routed
>packets on pre-routing chain, but on forward chain it wouldn't really
>do anything useful.
>
...Ok? The hooks mask limits the use of the match to - true to its name -
hooks, so it is implies permitting the use of the match in the
PREROUTING/INPUT/FORWARD chain and chains called from it, as long as
no unlisted chain has a reference to it too. This is how most other
modules, e.g. xt_mac, act too.

Since xt_strict inspects in_dev, and in_dev is not available in
OUTPUT/POSTROUTING, I was suggesting to just limit its use to the
chains where in_dev != NULL.
Or did I misunderstood you?
