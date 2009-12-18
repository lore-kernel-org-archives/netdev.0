From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 1/3] Security: Add prctl(PR_{GET,SET}_NETWORK)
 interface. (v2)
Date: Fri, 18 Dec 2009 15:46:34 +0000
Message-ID: <20091218154634.79decdc4@lxorguk.ukuu.org.uk>
References: <20091218030056.GC3047@heat>
	<20091218032957.GA23514@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mark Seaborn <mrs@mythic-beasts.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?ISO-8859-14?B?QW3pcmljbw==?= Wang <xiyou.wangcong@gmail.com>,
	Michael Stone <michael@laptop.org>
To: Michael Stone <michael@laptop.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20091218032957.GA23514@heat>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 17 Dec 2009 22:29:57 -0500
Michael Stone <michael@laptop.org> wrote:

> Daniel Bernstein has observed [1] that security-conscious userland processes

Dan Bernstein has observed many things .. ;)

> may benefit from the ability to irrevocably remove their ability to create,
> bind, connect to, or send messages except in the case of previously connected
> sockets or AF_UNIX filesystem sockets. We provide this facility by implementing
> support for a new prctl(PR_SET_NETWORK) flag named PR_NETWORK_OFF.

This is a security model, it belongs as a security model using LSM. You
can already do it with SELinux and the like as far as I can see but
that's not to say you shouldn't submit it also as a small handy
standalone security module for people who don't want to load the big
security modules.

Otherwise you end up putting crap in fast paths that nobody needs but
everyone pays for and weird tests and hacks for address family and like
into core network code.

The fact the patches look utterly ugly should be telling you something -
which is that you are using the wrong hammer
