From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.12-rc4] IPv4/IPv6: UDP Large Send Offload feature
Date: Thu, 26 May 2005 16:42:17 -0700 (PDT)
Message-ID: <20050526.164217.45745005.davem@davemloft.net>
References: <20050526232006.60E6365005@linux.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, raghavendra.koushik@neterion.com,
        leonid.grossman@neterion.com, ananda.raju@neterion.com,
        rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ravinandan.arakali@neterion.com
In-Reply-To: <20050526232006.60E6365005@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


sock_append_data() seems like a lot of wasted work.

We already pass around the fragmented SKB as a list chained by
skb_shinfo(skb)->fraglist, just pass this thing to the device and in
this way you'll avoid all of that work sock_append_data() does
entirely.

Or is there a reason you did not implement it this
way?

This is one of the uses the skb_shinfo(skb)->fraglist was intended
for.

IN FACT, this fragmentation offload you are implementing here is what
the feature bit NETIF_F_FRAGLIST was meant to indicate.
