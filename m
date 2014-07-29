From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net-next] sfc: Use __iowrite64_copy instead of a slightly
 different local function
Date: Tue, 29 Jul 2014 16:03:51 +0100
Message-ID: <53D7B7D7.2030405@solarflare.com>
References: <1406427279.29010.139.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Shradha Shah <sshah@solarflare.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:8521 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753425AbaG2PED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 11:04:03 -0400
In-Reply-To: <1406427279.29010.139.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/07/14 03:14, Ben Hutchings wrote:
> __iowrite64_copy() isn't quite the same as efx_memcpy_64(), but
> it looks close enough:
>
> - The length is in units of qwords not bytes
> - It never byte-swaps, but that doesn't make a difference now as PIO
>   is only enabled for x86_64
> - It doesn't include any memory barriers, but that's OK as there is a
>   barrier just before pushing the doorbell
> - mlx4_en uses it for the same purpose
>
> Compile-tested only.
>
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Acked-by: Edward Cree <ecree@solarflare.com>

On my test system, __iowrite64_copy compiles to use "mov    %rax,(%rdi)"
which we believe is safe (all writes will be naturally-aligned 64-bit
accesses, as required by the hardware).
