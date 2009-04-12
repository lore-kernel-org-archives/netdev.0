From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Mon, 13 Apr 2009 00:53:34 +0400
Message-ID: <20090412205334.GA14345@ioremap.net>
References: <1239137800.21227.10.camel@dogo.mojatatu.com> <20090407211130.GA5918@ioremap.net> <7e0dd21a0904081406w31da460pe1c0c7153538f283@mail.gmail.com> <7e0dd21a0904120327q537956abkf75a17d477cc2e61@mail.gmail.com> <20090412103212.GA28397@ioremap.net> <7e0dd21a0904120423v4296898fl7ce82ec8c3e42d3a@mail.gmail.com> <20090412142451.GA2694@ioremap.net> <7e0dd21a0904121227n3b03f2c7v8bf30c45667603a1@mail.gmail.com> <20090412195203.GA11899@ioremap.net> <7e0dd21a0904121330p3fe9b27bx1cd16a6c8fb9b574@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>
To: Johann Baudy <johann.baudy@gnu-log.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netgear.net.ru ([195.178.208.66]:40231 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752429AbZDLUxg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Apr 2009 16:53:36 -0400
Content-Disposition: inline
In-Reply-To: <7e0dd21a0904121330p3fe9b27bx1cd16a6c8fb9b574@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 12, 2009 at 10:30:34PM +0200, Johann Baudy (johann.baudy@gnu-log.net) wrote:
> Where do you see that skb_shinfo(skb)->frags[i].page (not other
> fields) can be overwritten ?

pull_pages:
	eat = delta;
	k = 0;
	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
		if (skb_shinfo(skb)->frags[i].size <= eat) {
			put_page(skb_shinfo(skb)->frags[i].page);
			eat -= skb_shinfo(skb)->frags[i].size;
		} else {
			skb_shinfo(skb)->frags[k] = skb_shinfo(skb)->frags[i];


-- 
	Evgeniy Polyakov
