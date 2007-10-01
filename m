From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 1/1][TCP]: break missing at end of switch statement
Date: Mon, 1 Oct 2007 18:25:30 +0100
Message-ID: <200710011825.30434@strip-the-willow>
References: <200710011332.43657@strip-the-willow> <200710011439.28676@strip-the-willow> <20071001143108.GA5648@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@st-paulia.net>, netdev@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:62066 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752515AbXJARZu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2007 13:25:50 -0400
In-Reply-To: <20071001143108.GA5648@ghostprotocols.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnaldo, Al Viro, and Yoshifuji -

sorry for having wasted your time with this one. You are right, that was complete nonsense. 
I don't know where my mind was - even my test program used to `prove' this was screwed up.

So nothing wrong here and thank you very much for your clarifying comments.

|  > |  > --- a/net/ipv4/tcp_input.c
|  > |  > +++ b/net/ipv4/tcp_input.c
|  > |  > @@ -3129,6 +3129,7 @@ static void tcp_reset(struct sock *sk)
|  > |  >  			return;
|  > |  >  		default:
|  > |  >  			sk->sk_err = ECONNRESET;
|  > |  > +			break;
|  > |  >  	}
|  > |  >  
|  > |  >  	if (!sock_flag(sk, SOCK_DEAD))
|  > |  
|  > |  NAK; it is not required at all.
|  > |  
|  > |  --yoshfuji
|  > |  
|  > If it were true what you are saying then the statement 
|  > 
|  >        `sk->sk_err = ECONNRESET;' 
|  > 
|  > can go as well since it will always be overridden.
|  
|  Gerrit,
|  
|          It is not required. The statement you mention will be executed
|  when the sk_state is not one of TCP_SYN_SENT, TCP_CLOSE_WAIT or
|  TCP_CLOSE.
|  
|  	A 'break' is only needed in a label block if it is not the last
|  one.
|  
|  - Arnaldo
|  
|  
