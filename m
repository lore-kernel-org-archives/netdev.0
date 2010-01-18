From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] S2io: two branches the same in wait_for_cmd_complete()
Date: Sun, 17 Jan 2010 19:13:59 -0800 (PST)
Message-ID: <20100117.191359.190417865.davem@davemloft.net>
References: <4B53284C.1090405@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, sivakumar.subramani@neterion.com,
	ram.vepa@neterion.com, santosh.rastapur@neterion.com,
	sreenivasa.honnur@neterion.com, anil.murthy@neterion.com
To: roel.kluin@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755254Ab0ARDNz@vger.kernel.org>
In-Reply-To: <4B53284C.1090405@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roel Kluin <roel.kluin@gmail.com>
Date: Sun, 17 Jan 2010 16:10:04 +0100

> Regardless of the bit_state, the branches execute the same code.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
>  drivers/net/s2io.c |   13 +++----------
>  1 files changed, 3 insertions(+), 10 deletions(-)
> 
> Maybe something else was intended?
> this was introduced in commit 9fc93a41a1ad11

If you know the guilty commit, at least do the author(s) of commit
and/or the driver maintainer(s) the courtesy of CC:'ing them on
patches like this.

I've fixed this up here in my reply.

> diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
> index cc42186..0e353d6 100644
> --- a/drivers/net/s2io.c
> +++ b/drivers/net/s2io.c
> @@ -3415,16 +3415,9 @@ static int wait_for_cmd_complete(void __iomem *addr, u64 busy_bit,
>  
>  	do {
>  		val64 = readq(addr);
> -		if (bit_state == S2IO_BIT_RESET) {
> -			if (!(val64 & busy_bit)) {
> -				ret = SUCCESS;
> -				break;
> -			}
> -		} else {
> -			if (!(val64 & busy_bit)) {
> -				ret = SUCCESS;
> -				break;
> -			}
> +		if (!(val64 & busy_bit)) {
> +			ret = SUCCESS;
> +			break;
>  		}
>  
>  		if (in_interrupt())
