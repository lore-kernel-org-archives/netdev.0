From: "David S. Miller" <davem@redhat.com>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: Sat, 13 Sep 2003 19:25:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030913192522.58705cb0.davem@redhat.com>
References: <200309022116.41697.bdschuym@pandora.be>
	<20030905153152.GA3623@obroa-skai.de.gnumonks.org>
	<20030908191400.5ef59ab6.davem@redhat.com>
	<200309132159.37834.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, acme@conectiva.com.br,
   netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200309132159.37834.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 13 Sep 2003 21:59:37 +0200
Bart De Schuymer <bdschuym@pandora.be> wrote:

> It just uses unsigned int instead of unsigned long, so there should
> be no problem with the evil Sparc64.

Sparc64 doesn't have the problems, it just fixes up the unaligned
accesses there so it'll just be super-slow (some "optimization" :).

The problem is on parisc64 which is very strict about accessing
structure members which are not aligned to the accessor type you use
to dereference and gives you a link/compile error when you violate
this.

> Perhaps the ip_tables.c code from which I copied the original code
> should be altered too.

Yes.

> It's a real optimization btw, the .o file is 32 bytes
> larger when doing the bit operations on a char with i<IFNAMSIZ.
> All hail Rusty :)

I understand, but instead create an arch routine to optimize this
instead of using non-portable constructs.  memcmp_masked() or
something like that.
