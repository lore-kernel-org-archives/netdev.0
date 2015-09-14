From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm6: Fix ICMPv6 and MH header checks in
 _decode_session6
Date: Mon, 14 Sep 2015 13:52:12 +0200
Message-ID: <20150914115212.GJ25499@secunet.com>
References: <1441958240-29679-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Marcin Jurkowski <marcin1j@gmail.com>, <satmd@lain.at>,
	<netdev@vger.kernel.org>,
	Mathias Krause <mathias.krause@secunet.com>,
	PaX Team <pageexec@freemail.hu>
To: Mathias Krause <minipli@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:37777 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751363AbbINLwR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Sep 2015 07:52:17 -0400
Content-Disposition: inline
In-Reply-To: <1441958240-29679-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 11, 2015 at 09:57:20AM +0200, Mathias Krause wrote:
> From: Mathias Krause <mathias.krause@secunet.com>
> 
> Ensure there's enough data left prior calling pskb_may_pull(). If
> skb->data was already advanced, we'll call pskb_may_pull() with a
> negative value converted to unsigned int -- leading to a huge
> positive value. That won't matter in practice as pskb_may_pull()
> will likely fail in this case, but it leads to underflow reports on
> kernels handling such kind of over-/underflows, e.g. a PaX enabled
> kernel instrumented with the size_overflow plugin.
> 
> Reported-by: satmd <satmd@lain.at>
> Reported-and-tested-by: Marcin Jurkowski <marcin1j@gmail.com>
> Signed-off-by: Mathias Krause <mathias.krause@secunet.com>
> Cc: PaX Team <pageexec@freemail.hu>

Skipping upper layer informations due to a wrong length calculation,
may also leed to incorrect policy lookups. Patch applied to the
ipsec tree, thanks!
