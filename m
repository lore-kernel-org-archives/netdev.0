From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/6] [NET]: Rethink mark field in struct flowi
Date: Thu, 9 Nov 2006 14:23:02 +0100
Message-ID: <200611091423.02504.dada1@cosmosbay.com>
References: <20061109112735.577771022@lsx.localdomain> <20061109113245.573179984@lsx.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:49598 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S965984AbWKINW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Nov 2006 08:22:56 -0500
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061109113245.573179984@lsx.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 09 November 2006 12:27, Thomas Graf wrote:
> Now that all protocols have been made aware of the mark
> field it can be moved out of the union thus simplyfing
> its usage.
>
> The config options in the IPv4/IPv6/DECnet subsystems
> to enable respectively disable mark based routing only
> obfuscate the code with ifdefs, the cost for the
> additional comparison in the flow key is insignificant,
> and most distributions have all these options enabled
> by default anyway. Therefore it makes sense to remove
> the config options and enable mark based routing by
> default.

I give a big NACK to this patch.

By moving fwmark outside of union, you basically touch more cache lines in 
lookups. I have many machines doing XX.XXX of lookups per second, with long 
chains, already using 10% of CPU. I am sure a lot of other machines would 
suffer with this patch, especially machines with 32 bytes cache lines.

For IPV4 lookups, compare offset of fwmark before your patch and after.
The size of ip6_u is so large that moving fwmark after nl_u union is not an 
option. Many packets in flight on the Internet are still IPV4.

If you think code is obfuscated, you can make it more readable using macros 
defined in include files, and used in C file without ifdefs.

Thank you
Eric
