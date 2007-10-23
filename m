From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] - trivial - Improve appletalk checksum calculation
Date: Mon, 22 Oct 2007 20:30:52 -0700
Message-ID: <20071022203052.23725719@freepuppy.rosehill>
References: <1193081779.5132.24.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49381 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752138AbXJWDce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 23:32:34 -0400
In-Reply-To: <1193081779.5132.24.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 22 Oct 2007 12:36:19 -0700
Joe Perches <joe@perches.com> wrote:

> It's a bit after 2.6.1 now...
> 
> Removes unnecessary if, uses 16 bit rotate left.
> Performance improves ~30%
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> 
> diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
> index 7c0b515..1c50f4c 100644
> --- a/net/appletalk/ddp.c
> +++ b/net/appletalk/ddp.c
> @@ -925,15 +925,9 @@ static int atrtr_ioctl(unsigned int cmd, void __user *arg)
>  static unsigned long atalk_sum_partial(const unsigned char *data,
>  				       int len, unsigned long sum)
>  {
> -	/* This ought to be unwrapped neatly. I'll trust gcc for now */
>  	while (len--) {
> -		sum += *data;
> -		sum <<= 1;
> -		if (sum & 0x10000) {
> -			sum++;
> -			sum &= 0xffff;
> -		}
> -		data++;
> +		sum += *data++;
> +		sum = ((sum & 0x8000)>>15) | ((sum & 0x7fff)<<1);
>  	}
>  	return sum;
>  }
> 

The end of the message you quoted was:

> Corrected fast code is:
> 
>         while (len--) {
>                 sum += *data++;
>                 sum <<= 1;
>                 sum = (((sum & 0x10000) >> 16) + sum) & 0xffff;
>         }
> 
> At least it is correct on the standalone random data test, and the
> new code is 30% faster for the cached memory case (13.7 clks/byte vs 18 
> clks/byte).

Your code looks different...

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
