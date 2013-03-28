From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree
 (net-next tree related)
Date: Thu, 28 Mar 2013 01:19:39 -0400 (EDT)
Message-ID: <20130328.011939.1891553737450044285.davem@davemloft.net>
References: <20130328160420.e57d7fdbd2894807e73e8497@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, jasowang@redhat.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130328160420.e57d7fdbd2894807e73e8497@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 28 Mar 2013 16:04:20 +1100

> Hi all,
> 
> After merging the final tree, today's linux-next build (powerpc
> ppc44x_defconfig) failed like this:
> 
> net/packet/af_packet.c: In function 'packet_sendmsg_spkt':
> net/packet/af_packet.c:1515:2: error: implicit declaration of function 'skb_probe_transport_header' [-Werror=implicit-function-declaration]
> drivers/net/tun.c: In function 'tun_get_user':
> drivers/net/tun.c:1206:2: error: implicit declaration of function 'skb_probe_transport_header' [-Werror=implicit-function-declaration]
> 
> Caused by commit 40893fd0fd4e ("net: switch to use
> skb_probe_transport_header()").  This is a 32 bit build, so that
> "BITS_PER_LONG > 32" is false and so NET_SKBUFF_DATA_USES_OFFSET is not
> defined ... and skb_probe_transport_header() is only defined in an area of
> skbuff.h protected by "#ifdef NET_SKBUFF_DATA_USES_OFFSET"  :-(
> 
> I have reverted that commit for today.

This got fixed about an hour ago :-)
