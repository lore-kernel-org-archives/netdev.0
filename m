From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [RFC] bmac:change to use bitrev8() generic function
Date: Mon, 10 Aug 2015 13:49:01 +0200
Message-ID: <20150810114901.GS16878@distanz.ch>
References: <9A81C947-6F69-4549-B1D0-58061D6976CE@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fabf@skynet.be, david@gibson.dropbear.id.au, davem@davemloft.net,
	benh@kernel.crashing.org, netdev@vger.kernel.org,
	open list <linux-kernel@vger.kernel.org>
To: yalin wang <yalin.wang2010@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <9A81C947-6F69-4549-B1D0-58061D6976CE@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015-08-10 at 11:53:41 +0200, yalin wang <yalin.wang2010@gmail.com> wrote:
> This change to use generic bitrev8() for bmac driver.
> 
> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
> ---
>  drivers/net/ethernet/apple/bmac.c | 17 +++--------------
>  1 file changed, 3 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/net/ethernet/apple/bmac.c b/drivers/net/ethernet/apple/bmac.c
> index a65d7a6..e749747 100644
> --- a/drivers/net/ethernet/apple/bmac.c
> +++ b/drivers/net/ethernet/apple/bmac.c
> @@ -22,6 +22,7 @@
>  #include <linux/bitrev.h>
>  #include <linux/ethtool.h>
>  #include <linux/slab.h>
> +#include <linux/bitrev.h>
>  #include <asm/prom.h>
>  #include <asm/dbdma.h>
>  #include <asm/io.h>
> @@ -805,18 +806,6 @@ static irqreturn_t bmac_txdma_intr(int irq, void *dev_id)
>  }
>  
>  #ifndef SUNHME_MULTICAST
> -/* Real fast bit-reversal algorithm, 6-bit values */
> -static int reverse6[64] = {
> -	0x0,0x20,0x10,0x30,0x8,0x28,0x18,0x38,
> -	0x4,0x24,0x14,0x34,0xc,0x2c,0x1c,0x3c,
> -	0x2,0x22,0x12,0x32,0xa,0x2a,0x1a,0x3a,
> -	0x6,0x26,0x16,0x36,0xe,0x2e,0x1e,0x3e,
> -	0x1,0x21,0x11,0x31,0x9,0x29,0x19,0x39,
> -	0x5,0x25,0x15,0x35,0xd,0x2d,0x1d,0x3d,
> -	0x3,0x23,0x13,0x33,0xb,0x2b,0x1b,0x3b,
> -	0x7,0x27,0x17,0x37,0xf,0x2f,0x1f,0x3f
> -};
> -
>  static unsigned int
>  crc416(unsigned int curval, unsigned short nxtval)
>  {
> @@ -871,7 +860,7 @@ bmac_addhash(struct bmac_data *bp, unsigned char *addr)
>  
>  	if (!(*addr)) return;
>  	crc = bmac_crc((unsigned short *)addr) & 0x3f; /* Big-endian alert! */
> -	crc = reverse6[crc];	/* Hyperfast bit-reversing algorithm */
> +	crc = bitrev8((u8)crc);

No, this won't work. reverse6 works on 6 bit values, while bitrev8 works
on 8bit values, e.g. reverse6[1] = 0x20, while bitrev8(1) = 0x80
