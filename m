From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [PATCH 1/1] netfilter: Add possibility to turn off netfilters defrag per netns
Date: Wed, 4 Jan 2012 21:56:05 +0100
Message-ID: <201201042156.05586.hans@schillstrom.com>
References: <1325664443-10320-1-git-send-email-hans.schillstrom@ericsson.com> <20120104174035.GB3489@1984> <alpine.DEB.2.00.1201041857350.3170@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1201041857350.3170@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wednesday, January 04, 2012 19:05:10 Jozsef Kadlecsik wrote:
> On Wed, 4 Jan 2012, Pablo Neira Ayuso wrote:
> 
> > On Wed, Jan 04, 2012 at 12:48:35PM +0100, Hans Schillstrom wrote:
> > > I like that idea, an "early" table at prio -500 with PREROUTING.
> > > There is also a need for a new flag "--allfrags"
> > > i.e. all fragments needs to be sorted out and sent to same dest for defrag.
> > > 
> > > ex.
> > > iptables -t early -A PREROUTING -i eth0 --allfrags -j NOTRACK
> > 
> > New tables add too much overhead. We have discussed this before with
> > Patrick.
> > 
> > Since this still remains specific to your needs, I think you can
> > remove nf_conntrack module in your setup.
> > 
> > I don't come with one sane setup that may want selectively defragment
> > some traffic yes and other not.
> > 
> > Am I missing anything else?
> 
> I agree. If you don't want defragmentation at all, then make sure you 
> don't load the nf_conntrack module directly/indirectly. Conntrack doesn't 
> work without defragmentation anyway.

We are using LXC and it's only in the container that holds the external 
interface that can't have defragmentation.
The problem is if it's loaded you have it in all namespaces :-(

> 
> The only thing what such a really-early table could buy at the moment is 
> to specify which flows not to defragment at layer 3 level.
> 
> If we had dynamic hooks registration and hook priorities at table level, 
> that'd come handy now.

I do agree.

> 

Regards
Hans
