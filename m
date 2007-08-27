From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-2.6.24] introduce MAC_FMT/MAC_ARG
Date: Mon, 27 Aug 2007 14:26:46 -0700
Message-ID: <1188250006.18004.144.camel@localhost>
References: <1187808408.4314.15.camel@johannes.berg>
	 <1188086976.18004.5.camel@localhost>
	 <1188212049.6756.18.camel@johannes.berg>
	 <20070827.134131.41639376.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2986 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764830AbXH0V12 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Aug 2007 17:27:28 -0400
In-Reply-To: <20070827.134131.41639376.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-08-27 at 13:41 -0700, David Miller wrote:
> there are better approaches to this,
> how about just calling:
> 
> 	print_mac(dev->dev_addr);
> 
> Sure, we'll have to split up printk() calls, but in the end it's
> likely still smaller and better.  And I think it's much cleaner
> than this macro stuff.

My original patch had the equivalent of

	char* print_mac(char* buf, const char* addr) {
		sprintf(buf,"%02x:...", addr[0]...)
		return buf;
	}

and used:

	DECLARE_MAC_BUF(var); //same as char var[18];
	printk(MAC_FMT, MAC_ARG(var, addr));

which didn't require splitting printk()s

I've still got the original patch.
It's just substituting EUI48 for MAC and forward porting.

Want something like that?

