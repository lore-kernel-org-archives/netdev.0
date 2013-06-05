From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PULL] vhost: cleanups and fixes
Date: Wed, 5 Jun 2013 18:53:38 +0300
Message-ID: <20130605155338.GA26561@redhat.com>
References: <20130502105353.GA24655@redhat.com>
 <1367520929.23900.114.camel@haakon3.risingtidesystems.com>
 <20130502193309.GC16031@redhat.com>
 <CA+55aFwwVMhmmJfWoepipWT+WQZHt4gRPKSucgBABe5Rq=kVkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	KVM list <kvm@vger.kernel.org>, virtualization@lists.osdl.org,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Asias He <asias@redhat.com>,
	target-devel <target-devel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFwwVMhmmJfWoepipWT+WQZHt4gRPKSucgBABe5Rq=kVkw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 02, 2013 at 12:49:42PM -0700, Linus Torvalds wrote:
> On Thu, May 2, 2013 at 12:33 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> >
> > I prefer not rebasing,
> 
> Good.
> 
> >                   will play with git to see why
> > does request-pull get me a wrong diffstat and how
> > to trick it into doing the right thing.
> > Maybe merging my branch into master will do this.
> 
> No, don't do an unnecessary merge just to get the diffstat right.
> 
> git pull-request ends up assuming that there are no back-merges, and
> that you have a uniquely defined single shared merge base. That allows
> pull-request to just generate the diff directly from that merge base,
> without actually trying to do the merge itself (which may have
> conflicts etc).
> 
> But because git pull-request doesn't actually *do* the merge, it means
> that it will fail to give the correct diffstat if the tree is
> complicated and has multiple merge bases, and it can't really figure
> what the original shared state was before the development.
> 
> This is just one reason I do *not* want to see back-merges. They make
> history harder to read not just for humans.
> 
> You can either ignore the problem (I'll see the real diffstat when I
> actually do the merge), or you can do a test-merge yourself (that you
> do *not* then push out in the development branch - keep it in a
> temporary branch for your own edification or just delete it after
> doing the merge, and don't do development on it!)
> 
> In this case, it's an indirect back-merge: you back-merged a commit
> from the target tree that I have now merged, so it has become a
> back-merge. I'm not sure why you did that - if you needed to start
> from that state, it would actually have been better to just start at
> that state instead of merging it.

OK I'm in that situation again. I have some vhost-net patches that depend on
changes in tip.
But I also have a vhost-next branch with unrelated changes, that
I started from -rc3.

Previously I would just merge tip into vhost-next, then everyone's
happy, but it will create an implicit back-merge again, won't it?

So what should I do?

Sorry about being dense.

> But whatever. You can get the
> diffstat by using your merge as the base, so
> 
>     git diff -M --stat --summary bc7562355fda..
> 
> in your branch should get the right result without any merges etc..
> But please do send me a proper pull request.
> 
>               Linus
