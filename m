From: David Miller <davem@davemloft.net>
Subject: Re: [IPv6] Fix ICMPv6 redirect handling with target multicast
 address, try 3
Date: Mon, 08 Oct 2007 00:12:53 -0700 (PDT)
Message-ID: <20071008.001253.26300247.davem@davemloft.net>
References: <46FD2B37.6040502@hp.com>
	<4702997D.6020208@hp.com>
	<4703AAC1.3040500@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	dlstevens@us.ibm.com
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40697
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752419AbXJHHMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 03:12:54 -0400
In-Reply-To: <4703AAC1.3040500@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Brian Haley <brian.haley@hp.com>
Date: Wed, 03 Oct 2007 10:44:17 -0400

> When the ICMPv6 Target address is multicast, Linux processes the 
> redirect instead of dropping it.  The problem is in this code in 
> ndisc_redirect_rcv():
> 
>          if (ipv6_addr_equal(dest, target)) {
>                  on_link = 1;
>          } else if (!(ipv6_addr_type(target) & IPV6_ADDR_LINKLOCAL)) {
>                  ND_PRINTK2(KERN_WARNING
>                             "ICMPv6 Redirect: target address is not 
> link-local.\n");
>                  return;
>          }
> 
> This second check will succeed if the Target address is, for example, 
> FF02::1 because it has link-local scope.  Instead, it should be checking 
> if it's a unicast link-local address, as stated in RFC 2461/4861 Section 
> 8.1:
> 
>        - The ICMP Target Address is either a link-local address (when
>          redirected to a router) or the same as the ICMP Destination
>          Address (when redirected to the on-link destination).
> 
> I know this doesn't explicitly say unicast link-local address, but it's 
> implied.
> 
> This bug is preventing Linux kernels from achieving IPv6 Logo Phase II 
> certification because of a recent error that was found in the TAHI test 
> suite - Neighbor Disovery suite test 206 (v6LC.2.3.6_G) had the 
> multicast address in the Destination field instead of Target field, so 
> we were passing the test.  This won't be the case anymore.
> 
> The patch below fixes this problem, and also fixes ndisc_send_redirect() 
> to not send an invalid redirect with a multicast address in the Target 
> field.  I re-ran the TAHI Neighbor Discovery section to make sure Linux 
> passes all 245 tests now.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>
> Acked-by: David L Stevens <dlstevens@us.ibm.com>

I believe everyone's concerns have been addressed in this
version of the patch, so I have applied it to net-2.6

Thanks everyone!
