From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/3] Security: Implement prctl(PR_SET_NETWORK, PR_NETWORK_OFF) semantics. (v2)
Date: Thu, 17 Dec 2009 19:57:09 -0800
Message-ID: <m16385vsru.fsf@fess.ebiederm.org>
References: <20091218030056.GC3047@heat> <20091218033128.GB23514@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Seaborn <mrs@mythic-beasts.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	Bernie Innocenti <bernie@codewiz.org>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
To: Michael Stone <michael@laptop.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20091218033128.GB23514@heat> (Michael Stone's message of "Thu\, 17 Dec 2009 22\:31\:28 -0500")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Stone <michael@laptop.org> writes:

> Return -EPERM any time we try to __sock_create(), sys_connect(), sys_bind(),
> sys_sendmsg(), or __ptrace_may_access() from a process with PR_NETWORK_OFF set
> in current->network unless we're working on a socket which is already connected
> or on a non-abstract AF_UNIX socket.

It appears to me that the current security hooks are sufficient for what
you are doing.

The one true security module business prevents you from actually using the
security hooks, but could you create wrappers for the network security
hooks so the logic of the network stack does not need to change.

At the very least the huge separation of the test for AF_UNIX and
the test to see if it is a an anonymous AF_UNIX socket is pretty
large.  Structuring the code in such a way as to keep that together would
be nice.

Eric
