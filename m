From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: + net-ipv4-tcpc-fix-warning.patch added to -mm tree
Date: Tue, 08 Dec 2009 20:45:53 -0500
Message-ID: <4B1F0151.10903@gmail.com>
References: <200912090045.nB90jTaO010647@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mm-commits@vger.kernel.org, davem@davemloft.net,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:33790 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575AbZLIBpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 20:45:49 -0500
In-Reply-To: <200912090045.nB90jTaO010647@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> The patch titled
>      net/ipv4/tcp.c: fix warning
> has been added to the -mm tree.  Its filename is
>      net-ipv4-tcpc-fix-warning.patch
> 
> Before you just go and hit "reply", please:
>    a) Consider who else should be cc'ed
>    b) Prefer to cc a suitable mailing list as well
>    c) Ideally: find the original patch on the mailing list and do a
>       reply-to-all to that, adding suitable additional cc's
> 
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> 
> See http://userweb.kernel.org/~akpm/stuff/added-to-mm.txt to find
> out what to do about this
> 
> The current -mm tree may be found at http://userweb.kernel.org/~akpm/mmotm/
> 
> ------------------------------------------------------
> Subject: net/ipv4/tcp.c: fix warning
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> x86_64 allmodconfig:
> 
> net/ipv4/tcp.c: In function 'do_tcp_getsockopt':
> net/ipv4/tcp.c:2544: warning: comparison is always false due to limited range of data type
> 
> sizeof(tcpct_value) is 536, which can never be less than a value which is held
> in a u8.
> 
> This fix is stupid - just delete the code?
> 
I didn't have this warning, how in the world do you get it?

This is what David calls my "anal" coding style.  I check everything,
because someday somebody else might make a change, and it's important
that such problems be detected.  In this case, I assume the compiler
will compile them out or it would have no effect, and commented that
it should be impossible.

Your test should probably be TCP_MSS_DEFAULT < TCP_COOKIE_PAIR_SIZE


> btw, what does "return as nonce" try to mean?
> 
The internet-draft specifies returning a nonce.


> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Acked-by: William Allen Simpson <william.allen.simpson@gmail.com>

> ---
> 
>  net/ipv4/tcp.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff -puN net/ipv4/tcp.c~net-ipv4-tcpc-fix-warning net/ipv4/tcp.c
> --- a/net/ipv4/tcp.c~net-ipv4-tcpc-fix-warning
> +++ a/net/ipv4/tcp.c
> @@ -2540,11 +2540,13 @@ static int do_tcp_getsockopt(struct sock
>  			ctd.tcpct_cookie_desired = cvp->cookie_desired;
>  			ctd.tcpct_s_data_desired = cvp->s_data_desired;
>  
> +#if TCP_MSS_DEFAULT < 256
>  			/* Cookie(s) saved, return as nonce */
>  			if (sizeof(ctd.tcpct_value) < cvp->cookie_pair_size) {
>  				/* impossible? */
>  				return -EINVAL;
>  			}
> +#endif
>  			memcpy(&ctd.tcpct_value[0], &cvp->cookie_pair[0],
>  			       cvp->cookie_pair_size);
>  			ctd.tcpct_used = cvp->cookie_pair_size;
> _
