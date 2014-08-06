From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: ip6tables filter breakage.
Date: Thu, 7 Aug 2014 00:01:35 +0200
Message-ID: <20140806215638.GA31519@salvia>
References: <20140806195222.GA10618@redhat.com>
 <20140806.131354.1888027200650409969.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davej@redhat.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140806.131354.1888027200650409969.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 06, 2014 at 01:13:54PM -0700, David Miller wrote:
> From: Dave Jones <davej@redhat.com>
> Date: Wed, 6 Aug 2014 15:52:22 -0400
> 
> CC:'ing netfilter-devel, Dave please do this in the future for
> netfilter reports, thanks.
> 
> > After updating to Linus' current tree with todays net/ merge,
> > I noticed that ip6tables doesn't work any more..
> > 
> > # ip6tables -F
> > ip6tables v1.4.19.1: can't initialize ip6tables table `filter': No
> > chain/target/match by that name
> > Perhaps ip6tables or your kernel needs to be upgraded
> > 
> > My config has CONFIG_IP6_NF_FILTER=m
> > I also note that ip6table_filter.ko doesn't get auto-loaded now.
> > But even after modprobing it, I get the same message.
> > 
> > Is there some additional option I now need to enable ?
> > 
> > 
> > I was a little surprised by how CONFIG_NF_TABLES is mandatory
> > for iptables to keep working, even if you don't have nft userspace.
> > (The only relevant thing in the Kconfig was related to x_tables,
> >  which I wasn't using).
> > 
> > Perhaps either some select's, or additional help text ?

Cc'ing Tom:

cb1ce2e ipv6: Implement automatic flow label generation on transmit
has allocated socket option 64 which is already reserved by ip6tables.

I'm going to send a patch to fix this.
