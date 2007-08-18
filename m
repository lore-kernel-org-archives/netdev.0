From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Sat, 18 Aug 2007 07:18:20 +0200
Message-ID: <6db2717888e35173c9f36ef0b8c7b32b@kernel.crashing.org>
References: <20070816003948.GY9645@linux.vnet.ibm.com> <alpine.LFD.0.999.0708160800130.24380@enigma.security.iitk.ac.in> <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in> <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au> <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au> <Pine.LNX.4.64.0708161743500.13267@kivilampi-30.cs.helsinki.fi> <46C4ABA5.9010804@redhat.com> <Pine.LNX.4.64.0708161319000.17777@schroedinger.engr.sgi.com> <c298f0e3f9e49c9dd2d326115d156084@kernel.crashing.org> <alpine.LFD.0.999.0708180002290.3666@enigma.security.iitk.ac.in> <a51ab88dc00f8d7fd44f79400671d259@kernel.crashing.org> <alpine.LFD.0.999.0708180522120.3666@enigma.security.iitk.ac.in> <c0115c88da5d6756502e0c0499faa7
 1f@kernel.crashing.org> <alpine.LFD.0.999.0708! 180556330.3666@enigma.security.iitk.ac.in> <67eca5ac43d3b1dbd1a04c7c36aebd5a@kernel.crashing.org> <alpine.LFD.0.999.0708180833520.3666@enigma!
 .security.iitk.ac.in>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <clameter@sgi.com>,
	Paul Mackerras <paulus@samba.org>, heiko.carstens@de.ibm.com,
	horms@verge.net.au, Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	ak@suse.de, cfriesen@nortel.com, rpjday@mindspring.com,
	Netdev <netdev@vger.kernel.org>, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org, zlynx@acm.org,
	Andrew Morton <akpm@linux-foundation.org>,
	schwidefsky@de.ibm.com, Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, wjiang@resilience.com
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:37895 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750833AbXHRFVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Aug 2007 01:21:09 -0400
In-Reply-To: <alpine.LFD.0.999.0708180833520.3666@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> The documentation simply doesn't say "+m" is allowed.  The code to
>> allow it was added for the benefit of people who do not read the
>> documentation.  Documentation for "+m" might get added later if it
>> is decided this [the code, not the documentation] is a sane thing
>> to have (which isn't directly obvious).
>
> Huh?
>
> "If the (current) documentation doesn't match up with the (current)
> code, then _at least one_ of them has to be (as of current) wrong."
>
> I wonder how could you even try to disagree with that.

Easy.

The GCC documentation you're referring to is the user's manual.
See the blurb on the first page:

"This manual documents how to use the GNU compilers, as well as their
features and incompatibilities, and how to report bugs.  It corresponds
to GCC version 4.3.0.  The internals of the GNU compilers, including
how to port them to new targets and some information about how to write
front ends for new languages, are documented in a separate manual."

_How to use_.  This documentation doesn't describe in minute detail
everything the compiler does (see the source code for that -- no, it
isn't described in the internals manual either).

If it doesn't tell you how to use "+m", and even tells you _not_ to
use it, maybe that is what it means to say?  It doesn't mean "+m"
doesn't actually do something.  It also doesn't mean it does what
you think it should do.  It might do just that of course.  But treating
writing C code as an empirical science isn't such a smart idea.

> And I didn't go whining about this ... you asked me. (I think I'd said
> something to the effect of GCC docs are often wrong,

No need to guess at what you said, even if you managed to delete
your own mail already, there are plenty of free web-based archives
around.  You said:

> See, "volatile" C keyword, for all it's ill-definition and dodgy
> semantics, is still at least given somewhat of a treatment in the C
> standard (whose quality is ... ummm, sadly not always good and clear,
> but unsurprisingly, still about 5,482 orders-of-magnitude times
> better than GCC docs).

and that to me reads as complaining that the ISO C standard "isn't
very good" and that the GCC documentation is 10**5482 times worse
even.  Which of course is hyperbole and cannot be true.  It also
isn't helpful in any way or form for anyone on this list.  I call
that whining.

> which is true,

Yes, documentation of that size often has shortcomings.  No surprise
there.  However, great effort is made to make it better documentation,
and especially to keep it up to date; if you find any errors or
omissions, please report them.  There are many ways how to do that,
see the GCC homepage.</end-of-marketing-blurb>

> but probably you feel saying that is "not allowed" on non-gcc lists?)

You're allowed to say whatever you want.  Let's have a quote again
shall we?  I said:

> If you find any problems/shortcomings in the GCC documentation,
> please file a PR, don't go whine on some unrelated mailing lists.
> Thank you.

I read that as a friendly request, not a prohibition.  Well maybe
not actually friendly, more a bit angry.  A request, either way.

> As for the "PR"

"Problem report", a bugzilla ticket.  Sorry for using terminology
unknown to you.

> you're requesting me to file with GCC for this, that
> gcc-patches@ thread did precisely that

Actually not -- PRs make sure issues aren't forgotten (although
they might gather dust, sure).  But yes, submitting patches is a
Great Thing(tm).

> and more (submitted a patch to
> said documentation -- and no, saying "documentation might get added
> later" is totally bogus and nonsensical -- documentation exists to
> document current behaviour, not past).

When code like you want to write becomes a supported feature, that
will be reflected in the user manual.  It is completely nonsensical
to expect everything that is *not* a supported feature to be mentioned
there.

> I wouldn't have replied, really, if you weren't so provoking.

Hey, maybe that character trait is good for something, then.
Now to build a business plan around it...


Segher

