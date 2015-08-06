From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rtnl_mutex deadlock?
Date: Fri, 7 Aug 2015 07:41:17 +0800
Message-ID: <20150806234117.GA22588@gondor.apana.org.au>
References: <CA+55aFwYhdHdLUbYYAc9GgmFuVXniwAESYHuzDWjdapPC0m1Xw@mail.gmail.com>
 <CAHA+R7N2fRz2zr-6MX9StqPLdNAWRiG55xidrC7reSRrVeQPcQ@mail.gmail.com>
 <20150805074330.GA2084@nanopsycho.orion>
 <CA+55aFw1856zEq88RfqoizjeVRR9Ut-ug+VWA+mKFOS77FYpSg@mail.gmail.com>
 <55C25CFB.2060103@iogearbox.net>
 <20150806003026.GA12785@gondor.apana.org.au>
 <55C3743F.1010900@iogearbox.net>
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
Received: from helcar.hengli.com.au ([209.40.204.226]:56339 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752361AbbHFXlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2015 19:41:55 -0400
Content-Disposition: inline
In-Reply-To: <55C3743F.1010900@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 06, 2015 at 04:50:39PM +0200, Daniel Borkmann wrote:
> 
> Then, in __rhashtable_insert_fast(), I could trigger an -EBUSY when I'm
> really unlucky and exceed the ht->elasticity limit of 16. I would then
> end up in rhashtable_insert_rehash() to find out there's already one
> ongoing and thus, I'm getting -EBUSY via __netlink_insert().

Right, so the only way you can trigger this is if you hit a chain
longer than 16 and the number of entries in the table is less than
75% the size of the table, as well as there being an existing resize
or rehash operation.

This should be pretty much impossible.

But if we had a WARN_ON_ONCE there then we'll know for sure.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
