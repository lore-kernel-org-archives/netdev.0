From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH v3] net: mv643xx_eth: Fix highmem support in non-TSO egress
 path
Date: Sat, 24 Jan 2015 10:45:29 -0300
Message-ID: <54C3A1F9.1000403@free-electrons.com>
References: <1421928859-17923-1-git-send-email-ezequiel.garcia@free-electrons.com> <1421937182-1708-1-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, B38611@freescale.com,
	fabio.estevam@freescale.com, David.Laight@ACULAB.COM
To: David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:55862 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752473AbbAXNrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jan 2015 08:47:37 -0500
In-Reply-To: <1421937182-1708-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

On 01/22/2015 11:33 AM, Ezequiel Garcia wrote:
> Commit 69ad0dd7af22b61d9e0e68e56b6290121618b0fb
> Author: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
> Date:   Mon May 19 13:59:59 2014 -0300
>=20
>     net: mv643xx_eth: Use dma_map_single() to map the skb fragments
>=20
> caused a nasty regression by removing the support for highmem skb
> fragments. By using page_address() to get the address of a fragment's
> page, we are assuming a lowmem page. However, such assumption is inco=
rrect,
> as fragments can be in highmem pages, resulting in very nasty issues.
>=20
> This commit fixes this by using the skb_frag_dma_map() helper,
> which takes care of mapping the skb fragment properly. Additionally,
> the type of mapping is now tracked, so it can be unmapped using
> dma_unmap_page or dma_unmap_single when appropriate.
>=20
> This commit also fixes the error path in txq_init() to release the
> resources properly.
>=20
> Fixes: 69ad0dd7af22 ("net: mv643xx_eth: Use dma_map_single() to map t=
he skb fragments")
> Reported-by: Russell King <rmk+kernel@arm.linux.org.uk>

Russell, when you have some time, please test this patch. I think it
solves the regression and it manages to unmap the descriptors properly.

Thanks!
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
