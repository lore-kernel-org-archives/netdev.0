From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/4] printk: add %I4, %I6, %i4, %i6 format specifiers
Date: Thu, 30 Oct 2008 13:28:58 -0700
Message-ID: <1225398538.1288.9.camel@localhost>
References: <1225305340.5688.36.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:2337 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753121AbYJ3U3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 16:29:04 -0400
In-Reply-To: <1225305340.5688.36.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-10-29 at 11:35 -0700, Harvey Harrison wrote:
> For use in printing IPv4, or IPv6 addresses in the usual way:
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---
>  lib/vsprintf.c |   31 +++++++++++++++++++++++++++++++
>  1 files changed, 31 insertions(+), 0 deletions(-)
> 
> diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> index cb5bc04..a863006 100644
> --- a/lib/vsprintf.c
> +++ b/lib/vsprintf.c
[]
> @@ -650,6 +671,16 @@ static char *pointer(const char *fmt, char *buf, char *end, void *ptr, int field
>  		return mac_address_string(buf, end, ptr, field_width, precision, flags);
>  	case '6':
>  		return ip6_addr_string(buf, end, ptr, field_width, precision, flags);
> +	case 'i':
> +		flags |= SPECIAL;
> +		/* Fallthrough */
> +	case 'I':
> +		if (fmt[1] == '6')
> +			return ip6_addr_string(buf, end, ptr, field_width, precision, flags);
> +		if (fmt[1] == '4')
> +			return ip4_addr_string(buf, end, ptr, field_width, precision, flags);
> +		flags &= ~SPECIAL;
> +		break;
>  	}
>  	flags |= SMALL;
>  	if (field_width == -1) {

Hi Harvey.

I was thinking about extending %p<foo> to support
struct task_struct * and noticed this code isn't
really correct.

SPECIAL should be cleared from flags only when *fmt
is 'i' not 'I' and SPECIAL wasn't previously set.

cheers, Joe

