From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] xfrm ip6ip6 (revised)
Date: Fri, 13 Jun 2003 12:07:02 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030613.120702.71089628.davem@redhat.com>
References: <87fzmv5ejc.wl@karaba.org>
	<20030601.013040.116362760.davem@redhat.com>
	<87smqerml5.wl@karaba.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: jmorris@intercode.com.au, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: mk@linux-ipv6.org
In-Reply-To: <87smqerml5.wl@karaba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Mitsuru KANDA / 神田 充 <mk@linux-ipv6.org>
   Date: Sat, 14 Jun 2003 01:03:50 +0900

   	- to allocate unique spi values in xfrm6_tunnel.c  
   	  by using just simple open addressing hash, 

Mitsuru, what happens if two tunnels use same address?

Only first one will be found in hash, this is incorrect
behavior as it will cause the wrong SPI to be used when
packets are really destined for second user of that address.

You need to add refcount to hash table entries, so that SPI can be
shared by different xfrm6 tunnels with same address.
