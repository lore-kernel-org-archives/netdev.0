From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [PATCHv2 net-next-2.6 0/5] XFRM,IPv6: Removal of RH2/HAO from IPsec-protected MIPv6 traffic
Date: Tue, 28 Sep 2010 23:33:16 +0200
Message-ID: <87r5gdtuxv.fsf@small.ssi.corp>
References: <cover.1285687738.git.arno@natisbad.org>
	<20100928.133849.112575548.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, herbert@gondor.apana.org.au,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:35465 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752337Ab0I1Vcc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Sep 2010 17:32:32 -0400
In-Reply-To: <20100928.133849.112575548.davem@davemloft.net> (David Miller's
	message of "Tue, 28 Sep 2010 13:38:49 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

David Miller <davem@davemloft.net> writes:

> Try again, this time with ipv6 modular:
>
> net/built-in.o: In function `xfrm_input_addr_check':
> /home/davem/src/GIT/net-next-2.6/net/xfrm/xfrm_input.c:115: undefined reference to `xfrm6_input_addr_check'
>
> You can't put xfrm6_input_addr_check into the ipv6.o object build if you want to
> call it from the generic xfrm stack which is always built statically.
>
> Put this and xfrm4_input_addr_check where it belongs, as an afinfo->op()

Before following the (dumb) #ifdef path, I was about to do that but
worried about the penalty of the additional xfrm_state_get/put_afinfo()
calls on each packet I was about to add. Should I just reduce my amount
of coffee or is it a valid concern?

Cheers,

a+
