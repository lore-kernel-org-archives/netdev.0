From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: Conforming to -D_FORTIFY_SOURCE=2
 restrictions
Date: Mon, 17 Oct 2011 08:23:07 -0700
Message-ID: <20111017082307.46a994a8@nehalam.linuxnetplumber.net>
References: <CAGBH1r6P_nmVhSQ7d9sj1qU_1VY7QssWm3ftS4mNcQjyAuCcqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Bin Li <libin.charles@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43684 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751171Ab1JQPXK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Oct 2011 11:23:10 -0400
In-Reply-To: <CAGBH1r6P_nmVhSQ7d9sj1qU_1VY7QssWm3ftS4mNcQjyAuCcqA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Oct 2011 15:35:35 +0800
Bin Li <libin.charles@gmail.com> wrote:

> (gdb) l
> 161                     len = slen;
> 162                     if (len > 0) {
> 163                             if (len > max)
> 164                                     invarg("\"ALGOKEY\" makes buffer
> overflow\n", key);
> 165
> 166                             strncpy(buf, key, len);
> 167                     }
> 168             }
> 169
> 170             alg->alg_key_len = len * 8;
> (gdb) up
> #8  xfrm_state_modify (cmd=<optimized out>, flags=<optimized out>, argc=1,
>     argv=0x7fffffffe370) at xfrm_state.c:406
> 406                                     xfrm_algo_parse((void *)&alg, type,
> name, key,
> 
> the compiler passes zero to __builtin___strncpy_chk as the buffer size.
> xfrm_algo_parse is inlined into xfrm_state_modify.

I don't understand, looks like a compiler bug. Call strncpy with
0 length should not be possible since the check was  3 lines
before for len > 0.
