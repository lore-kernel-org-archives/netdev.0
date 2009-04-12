From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Sun, 12 Apr 2009 14:32:12 +0400
Message-ID: <20090412103212.GA28397@ioremap.net>
References: <1238701718.5669.26.camel@bender> <20090407072647.GA11480@gondor.apana.org.au> <1239108520.32737.28.camel@dogo.mojatatu.com> <20090407130447.GA14329@gondor.apana.org.au> <1239112067.32737.51.camel@dogo.mojatatu.com> <7e0dd21a0904070738jd8a2714wd840352699f1e9f1@mail.gmail.com> <1239137800.21227.10.camel@dogo.mojatatu.com> <20090407211130.GA5918@ioremap.net> <7e0dd21a0904081406w31da460pe1c0c7153538f283@mail.gmail.com> <7e0dd21a0904120327q537956abkf75a17d477cc2e61@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>
To: Johann Baudy <johann.baudy@gnu-log.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cet.com.ru ([195.178.208.66]:50529 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755241AbZDLKcO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Apr 2009 06:32:14 -0400
Content-Disposition: inline
In-Reply-To: <7e0dd21a0904120327q537956abkf75a17d477cc2e61@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johann.
Sorry for long reply.

On Sun, Apr 12, 2009 at 12:27:04PM +0200, Johann Baudy (johann.baudy@gnu-log.net) wrote:
> Do you mean that skb_shinfo(skb)->frags[i].page will be valid until
> destructor? even if linearized, cloned ....?

Page itself will live until destruction time, when skb is linearized
page is freed, so your own destructor will find that given page is no
longer used, and appropriate memory area can be overwritten.

When skb is cloned, page is untouched, only shared info reference
counter is increased.

-- 
	Evgeniy Polyakov
