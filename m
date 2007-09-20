From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH - net-2.6.24 0/2] Introduce and use print_ip and
	print_ipv6
Date: Thu, 20 Sep 2007 16:20:58 -0700
Message-ID: <1190330458.26101.188.camel@localhost>
References: <1190271211.26101.91.camel@localhost>
	 <20070920230552.GF15613@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3218 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751049AbXITXVF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 19:21:05 -0400
In-Reply-To: <20070920230552.GF15613@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-09-21 at 01:05 +0200, Thomas Graf wrote:
> What exactly is the advantage of this?

It makes the kernel image smaller and has consistency,
typechecking and sparse advantages.

print_mac(char *buf, const u8 *addr)
print_ip(char *buf, __be32 addr)
print_ipv6(char *buf, const u8 *addr)

Current use of formatting for IPV6:
  NIP6_FMT in each format, 38 bytes %s is 2.
  NIP6(addr) is 8 args, and inlined ntohs overhead
now it's:
  automatic buffer, format "%s", function call and 2 args

IPv4 is more or less a wash:
  format "%u.%u.%u.%u", 11 bytes, 4 args inlined
vs
  automatic buffer, format "%s", function call and 2 args 


