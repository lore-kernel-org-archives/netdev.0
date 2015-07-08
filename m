From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2] net/bridge: Use __in6_dev_get rather than in6_dev_get
 in br_validate_ipv6
Date: Wed, 8 Jul 2015 11:04:21 +0200
Message-ID: <20150708090421.GA4824@salvia>
References: <1436280921-2795-1-git-send-email-julien.grall@citrix.com>
 <20150707113434.25f77b1e@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julien Grall <julien.grall@citrix.com>,
	xen-devel@lists.xenproject.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Bernhard Thaler <bernhard.thaler@wvnet.at>, fw@strlen.de,
	ian.campbell@citrix.com, wei.liu2@citrix.com,
	Bob Liu <bob.liu@oracle.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150707113434.25f77b1e@urahara>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 07, 2015 at 11:34:34AM -0700, Stephen Hemminger wrote:
> On Tue, 7 Jul 2015 15:55:21 +0100
> Julien Grall <julien.grall@citrix.com> wrote:
> 
> > The commit efb6de9b4ba0092b2c55f6a52d16294a8a698edd "netfilter: bridge:
> > forward IPv6 fragmented packets" introduced a new function
> > br_validate_ipv6 which take a reference on the inet6 device. Although,
> > the reference is not released at the end.
> > 
> > This will result to the impossibility to destroy any netdevice using
> > ipv6 and bridge.
> > 
> > It's possible to directly retrieve the inet6 device without taking a
> > reference as all netfilter hooks are protected by rcu_read_lock via
> > nf_hook_slow.
> > 
> > Spotted while trying to destroy a Xen guest on the upstream Linux:
> > "unregister_netdevice: waiting for vif1.0 to become free. Usage count = 1"
> > 
> > Signed-off-by: Julien Grall <julien.grall@citrix.com>
> > Cc: Bernhard Thaler <bernhard.thaler@wvnet.at>
> > Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> > Cc: fw@strlen.de
> > Cc: ian.campbell@citrix.com
> > Cc: wei.liu2@citrix.com
> > Cc: Bob Liu <bob.liu@oracle.com>
> > 
> > ---
> >     Note that it's impossible to create new guest after this message.
> >     I'm not sure if it's normal.
> > 
> >     Changes in v2:
> >         - Don't take a reference to inet6.
> >         - This was "net/bridge: Add missing in6_dev_put in
> >         br_validate_ipv6" [0]
> > 
> >     [0] https://lkml.org/lkml/2015/7/3/443
> > ---
> >  net/bridge/br_netfilter_ipv6.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> I like this simple solution
> 
> Acked-by: Stephen Hemminger <stephen@networkplumber.org>

Applied, thanks.
