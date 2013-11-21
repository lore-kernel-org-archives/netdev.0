From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net v3] vti: fix spd lookup: match plaintext pkt, not
 ipsec pkt
Date: Thu, 21 Nov 2013 12:45:53 +0100
Message-ID: <20131121114553.GC31491@secunet.com>
References: <1383646612-30103-1-git-send-email-christophe.gouault@6wind.com>
 <1383725153-26298-1-git-send-email-christophe.gouault@6wind.com>
 <20131107112549.GP31491@secunet.com>
 <527B8DC5.6080702@6wind.com>
 <1902752B0C92F943AB7EA9EE13E2DEEC1273BA977C@HQ1-EXCH02.corp.brocade.com>
 <528DDB5F.8080400@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Saurabh Mohan <saurabh.mohan@brocade.com>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Collins <bsderandrew@gmail.com>,
	Fan Du <fan.du@windriver.com>
To: Christophe Gouault <christophe.gouault@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:33337 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753733Ab3KULqG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Nov 2013 06:46:06 -0500
Content-Disposition: inline
In-Reply-To: <528DDB5F.8080400@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 21, 2013 at 11:07:27AM +0100, Christophe Gouault wrote:
> 
> But you can optionally apply differentiated policies within the same
> tunnel, by setting SPs with narrower selectors: according to the
> plaintext traffic that crosses the tunnel, you can request to use
> different protocols (esp/ah), different SAs, maybe drop some traffic.

This raises the question about the MTU of a vti device. If the SA
is not unique, it is not clear which MTU we should use for that device.

> Only ipsec tunnel mode and drop policies should be bound to a VTI interface.
> 
> And the patch restores the SP semantics: the selector is used to match
> the plaintext traffic, not the IPsec encrypted traffic.
> 

On the other hand, I've spend quite some time to figure out how
inter address family tunneling can work with vti devices. It
seems that we need plaintext matching to get this to work.
