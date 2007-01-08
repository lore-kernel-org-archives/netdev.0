From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH][RFC] tcp: fix ambiguity in the `before' relation
Date: Mon, 8 Jan 2007 08:58:15 +0000
Message-ID: <200701080858.15434@strip-the-willow>
References: <E1H2GGi-0008E5-00@gondolin.me.apana.org.au> <200701051249.13325@strip-the-willow> <20070105203443.GA25173@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:63187 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932634AbXAHI5V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jan 2007 03:57:21 -0500
To: Herbert Xu <herbert.xu@redhat.com>
In-Reply-To: <20070105203443.GA25173@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

|  > Since the old definition is not used in the way "before(x, y) && !before(y, x)", but rather in the
|  > fashion "before(x, y)" or "after(y, x)", the main advantage of the new definition is that it makes
|  > this type of use a safe case. 
|  
|  This is not true because
|  
|  	if (before(x, y))
|  		goto drop;
|  
|  means that you're effectively using it as !before(x, y).  In other words,
|  the change is good if our code read
|  
|  	if (before(x, y))
|  		process_packet();
|  
That is correct - whether it is indeed safe(r) to use needs to be evaluated in the individual context.
