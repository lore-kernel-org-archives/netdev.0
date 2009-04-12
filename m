From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Sun, 12 Apr 2009 23:52:03 +0400
Message-ID: <20090412195203.GA11899@ioremap.net>
References: <1239112067.32737.51.camel@dogo.mojatatu.com> <7e0dd21a0904070738jd8a2714wd840352699f1e9f1@mail.gmail.com> <1239137800.21227.10.camel@dogo.mojatatu.com> <20090407211130.GA5918@ioremap.net> <7e0dd21a0904081406w31da460pe1c0c7153538f283@mail.gmail.com> <7e0dd21a0904120327q537956abkf75a17d477cc2e61@mail.gmail.com> <20090412103212.GA28397@ioremap.net> <7e0dd21a0904120423v4296898fl7ce82ec8c3e42d3a@mail.gmail.com> <20090412142451.GA2694@ioremap.net> <7e0dd21a0904121227n3b03f2c7v8bf30c45667603a1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>
To: Johann Baudy <johann.baudy@gnu-log.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cs-studio.ru ([195.178.208.66]:59021 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752614AbZDLTwE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Apr 2009 15:52:04 -0400
Content-Disposition: inline
In-Reply-To: <7e0dd21a0904121227n3b03f2c7v8bf30c45667603a1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 12, 2009 at 09:27:37PM +0200, Johann Baudy (johann.baudy@gnu-log.net) wrote:
> I've seen that during skb_linearize(), skb_shinfo(skb)->frags[i].page
> is not lost even if pages has been put. So I can get back original
> frag address from this info in skb destructor. Can I rely on
> skb_shinfo(skb)->frags[i].page on more complicated sending paths ... ?

skb_shinfo(skb)->frags[i] can be overwritten, for example in
__pskb_pull_tail() at pull_pages: label.

-- 
	Evgeniy Polyakov
