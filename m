From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Functions Clean-up
Date: Sun, 03 Nov 2002 22:16:58 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021103.221658.52523847.yoshfuji@linux-ipv6.org>
References: <20021103.115427.104445233.yoshfuji@linux-ipv6.org>
	<1036328414.1048.3.camel@arwen>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   netfilter-devel@lists.netfilter.org, davem@redhat.com, kuznet@ms2.inr.ac.ru,
   usagi@linux-ipv6.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kisza@securityaudit.hu
In-Reply-To: <1036328414.1048.3.camel@arwen>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <1036328414.1048.3.camel@arwen> (at Sun, 03 Nov 2002 14:00:14 +0100), Andras Kis-Szabo <kisza@securityaudit.hu> says:

> This patch removes one function from the Netfilter code and forces the
> Netfilter to use a similar function from the kernel's one!

net/ipv6/netfilter/ip6_queue.c says:

/*
 * Taken from net/ipv6/ip6_output.c
 * We should use the one there, but is defined static
 * so we put this just here and let the things as
 * they are now.
 *
 * If that one is modified, this one should be modified too.
 */

So, the reason why the copy of route6_me_harder() 
lives there is because net/ipv6/ip6_output.c has not been 
exported it.

Is this something to do with parser of extension headers?
Parser of extension headers is different thing, isn't it?

Yes, since duplication of code is bad unless there're really 
strong reasons.  I believe that there would be a better 
design for filtering.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
