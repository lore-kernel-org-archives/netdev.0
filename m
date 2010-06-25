From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 6/8] netpoll: Allow netpoll_setup/cleanup recursion
Date: Fri, 25 Jun 2010 10:46:47 +0200
Message-ID: <20100625084647.GA4914@elte.hu>
References: <20100624182123.45264dfe.akpm@linux-foundation.org>
 <20100624.203006.35035648.davem@davemloft.net>
 <20100624205059.a28756b0.akpm@linux-foundation.org>
 <20100624.212713.242141362.davem@davemloft.net>
 <20100624214204.a85c8ba2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, herbert@gondor.hengli.com.au,
	mst@redhat.com, frzhang@redhat.com, netdev@vger.kernel.org,
	amwang@redhat.com, shemminger@vyatta.com, mpm@selenic.com,
	paulmck@linux.vnet.ibm.com, a.p.zijlstra@chello.nl,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100624214204.a85c8ba2.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Andrew Morton <akpm@linux-foundation.org> wrote:

> On Thu, 24 Jun 2010 21:27:13 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
> 
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Date: Thu, 24 Jun 2010 20:50:59 -0700
> > 
> > > What happens if you want to actually *drop* a patch from net-next? 
> > > Surely that happens?
> > 
> > I've only respun the tree on two or three occasions and that was
> > because I made some significant error myself and screwed up the
> > GIT tree somehow.
> > 
> > We've fixed much worse bugs than this one weeks after the changes
> > causing them went in, life goes on.
> 
> Still sucks - this is a quite ugly drawback to how we're using git. 
> I've hit bisection holes several times which held up the show. 
> Sometimes you can make them go away by fiddling the .config, other
> times I've hunted down the fix and manually applied it for each
> iteration.  It makes me feel all guilty each time I ask some poor sap
> to bisect a bug for us.

One solution would be, for really grave bugs that introduce a significant 
window of bisection breakage, to add a special tag:

  Fixes-Bug: SHA1

Which could then be parsed by a special variant of git bisect and which would 
try to cherry-pick all Fixes-Bug commits into the bisection point.

But there are numerous disadvantages that:

 - The bisection itself would be slower (maybe not a big issue for most 
   bisection sessions)

 - Such cherry-picked trees wouldnt be precisely the same thing as the tree 
   as-it-was-there.

 - Awkward combination bugs could ensue

 - The cherry-pick may fail or may mis-apply things.

 - If the Fixes-Bug tag is typoed or misconstrued then that might not be found 
   until someone tries a bisection and fails ... leading to awkward 
   add-the-tag-again-to-some-commit scenarios.

My gut feeling is that we really dont want to go there. As painful as 
bisection breakages are, they are relatively rare (compared to regular 
regressions), and the value of testing _that precise_ sha1 is a fundamental 
thing - git bisect shouldnt interact and reorder fixes.

If a bug wasnt found sooner then it either didnt matter that much, or the tree 
QA was bad. Neither of those factors forces a change in the development model.

	Ingo
