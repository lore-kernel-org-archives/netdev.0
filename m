From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Kernel header changes break glibc build
Date: Wed, 6 Dec 2006 15:23:27 +0100
Message-ID: <20061206142327.GC8693@postel.suug.ch>
References: <Pine.LNX.4.64.0610061718370.18057@digraph.polyomino.org.uk> <1165148731.12649.51.camel@pmac.infradead.org> <20061204091341.GM8693@postel.suug.ch> <1165410114.5253.218.camel@pmac.infradead.org> <20061206134308.GL9556@sunsite.mff.cuni.cz> <20061206135931.GB8693@postel.suug.ch> <1165414039.5253.233.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jakub Jelinek <jakub@redhat.com>, 	Ulrich Drepper <drepper@redhat.com>, 	"Joseph S. Myers" <joseph@codesourcery.com>, netdev@vger.kernel.org, 	libc-alpha@sourceware.org, akpm@osdl.org, 	"David S. Miller" <davem@davemloft.net>
Return-path: <libc-alpha-return-19606-glibc-alpha=m.gmane.org@sourceware.org>
To: David Woodhouse <dwmw2@infradead.org>
Content-Disposition: inline
In-Reply-To: <1165414039.5253.233.camel@pmac.infradead.org>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
List-Id: netdev.vger.kernel.org

* David Woodhouse <dwmw2@infradead.org> 2006-12-06 14:07
> On Wed, 2006-12-06 at 14:59 +0100, Thomas Graf wrote:
> > Are you suggesting that the kernel has to keep macros around which
> > are of no use to the kernel itself just because glibc uses them?
> 
> No, although in fact that _is_ the only reason we use these horrid __uXX
> types rather than proper C datatypes, isn't it?

Alright, so we agree that there must be a possibility of getting rid of
deprecated crap which leads to interface abusage.

Fixing things is as simple as #ifndef IFA_MAX respectively IFLA_RTA in
some compat header.

> I'm suggesting that if you want to change things around as you did, you
> should make sure the users of those headers adapt to cope. You did fix
> the in-kernel users; you neglected to fix glibc -- and as far as I can
> tell you didn't even bother to _warn_ glibc folks.

I didn't warn them because I didn't know better. I was under the
impression that glibc still maintains their own set of headers
and will fix this automatically when they look at the diff. That's
what I do for my userspace applications that use kernel headers.

Ideally install_headers would do the trick but it often fails f.e.
when some application which uses bsd features thus including net/if.h
also wants to use new linux features and includes linux/if.h which
then conflicts.
