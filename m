From: Joe Perches <joe@perches.com>
Subject: Re: [IPX]: Fix checksum computation.
Date: Fri, 31 Oct 2003 13:24:06 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1067635446.11564.92.camel@localhost.localdomain>
References: <200310312006.h9VK62Hh005910@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <200310312006.h9VK62Hh005910@hera.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2003-10-30 at 19:43, Linux Kernel Mailing List wrote:
> ChangeSet 1.1399, 2003/10/30 19:43:04-08:00, davem@nuts.ninka.net
> 	[IPX]: Fix checksum computation.
> diff -Nru a/net/appletalk/ddp.c b/net/appletalk/ddp.c
> --- a/net/appletalk/ddp.c	Fri Oct 31 12:06:06 2003
> +++ b/net/appletalk/ddp.c	Fri Oct 31 12:06:06 2003
> @@ -937,9 +937,13 @@
>  {
>  	/* This ought to be unwrapped neatly. I'll trust gcc for now */
>  	while (len--) {
> -		sum += *data++;
> +		sum += *data;
>  		sum <<= 1;
> -		sum = ((sum >> 16) + sum) & 0xFFFF;
> +		if (sum & 0x10000) {
> +			sum++;
> +			sum &= 0xffff;
> +		}
> +		data++;
>  	}
>  	return sum;
>  }

This change didn't appear on this list for comment,
it just appeared in the source.

Why is this a "fix"?  Performance?
It seems more like someone's idea of code neatening.

If this is done, why not if (unlikely())
