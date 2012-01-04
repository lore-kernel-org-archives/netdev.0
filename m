From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH 1/1] netfilter: Add possibility to turn off netfilters
 defrag per netns
Date: Wed, 4 Jan 2012 19:05:10 +0100 (CET)
Message-ID: <alpine.DEB.2.00.1201041857350.3170@blackhole.kfki.hu>
References: <1325664443-10320-1-git-send-email-hans.schillstrom@ericsson.com> <201201041118.18552.hans.schillstrom@ericsson.com> <alpine.LNX.2.01.1201041216010.2645@frira.zrqbmnf.qr> <201201041248.36881.hans.schillstrom@ericsson.com>
 <20120104174035.GB3489@1984>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-in.kfki.hu ([148.6.0.28]:52419 "EHLO smtp2.kfki.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752272Ab2ADSFN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jan 2012 13:05:13 -0500
In-Reply-To: <20120104174035.GB3489@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 4 Jan 2012, Pablo Neira Ayuso wrote:

> On Wed, Jan 04, 2012 at 12:48:35PM +0100, Hans Schillstrom wrote:
> > I like that idea, an "early" table at prio -500 with PREROUTING.
> > There is also a need for a new flag "--allfrags"
> > i.e. all fragments needs to be sorted out and sent to same dest for defrag.
> > 
> > ex.
> > iptables -t early -A PREROUTING -i eth0 --allfrags -j NOTRACK
> 
> New tables add too much overhead. We have discussed this before with
> Patrick.
> 
> Since this still remains specific to your needs, I think you can
> remove nf_conntrack module in your setup.
> 
> I don't come with one sane setup that may want selectively defragment
> some traffic yes and other not.
> 
> Am I missing anything else?

I agree. If you don't want defragmentation at all, then make sure you 
don't load the nf_conntrack module directly/indirectly. Conntrack doesn't 
work without defragmentation anyway.

The only thing what such a really-early table could buy at the moment is 
to specify which flows not to defragment at layer 3 level.

If we had dynamic hooks registration and hook priorities at table level, 
that'd come handy now.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
