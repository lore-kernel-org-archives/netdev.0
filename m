From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: Sereral errors on udpv6_connect()
Date: Tue, 03 Jun 2003 22:46:57 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030603.224657.116381839.davem@redhat.com>
References: <20030604.093944.84705841.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: vnuorval@tcs.hut.fi, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030604.093944.84705841.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Wed, 04 Jun 2003 09:39:44 +0900 (JST)
   
   This patch fixes multiple errors in udpv6_connect().
    - pointer within an automatic storage class variable fl was illegally cached
      using ip6_dst_store().
    - uninitialized saddr was copied to fl.fl6_src.
    - don't cache if ipv6_saddr_get() failed.

Applied.

All these kinds of things need to be done differently once
routing by saddr is supported, more specifically when
route6 lookups make source address selection.  Look at
ipv4 side to see the kind of thing I'm talking about.

Yoshfuji-san, remember when Alexey wanted you to change your
source address selection so that it occurred at routing layer?
This is exactly what I'm talking about.

In my view, ipv6 routing is merely a SEVERELY crippled version
of ipv4 routing.  Most of ipv6 routing changes needed amount
to merely "porting over" existing ipv4 routing features.
