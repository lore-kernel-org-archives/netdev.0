From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.12-rc4] IPv4/IPv6: UDP Large Send Offload feature
Date: Fri, 27 May 2005 12:02:15 -0700 (PDT)
Message-ID: <20050527.120215.26278001.davem@davemloft.net>
References: <20050526.164217.45745005.davem@davemloft.net>
	<000a01c562d9$9b661130$3910100a@pc.s2io.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, raghavendra.koushik@neterion.com,
        leonid.grossman@neterion.com, ananda.raju@neterion.com,
        rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ravinandan.arakali@neterion.com
In-Reply-To: <000a01c562d9$9b661130$3910100a@pc.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Date: Fri, 27 May 2005 09:32:00 -0700

> Thanks for the quick feedback.
> At that time when we considered using skb_shinfo(skb)->fraglist,
> it contained fragments of MTU size. So, for a 60k udp datagram 
> and 1500 MTU we will have 60k/1500 = 45 fragments which is
> more than MAX_SKB_FRAGS(18).
> 
> However we will relook at fraglist for the possibility of increasing
> frag size to >MTU.

MAX_SKB_FRAGS controls the limit of skb_shinfo(skb)->frags[]
entries, not how many SKBs may be chained via
skb_shinfo(skb)->fraglist, there is no limit on the latter.

Note that there is much coalescing that can be performed on
the SKB list data areas, particularly if UDP sendfile() is
being used.

But such coalescing is messy to be performing inside of the
drivers.  It may end up being the case that your approach
ends up being a better one for these reasons.
