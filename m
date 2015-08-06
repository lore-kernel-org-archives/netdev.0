From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rtnl_mutex deadlock?
Date: Thu, 6 Aug 2015 08:30:26 +0800
Message-ID: <20150806003026.GA12785@gondor.apana.org.au>
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
Received: from helcar.hengli.com.au ([209.40.204.226]:34376 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827AbbHFAbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 20:31:08 -0400
Content-Disposition: inline
In-Reply-To: <55C25CFB.2060103@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 05, 2015 at 08:59:07PM +0200, Daniel Borkmann wrote:
>
> Here's a theory and patch below. Herbert, Thomas, does this make any
> sense to you resp. sound plausible? ;)

It's certainly possible.  Whether it's plausible I'm not so sure.
The netlink hashtable is unlimited in size.  So it should always
be expanding, not rehashing.  The bug you found should only affect
rehashing.

> I'm not quite sure what's best to return from here, i.e. whether we
> propagate -ENOMEM or instead retry over and over again hoping that the
> rehashing completed (and no new rehashing started in the mean time) ...

Please use something other than ENOMEM as it is already heavily
used in this context.  Perhaps EOVERFLOW?

We should probably add a WARN_ON_ONCE in rhashtable_insert_rehash
since two concurrent rehashings indicates something is going
seriously wrong.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
