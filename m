From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH 1/1] netfilter: Add possibility to turn off netfilters
 defrag per netns
Date: Wed, 4 Jan 2012 22:40:09 +0100 (CET)
Message-ID: <alpine.DEB.2.00.1201042232510.3934@blackhole.kfki.hu>
References: <1325664443-10320-1-git-send-email-hans.schillstrom@ericsson.com> <20120104174035.GB3489@1984> <alpine.DEB.2.00.1201041857350.3170@blackhole.kfki.hu> <201201042156.05586.hans@schillstrom.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hans Schillstrom <hans@schillstrom.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <201201042156.05586.hans@schillstrom.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 4 Jan 2012, Hans Schillstrom wrote:

> On Wednesday, January 04, 2012 19:05:10 Jozsef Kadlecsik wrote:
> > On Wed, 4 Jan 2012, Pablo Neira Ayuso wrote:
> > 
> > > On Wed, Jan 04, 2012 at 12:48:35PM +0100, Hans Schillstrom wrote:
> > > > I like that idea, an "early" table at prio -500 with PREROUTING.
> > > > There is also a need for a new flag "--allfrags"
> > > > i.e. all fragments needs to be sorted out and sent to same dest for defrag.
> > > > 
> > > > ex.
> > > > iptables -t early -A PREROUTING -i eth0 --allfrags -j NOTRACK
> > > 
> > > New tables add too much overhead. We have discussed this before with
> > > Patrick.
> > > 
> > > Since this still remains specific to your needs, I think you can
> > > remove nf_conntrack module in your setup.
> > > 
> > > I don't come with one sane setup that may want selectively defragment
> > > some traffic yes and other not.
> > > 
> > > Am I missing anything else?
> > 
> > I agree. If you don't want defragmentation at all, then make sure you 
> > don't load the nf_conntrack module directly/indirectly. Conntrack doesn't 
> > work without defragmentation anyway.
> 
> We are using LXC and it's only in the container that holds the external 
> interface that can't have defragmentation.
> The problem is if it's loaded you have it in all namespaces :-(

Conntrack is per net namespaces. You may have one container with conntrack 
enabled and another one without conntrack.

Moreover, if you may receive fragments of the same packet at different 
interfaces in different blades, then you may receive different whole 
packets of the same flow at different interfaces/blades. But stateful 
firewalling relies on the assumption that all packets goes through of the 
firewall. Because it's not assured, conntrack may not run in the 
containers you denoted as FW LXC.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
