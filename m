From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Fix Prefix Length of Link-local Addresses
Date: Mon, 07 Oct 2002 11:55:30 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021007.115530.00078126.davem@redhat.com>
References: <20021008.000559.17528416.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20021008.000559.17528416.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Tue, 08 Oct 2002 00:05:59 +0900 (JST)

   Prefix length for link-local address should be 64, not 10.
   This patch fixes prefix length of link-local address.
   
   Following patch is against 2.4.19.

Patch is applied, thank you.

BTW, we start to run into conflicts now and most of USAGI patches now
I need to apply some parts by hand.  Here is one example, with this
patch:
   
   @@ -783,7 +783,7 @@
    	struct in6_addr addr;
    
    	ipv6_addr_set(&addr,  __constant_htonl(0xFE800000), 0, 0, 0);
   -	addrconf_prefix_route(&addr, 10, dev, 0, RTF_ADDRCONF);
   +	addrconf_prefix_route(&addr, 64, dev, 0, RTF_ADDRCONF);
    }
    
    static struct inet6_dev *addrconf_add_dev(struct net_device *dev)

Note in this hunk the __constant_htonl() which was transformed
to plain htonl() by already accepted USAGI patch.

It is not such a big deal now, but it may soon become larger as
bigger USAGI patches are applied.  We will need to synchronize
at some point.
