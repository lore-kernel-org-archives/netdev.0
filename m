From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rtnl_mutex deadlock?
Date: Thu, 6 Aug 2015 13:19:01 +0800
Message-ID: <20150806051901.GA14659@gondor.apana.org.au>
References: <CA+55aFwYhdHdLUbYYAc9GgmFuVXniwAESYHuzDWjdapPC0m1Xw@mail.gmail.com>
 <CAHA+R7N2fRz2zr-6MX9StqPLdNAWRiG55xidrC7reSRrVeQPcQ@mail.gmail.com>
 <20150805074330.GA2084@nanopsycho.orion>
 <CA+55aFw1856zEq88RfqoizjeVRR9Ut-ug+VWA+mKFOS77FYpSg@mail.gmail.com>
 <55C25CFB.2060103@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Jiri Pirko <jiri@resnulli.us>,
	Cong Wang <cwang@twopensource.com>,
	David Miller <davem@davemloft.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>, Scott Feldman <sfeldma@gmail.com>,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:44257 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751650AbbHFFTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2015 01:19:38 -0400
Content-Disposition: inline
In-Reply-To: <55C25CFB.2060103@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 05, 2015 at 08:59:07PM +0200, Daniel Borkmann wrote:
> 
> Here's a theory and patch below. Herbert, Thomas, does this make any
> sense to you resp. sound plausible? ;)

Another possibility is the following bug:

https://patchwork.ozlabs.org/patch/503374/

It can cause a use-after-free which may lead to corruption of skb
state, including the cb buffer.  Of course it's a long shot.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
