From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Question about an assignment in handle_ing()
Date: Wed, 26 May 2010 09:13:07 +1000
Message-ID: <20100525231307.GA19475@gondor.apana.org.au>
References: <20100524112236.GF2810@psychotron.lab.eng.brq.redhat.com> <1274781067.3878.872.camel@bigi> <20100525102603.GA11494@gondor.apana.org.au> <1274789024.3878.919.camel@bigi> <20100525121202.GA12712@gondor.apana.org.au> <1274790038.3878.926.camel@bigi> <20100525124636.GA13161@gondor.apana.org.au> <1274793216.3878.947.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, kaber@trash.net
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:52779 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759051Ab0EYXNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 19:13:14 -0400
Content-Disposition: inline
In-Reply-To: <1274793216.3878.947.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 25, 2010 at 09:13:36AM -0400, jamal wrote:
> On Tue, 2010-05-25 at 22:46 +1000, Herbert Xu wrote:
> 
> > That's not very surprising as you're not checking whether the
> > skb is cloned in act_pedit.c:
> 
> I meant the test "if (skb_cloned(skb))" failed in such cases;-> So you
> couldnt reliably use it. 
> If it turns out it is unnecessary, what you describe is what i had in
> mind as well.

If it did happen like you said then it would be a serious bug
in our stack as everything else (including the TCP stack) relies
on this.

You can't just make up your own rules :)
 
> It is not the responsibility of the action to drop packets in a pipeline
> rather the responsibility is that of the caller (ref: rule #3 in
> Documentation/networking/tc-actions-env-rules.txt). What to do on a
> failure such as above is programmable by the action user/admin.

But how can the caller make that decision when you return exactly
the same value in the error case as the normal case?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
