From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH][RFC] tcp: fix ambiguity in the `before' relation
Date: Fri, 5 Jan 2007 11:51:16 +0000
Message-ID: <200701051151.16377@strip-the-willow>
References: <E1H2GGi-0008E5-00@gondolin.me.apana.org.au> <200701041249.02459@strip-the-willow> <20070105035904.GB18653@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:46559 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161071AbXAELuy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jan 2007 06:50:54 -0500
To: Herbert Xu <herbert.xu@redhat.com>
In-Reply-To: <20070105035904.GB18653@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

|  > The key point where the new definition differs from the old is that _the relation_
|  > before(x,y) is unambiguous: the case "before(x,y) && before(y,x)" will no longer occur.
|  
|  This is highly dependent on how the before macro is used in actual code.
|  There is nothing to suggest that this change won't create new security
|  holes in DCCP or any other protocol that uses this macro.  The only
|  way to be sure is to audit every single use.
I fully agree, merely changing the definition means going only half way.
  
|  So I think we need to do one of two things:
|  
|  1) Audit every single before/after check to ensure that it works
|  correctly with the new definition.
For DCCP I will perform such an audit and post the results to dccp@vger. 

With regard to TCP: I am heavily snowed under with other work at the moment. If there
are experienced TCP people on the list who would be happy to look at this, it would be
great. I counted the number of times before() is used - it amounted to 68. There are
of course obvious cases which are quick to dismiss, but in particular the example you
presented yesterday points out that careful analysis is needed.

I asked Dave to revert to the old TCP definition (patch has been committed); for the moment
this seems the safest thing to do.
     
|  2) Change before/after such that before(x, x+2^31) == !before(x+2^31, x).
This is what the new definition does: in the old definition we always have that
before(x, x+2^31) == before(x+2^31, x).
