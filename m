From: David Miller <davem@davemloft.net>
Subject: Re: authenc compile warnings in current net-2.6.24
Date: Wed, 10 Oct 2007 16:25:28 -0700 (PDT)
Message-ID: <20071010.162528.91758998.davem@davemloft.net>
References: <470D11B1.2040207@hartkopp.net>
	<20071010195337.GA21597@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: socketcan@hartkopp.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: netdev@ml.breakpoint.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60770
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756821AbXJJXZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 19:25:26 -0400
In-Reply-To: <20071010195337.GA21597@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sebastian Siewior <netdev@ml.breakpoint.cc>
Date: Wed, 10 Oct 2007 21:53:37 +0200

> * Oliver Hartkopp | 2007-10-10 19:53:53 [+0200]:
> 
> > CC [M] crypto/authenc.o
> > crypto/authenc.c: In function ?crypto_authenc_hash?:
> > crypto/authenc.c:88: warning: ?cryptlen? may be used uninitialized in this 
> > function
> > crypto/authenc.c:87: warning: ?dst? may be used uninitialized in this 
> > function
> > crypto/authenc.c: In function ?crypto_authenc_decrypt?:
> > crypto/authenc.c:163: warning: ?cryptlen? may be used uninitialized in this 
> > function
> > crypto/authenc.c:163: note: ?cryptlen? was declared here
> > crypto/authenc.c:162: warning: ?src? may be used uninitialized in this 
> > function
> > crypto/authenc.c:162: note: ?src? was declared here
> >
> > do you already know these warnings?
> 
> Those warnings are looking like a compiler bug to me.

It's just not smart enough to see that cryptlen's initialization
and it's use in the auth_unlock label path are both protected
by 'err' being non-zero.

To be honest I don't know of any compiler which commits enough
flow variable analysis to support doing %100 accurate warnings
in situations like this.

Since the compiler is unlikely to do so, I think we should fix
it somehow because useless warnings just distract.
