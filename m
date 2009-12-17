From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Security: Add prctl(PR_{GET,SET}_NETWORK) interface.
Date: Thu, 17 Dec 2009 18:14:47 +0100
Message-ID: <20091217171447.GJ9804@basil.fritz.box>
References: <20091216155938.GG15031@basil.fritz.box> <20091217012540.GA2609@heat> <fb69ef3c0912170906t291a37c4r6c4758ddc7dd300b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Stone <michael@laptop.org>,
	Andi Kleen <andi@firstfloor.org>,
	Ulrich Drepper <drepper@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>
To: Mark Seaborn <mrs@mythic-beasts.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:47637 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759483AbZLQROt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 12:14:49 -0500
Content-Disposition: inline
In-Reply-To: <fb69ef3c0912170906t291a37c4r6c4758ddc7dd300b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This is not very good because in some situations it is useful to disable
> connect() and bind() while still allowing ptracing of other processes.  For
> example, Plash creates a new UID for each sandbox and it is possible to use
> strace and gdb inside a sandbox.  Currently Plash is not able to block
> network access or allow only limited network access.  If you treat ptrace()
> this way we won't have the ability to use strace and gdb while limiting
> network access.

No that's not what the hunk does. I first thought the same. But it actually
just limits these processes from initiating ptracing themselves. You can still
attach gdb/strace to them.

Now I'm not sure if that's closing all holes, but at least I can't come
up with any obvious ones currently. I think I would still prefer a more
general security container in general.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
