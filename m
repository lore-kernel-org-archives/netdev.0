From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] etherdevice: Optimize
 compare_ether_addr/ether_addr_equal
Date: Mon, 02 Sep 2013 09:52:21 -0700
Message-ID: <1378140741.1953.85.camel@joe-AO722>
References: <1377939256.2054.11.camel@joe-AO722>
	 <20130831.182750.678717944135962097.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:55670 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756122Ab3IBQwW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 12:52:22 -0400
In-Reply-To: <20130831.182750.678717944135962097.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-08-31 at 18:27 -0400, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Sat, 31 Aug 2013 01:54:16 -0700
> 
> > When CONFIG_HAS_EFFICIENT_UNALIGNED_ACCESS is set,
> > optimize compare_ether_addr a little by removing an
> > xor and or by using a u32 and u16 comparison
> > instead of 3 separate u16 comparisons.
> > 
> > Make the ether_addr_equal_64bits code a bit simpler
> > by adding a test for CONFIG_64BIT and calling
> > ether_addr_equal otherwise.
> > 
> > This also slightly improves ether_addr_equal_64bits
> > by removing the zap_last_2bytes shifts in the !64bit
> > case.
> > 
> > Signed-off-by: Joe Perches <joe@perches.com>
> 
> You'll need to update Documantion/unaligned-memory-access.txt as well
> because it uses this funcation as a "real life" example.

I submitted patches converting compare_ether_addr uses
to ether_addr_equal.

I'll send this patch again along with documenting the
requirement for ether_addr_equal if/after those patches
are applied so compare_ether_addr can be removed.
