From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH v2] netfilter: ipset: Fix sleeping memory allocation in
 atomic context
Date: Fri, 16 Oct 2015 11:27:21 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1510161124390.15639@blackhole.kfki.hu>
References: <1444906569-9131-1-git-send-email-kernel@kyup.com>  <1444915978.4200.4.camel@edumazet-glaptop2.roam.corp.google.com>  <561FAD24.4050708@kyup.com>  <1444919523.4200.16.camel@edumazet-glaptop2.roam.corp.google.com>  <alpine.DEB.2.10.1510152015370.12052@blackhole.kfki.hu>
  <1444934818.25595.9.camel@edumazet-glaptop2.roam.corp.google.com>  <CAJFSNy6TaL1padva6euP1-8XFFwPFnBYgsMaEmeWrHpf8AJM-A@mail.gmail.com> <1444942391.25595.11.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Nikolay Borisov <n.borisov@siteground.com>,
	Nikolay Borisov <kernel@kyup.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	SiteGround Operations <operations@siteground.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1444942391.25595.11.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Oct 2015, Eric Dumazet wrote:

> On Thu, 2015-10-15 at 23:20 +0300, Nikolay Borisov wrote:
> 
> > While GFP_ATOMIC does indeed look the correct solution for this particular
> > case I was wondering whether something like (GFP_KERNEL & ~__GFP_WAIT)
> > wouldn't also make the cut without causing sleeping? I guess this is exactly
> > the sort of situation that Mel Gorman's patch can address
> > (marc.info/?l=linux-kernel&m=144283282101953) ?
> 
> This is not applicable here, because the caller would have to find a way
> to keep trying.
> 
> I believe one way to handle this problem (in a followup patch) would be
> to use a work queue for the gc, not a timer.
> 
> Using a timer for gc is almost always subject to big problems anyway.

Thanks, really! I'll work on to replace the timer based gc with a work 
queue based one in the next version.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
