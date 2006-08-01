From: Andi Kleen <ak@suse.de>
Subject: Re: [IPV6]: Audit all ip6_dst_lookup/ip6_dst_store calls
Date: Tue, 1 Aug 2006 19:24:10 +0200
Message-ID: <200608011924.10534.ak@suse.de>
References: <20060728194531.GA17744@lists.us.dell.com> <20060731090433.GA25192@gondor.apana.org.au> <20060801074133.b5b96f11.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Jan Beulich <jbeulich@novell.com>, mingo@elte.hu,
	arjan@infradead.org, Matt_Domsch@dell.com, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751694AbWHAR1G@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060801074133.b5b96f11.akpm@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 01 August 2006 16:41, Andrew Morton wrote:
> On Mon, 31 Jul 2006 19:04:33 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > 2) There is something broken in the x86_64 unwind code which is causing
> > it to panic just about everytime somebody calls dump_stack().
> > 
> > Andi, this is the second time I've seen a report where an otherwise
> > harmless dump_stack call (the other one was caused by a WARN_ON) gets
> > turned into a panic by the stack unwind code on x86_64.  This particular
> > report is with 2.6.18-rc3 so it looks like whatever bug is causing it
> > hasn't been fixed yet.
> > 
> > Could you please have a look at it? Thanks.
> 
> Jan thinks this might have been fixed by a patch which he sent Andi a
> couple of days ago.  Andi has sent that patch to Linus

I didn't send that particular patch before, just queued it, because I didn't realize
that particular crash, but I have now send it yesterday. So far L. hasn't merged
it unfortunately, but I will resend.

> but I'm not sure 
> which patch it was
 
"entry-more-unwind" was my version, there was another one from Jan

> and I'm not sure whether it has been merged into 
> mainline.
> 
> But yes, -rc3 unwind has problems.

"unwinder stuck" messages are expected and not really fatal because they
don't lose any information. I expect it will need some releases to work
them all out fully, but then we'll hopefully have a much better unwinder
that doesn't generate any false positives anymore.

New crashes during unwinding are fatal though and I plan to fix them.
So far this one was the only known one.

I already got a lot of patches queued for .19 that fix more unwind
information in a lot of assembly files. Still not fully complete though.
Fixing it all properly unfortunately requires undoing some stuff, e.g.
the unwinder cannot deal with separate lock sections, so I was slowly
removing them.

-Andi
