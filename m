From: David Madore <david.madore@ens.fr>
Subject: Re: atl1e Ethernet driver not seeing packets sent to 33:33:00:00:00:01 multicast
Date: Tue, 11 Nov 2008 23:00:15 +0100
Message-ID: <20081111220015.GA18215@clipper.ens.fr>
References: <20081111133108.GA7124@clipper.ens.fr> <20081111080611.7f6d4371@osprey.hogchain.net> <20081111155908.GA14665@clipper.ens.fr> <20081111100816.58a7cf09@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing-List <linux-kernel@vger.kernel.org>,
	Linux NetDev Mailing-List <netdev@vger.kernel.org>,
	atl1-devel@lists.sourceforge.net
To: "J. K. Cliburn" <jcliburn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nef2.ens.fr ([129.199.96.40]:3615 "EHLO nef2.ens.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750808AbYKKWA2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 17:00:28 -0500
Content-Disposition: inline
In-Reply-To: <20081111100816.58a7cf09@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 11, 2008 at 10:08:16AM -0600, J. K. Cliburn wrote:
> Can you please try this patch?
> 
> diff --git a/drivers/net/atl1e/atl1e_hw.c b/drivers/net/atl1e/atl1e_hw.c
> index 949e753..c0d5f7c 100644
> --- a/drivers/net/atl1e/atl1e_hw.c
> +++ b/drivers/net/atl1e/atl1e_hw.c
> @@ -163,9 +163,6 @@ int atl1e_read_mac_addr(struct atl1e_hw *hw)
>   * atl1e_hash_mc_addr
>   *  purpose
>   *      set hash value for a multicast address
> - *      hash calcu processing :
> - *          1. calcu 32bit CRC for multicast address
> - *          2. reverse crc with MSB to LSB
>   */
>  u32 atl1e_hash_mc_addr(struct atl1e_hw *hw, u8 *mc_addr)
>  {
> @@ -174,7 +171,6 @@ u32 atl1e_hash_mc_addr(struct atl1e_hw *hw, u8 *mc_addr)
>  	int i;
>  
>  	crc32 = ether_crc_le(6, mc_addr);
> -	crc32 = ~crc32;
>  	for (i = 0; i < 32; i++)
>  		value |= (((crc32 >> i) & 1) << (31 - i));
>  

Now it works.  Many thanks!

Happy hacking,

-- 
     David A. Madore
    (david.madore@ens.fr,
     http://www.madore.org/~david/ )
