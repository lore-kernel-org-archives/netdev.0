From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: RE: [PATCH] mlx4_en: fix transmit of packages when blue frame
 isenabled
Date: Sun, 09 Oct 2011 09:28:51 +0200
Message-ID: <1318145331.29415.372.camel@pasglop>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AE76@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eli Cohen <eli@dev.mellanox.co.il>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Eli Cohen <eli@mellanox.co.il>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:43429 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750893Ab1JIH3S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Oct 2011 03:29:18 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AE76@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-10-06 at 15:10 +0100, David Laight wrote:
> horrid...
> 1) I'm not sure the caller expects the buffer to be corrupted.
> 2) It contains a lot of memory cycles.
> 3) It looked from the calls that this code is copying descriptors,
>    so the transfer length is probably 1 or 2 words - so the loop
>    is inefficient.
> 4) ppc doesn't have a fast byteswap instruction (very new gcc might
>    use the byteswapping memery access for the le32_to_cpu() though),
>    so it would be better getting the byteswap done inside
>    __iowrite64_copy() - since that is probably requesting a byteswap
>    anyway.
> OTOH I'm not at all clear about the 64bit xfers....

And it's just plain wrong anyway. You should never have to byteswap a
copy.

Ben.
