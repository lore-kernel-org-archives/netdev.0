From: Robert Stonehouse <rstonehouse@solarflare.com>
Subject: Re: [PATCH net v4 1/2] sfc: use 64-bit writes for PIO.
Date: Thu, 5 Jun 2014 18:08:48 +0100
Message-ID: <5390A420.9070903@solarflare.com>
References: <538D9D1E.3090608@solarflare.com>	<538D9DB3.4080905@solarflare.com> <20140603.155807.2227032324368753328.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-7"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <sshah@solarflare.com>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:28007 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752170AbaFERIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 13:08:55 -0400
In-Reply-To: <20140603.155807.2227032324368753328.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/06/14 23:58, David Miller wrote:
> Did you do any functional testing of this on such a machine?
>
> I'm extremely disappointed in this patch submission, because you
> didn't even_compile_  test this in the environment where you claim
> the problem exists.

The next patch posted in the series would have meant that this change 
was limited to x86_64 systems.
I am sorry that by posting the patches in an incorrect order/not merging 
them we gave the impression that we do not test these patches (but hands 
up, patch 1/2 did break 32 bit compiles and certainly did need more 
work. Thanks to Sergei, Joe and yourself for comments)

For x86_64 machines we checked writeq() implementations in io.h and 
disassembled the module to ensure that a single 64bit access was used.

I would like to get an improved bug fix upstream, as I know this rare 
hardware issue has been hit in the wild  and with TX checksum offload 
enabled corrupted data can get to the application.

The reason for limiting to x86_64 is that in this code path there is an 
IO write to a write-combined mapping. It was a very hard case to hit 
(believed to depend on the timing of accesses and resulting 
write-combining behaviour), but we never reproduced it in our lab.
Limiting this IO to WC mappings to x86_64 only was a safety measure 
given the amount of hours of testing we have on x86_64 vs.other 64 bit 
platforms that we test with (PPC64)
This feature gives a small latency win on this hardware family for small 
packets.

Unless there are more comments to consider the next post will be a 
merged patch, addressing all points raised so far.

Regards
Rob
