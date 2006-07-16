From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH] clear skb cb on IP input
Date: Sun, 16 Jul 2006 07:20:35 -0400
Message-ID: <200607161120.k6GBKZEG009486@cmf.nrl.navy.mil>
References: <20060715.181222.74751444.davem@davemloft.net>
Reply-To: chas3@users.sourceforge.net
Cc: herbert@gondor.apana.org.au, shemminger@osdl.org, guichaz@yahoo.fr,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.12.161]:26254 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S1751574AbWGPLVT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Jul 2006 07:21:19 -0400
To: David Miller <davem@davemloft.net>
In-reply-to: <20060715.181222.74751444.davem@davemloft.net> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In message <20060715.181222.74751444.davem@davemloft.net>,David Miller writes:
>From: Herbert Xu <herbert@gondor.apana.org.au>
>> At least this lets us get rid of a few other memsets :)
>> 
>Applied, good spotting :-)  I remember when we added those
>things.
>
>But I'm beginning to think that the onus of this may in fact fall upon
>the devices, in fact.  Loopback is one of the few devices where the
>control block might not be cleared out, due to uses in the output
>path.  Devices predominantly provide a zero'd out control block in the
>skb on packet receive.

the atm layer has the same problem.  some atm device drivers use the
skb cb field, so it needs to be zero'ed by the next upper layer (clip,
lane) before being passed to the ip layer.  its also possible that the
atm layer should clone the skb before passing to the next layer which
would also zeroize the cb.

>Other opinions welcome...

why does the input side of the ip layer believe the cb contains valid
data?  it should zero the contents of the cb, or just fill in the cb
correctly when the packet arrives at its doorstop.
