From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH 1/1][TCP]: break missing at end of switch statement
Date: Mon, 1 Oct 2007 11:31:08 -0300
Message-ID: <20071001143108.GA5648@ghostprotocols.net>
References: <200710011332.43657@strip-the-willow> <20071001.222059.11266966.yoshfuji@st-paulia.net> <200710011439.28676@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: YOSHIFUJI Hideaki <yoshfuji@st-paulia.net>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:29132 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751892AbXJAObU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 10:31:20 -0400
Received: by nf-out-0910.google.com with SMTP id g13so2936951nfb
        for <netdev@vger.kernel.org>; Mon, 01 Oct 2007 07:31:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200710011439.28676@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Mon, Oct 01, 2007 at 02:39:28PM +0100, Gerrit Renker escreveu:
> Quoting YOSHIFUJI Hideaki:
> | 
> |  > [TCP]: break missing at end of switch statement
> |  > 
> |  > Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> |  > ---
> |  > --- a/net/ipv4/tcp_input.c
> |  > +++ b/net/ipv4/tcp_input.c
> |  > @@ -3129,6 +3129,7 @@ static void tcp_reset(struct sock *sk)
> |  >  			return;
> |  >  		default:
> |  >  			sk->sk_err = ECONNRESET;
> |  > +			break;
> |  >  	}
> |  >  
> |  >  	if (!sock_flag(sk, SOCK_DEAD))
> |  
> |  NAK; it is not required at all.
> |  
> |  --yoshfuji
> |  
> If it were true what you are saying then the statement 
> 
>        `sk->sk_err = ECONNRESET;' 
> 
> can go as well since it will always be overridden.

Gerrit,

        It is not required. The statement you mention will be executed
when the sk_state is not one of TCP_SYN_SENT, TCP_CLOSE_WAIT or
TCP_CLOSE.

	A 'break' is only needed in a label block if it is not the last
one.

- Arnaldo
