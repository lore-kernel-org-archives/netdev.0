From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCHv3] printk: add %pM format specifier for MAC
 addresses
Date: Mon, 27 Oct 2008 14:55:15 -0700
Message-ID: <1225144515.5269.40.camel@localhost>
References: <1225067465.5672.1.camel@brick>
	 <1225090765.3746.7.camel@johannes.berg> <1225124904.5440.1.camel@brick>
	 <20081027.123805.134354592.davem@davemloft.net>
	 <1225137542.5396.10.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, johannes@sipsolutions.net,
	anders@anduras.de, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:1523 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751327AbYJ0V4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 17:56:05 -0400
In-Reply-To: <1225137542.5396.10.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-10-27 at 12:59 -0700, Harvey Harrison wrote:

The changes to use %p4 aren't too bad.
I did that last year using a similar style
to print_mac.  80 or so files.
http://repo.or.cz/w/linux-2.6/trivial-mods.git?a=shortlog;h=refs/heads/print_ipv4
ipv6 was 30 or so files
http://repo.or.cz/w/linux-2.6/trivial-mods.git?a=shortlog;h=refs/heads/print_ipv6

> I was wondering if perhaps it would be
> better to allow a length to be specified as well, which would allow:
[]
> But if that was added, it may be more natural to call it 
> %pB (bytes)
> %pW (words)

I think length would not be good addition.
print_dump_hex already does a fine job.
There are also BE/LE expectation problems with pW.

The %p6 pointer should be in6_addr *
The %p4 pointer should be __be32 *.
Printing an ipv4 address should use %u.%u.%u.%u

I've been doodling with sparse to check
calls with __attribute__(format(printf
parsing the format strings for %p<FOO>
and match the argument types.

I'll post it if anything comes of it.

> +static char *mac_address(char *buf, char *end, u8 *addr, int field_width,
> +			 int precision, int flags)
> +{

mac_address_string please.


