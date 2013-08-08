From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/5] netfilter: add SYNPROXY core/target
Date: Thu, 8 Aug 2013 08:22:55 +0200
Message-ID: <20130808062255.GB24450@macbook.localnet>
References: <1375897371-18430-1-git-send-email-kaber@trash.net>
 <1375897371-18430-4-git-send-email-kaber@trash.net>
 <20130807222600.51eeca09@redhat.com>
 <20130807205602.GA21463@macbook.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, mph@one.com, as@one.com
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130807205602.GA21463@macbook.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 07, 2013 at 10:56:03PM +0200, Patrick McHardy wrote:
> On Wed, Aug 07, 2013 at 10:26:00PM +0200, Jesper Dangaard Brouer wrote:
> > On Wed,  7 Aug 2013 19:42:49 +0200
> > Patrick McHardy <kaber@trash.net> wrote:
> > 
> > Besides when using net->proc_net_stat, then the first entry is usually
> > "entries" which is not percpu, this will likely confusing the tool:
> >   lnstat -f synproxy -c 42
> 
> I'll look into that.

Ok right, the first field must contains something that is not per-CPU.
Unfortunately I don't have anything to put there and I really don't want
to keep any global state. The two possibilities I see are:

- a dummy field
- the number of proxied connections, but not using a global counter but
  gathered by iterating over the entire conntrack hash.

Any opinions?
