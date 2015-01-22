From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Thu, 22 Jan 2015 17:49:51 +0100
Message-ID: <20150122164951.GA3417@salvia>
References: <20150120202404.1741.8658.stgit@nitbit.x32>
 <20150122125246.GA4486@salvia>
 <20150122133713.GA25797@casper.infradead.org>
 <20150122140022.GA5674@salvia>
 <54C11094.2000807@mojatatu.com>
 <20150122151316.GB25797@casper.infradead.org>
 <54C11703.7030702@mojatatu.com>
 <20150122153727.GC25797@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com, Jiri Pirko <jiri@resnulli.us>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41715 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750794AbbAVQrA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 11:47:00 -0500
Content-Disposition: inline
In-Reply-To: <20150122153727.GC25797@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 22, 2015 at 03:37:27PM +0000, Thomas Graf wrote:
> On 01/22/15 at 10:28am, Jamal Hadi Salim wrote:
> > On 01/22/15 10:13, Thomas Graf wrote:
> > 
> > >I don't follow this. John's proposal allows to decide on a case by
> > >case basis what we want to export. Just like with ethtool or
> > >RTNETLINK. There is no direct access to hardware. A user can only
> > >configure what is being exposed by the kernel.
> > >
> > 
> > So if i am a vendor with my own driver, I can expose whatever i want.
> 
> No. We will reject any driver change attempting to do so on this
> list.

I think those vendors do not want to push those driver changes
mainstream. They will likely use these new ndo's to fully expose their
vendor-specific capabilities distributed in proprietary blobs.

I remember to have seen one ugly patch for netfilter that added
several hook functions (not netfilter hooks) at different positions of
the NAT code, the goal was to offload NAT through hardware. I was told
the code that was using those ad-hoc hooks was distributed in a binary
blob.

> This is the whole point of this: Coming up with a model that allows
> to describe capabilities and offer flow programming capabilities
> in a Vendor neutral way. A "push_vlan" or "pop_vlan" action will work
> with any driver that supports it.

Right, we need an abstraction for actions too, and the infrastructure
should not provide any means to circunvent and expose vendor specific
details.
