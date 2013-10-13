From: malc <av1474@comtv.ru>
Subject: Re: [PATCH 2/3] net: bpf jit: x86: optimize choose_load_func error
 path
Date: Sun, 13 Oct 2013 18:25:34 +0400 (MSK)
Message-ID: <alpine.LNX.2.00.1310131824180.2262@linmac>
References: <1381249910-17338-1-git-send-email-murzin.v@gmail.com> <1381249910-17338-2-git-send-email-murzin.v@gmail.com> <20131011.145613.332487610005117559.davem@davemloft.net> <20131013142115.GA1872@hp530>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaffeemonster@googlemail.com, edumazet@google.com,
	mingo@redhat.com, tglx@linutronix.de
To: Vladimir Murzin <murzin.v@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fe01x03-cgp.akado.ru ([77.232.31.164]:61323 "EHLO akado.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754540Ab3JMP0q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Oct 2013 11:26:46 -0400
In-Reply-To: <20131013142115.GA1872@hp530>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 13 Oct 2013, Vladimir Murzin wrote:

> On Fri, Oct 11, 2013 at 02:56:13PM -0400, David Miller wrote:
> > From: Vladimir Murzin <murzin.v@gmail.com>
> > Date: Tue,  8 Oct 2013 20:31:49 +0400
> > 

[..snip..]

> -common_load:			seen |= SEEN_DATAREF;
> +common_load:
> +				if (!func) {
> +					CLEAR_A();
> +					EIT_JMP(cleanup_addr - addrs[i]);

                                        EMIT? (likewise elsewhere)

> +					break;
> +				}
> +
> +				seen |= SEEN_DATAREF;
>  				t_offset = func - (image + addrs[i]);
>  				EMIT1_off32(0xbe, K); /* mov imm32,%esi */
>  				EMIT1_off32(0xe8, t_offset); /* call */
> @@ -624,6 +631,13 @@ common_load:			seen |= SEEN_DATAREF;
>  				goto common_load;
>  			case BPF_S_LDX_B_MSH:
>  				func = CHOOSE_LOAD_FUNC(K, sk_load_byte_msh);
> +
> +				if (!func) {
> +					CLEAR_A();
> +					EIT_JMP(cleanup_addr - addrs[i]);
> +					break;
> +				}
> +
>  				seen |= SEEN_DATAREF | SEEN_XREG;
>  				t_offset = func - (image + addrs[i]);
>  				EMIT1_off32(0xbe, K);	/* mov imm32,%esi */
> 

-- 
mailto:av1474@comtv.ru
