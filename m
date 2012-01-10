From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/1] netfilter: Add possibility to turn off netfilters
 defrag per netns
Date: Tue, 10 Jan 2012 04:17:14 +0100
Message-ID: <20120110031714.GA31483@1984>
References: <1325664443-10320-1-git-send-email-hans.schillstrom@ericsson.com>
 <alpine.DEB.2.00.1201050959030.5244@blackhole.kfki.hu>
 <20120105141859.GA8210@1984>
 <201201090958.43017.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201201090958.43017.hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Hans,

On Mon, Jan 09, 2012 at 09:58:42AM +0100, Hans Schillstrom wrote:
> > I wonder if we can conditionally register the sysctl only if we are
> > inside one lxc container.
> > 
> Sure no problem, but the code will not be so nice ... 

Indeed, ugly indeed.

> > I'm telling this because this sysctl does not seem to make any sense
> > to me outside of it.
> 
> I'm not so sure that we should make it asymetric,
> but it's not a big deal.
> 
> Anyway here is a sample of the sysctl in a namespace.
> It is the  "if (!net_eq(net, &init_net)) {..." that does the magic

Hm, after having a look at it, I think I prefer to provide some
inconditional sysctl.

Better call it nf_conntrack_enable and set it to 1 by default. AFAICS,
this will be a synonymous of:

iptables -I PREROUTING -t raw -j NOTRACK

This option is disabling conntracking after all. I don't think we
would ever support conntrack with fragments.

Please, send a patch including in the description that we need this
for lxc, I'll enqueue it for net-next unless someone raise the hand
with a better solution.

Thanks.
