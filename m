From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next-2.6 0/5] XFRM,IPv6: Removal of RH2/HAO from
 IPsec-protected MIPv6 traffic
Date: Tue, 28 Sep 2010 13:38:49 -0700 (PDT)
Message-ID: <20100928.133849.112575548.davem@davemloft.net>
References: <cover.1285687738.git.arno@natisbad.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, herbert@gondor.apana.org.au,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: arno@natisbad.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37775
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751543Ab0I1Ui3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 16:38:29 -0400
In-Reply-To: <cover.1285687738.git.arno@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaud Ebalard <arno@natisbad.org>
Date: Tue, 28 Sep 2010 17:53:50 +0200

> This an updated version of the patches. For reference, introduction of
> the feature is here http://thread.gmane.org/gmane.linux.network/172941
> Just tell me if you prefer I resend the full intro each time.
> 
> Compared to initial version, this v2 is
> 
>  - against net-next-2.6
>  - fixed and more exhaustively build tested for various kernel
>    configuration (w/ and w/o IPv6, IPv4, MIPv6, XFRM*, RO, ...).
>    It adds some #ifdef but I did not found good ways to spare those.
>  - built and tested on both current linux-2.6 and net-next-2.6 (*)
> 
> Comments welcome.

Try again, this time with ipv6 modular:

net/built-in.o: In function `xfrm_input_addr_check':
/home/davem/src/GIT/net-next-2.6/net/xfrm/xfrm_input.c:115: undefined reference to `xfrm6_input_addr_check'

You can't put xfrm6_input_addr_check into the ipv6.o object build if you want to
call it from the generic xfrm stack which is always built statically.

Put this and xfrm4_input_addr_check where it belongs, as an afinfo->op()


