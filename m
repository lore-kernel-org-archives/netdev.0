From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next 14/22] vxlan: Flow based tunneling
Date: Mon, 20 Jul 2015 14:41:05 -0300
Message-ID: <20150720174105.GA21405@localhost.localdomain>
References: <cover.1437137396.git.tgraf@suug.ch>
 <f5cf9490a8f114416ec24e9e1de190d6640f25f0.1437137396.git.tgraf@suug.ch>
 <20150720171522.GA14393@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, stephen@networkplumber.org, jpettit@nicira.com,
	kaber@trash.net, simon.horman@netronome.com,
	joestringer@nicira.com, ja@ssi.bg, ast@plumgrid.com,
	weichunc@plumgrid.com, netdev@vger.kernel.org, dev@openvswitch.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38623 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756611AbbGTRlR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jul 2015 13:41:17 -0400
Content-Disposition: inline
In-Reply-To: <20150720171522.GA14393@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 20, 2015 at 02:15:22PM -0300, Marcelo Ricardo Leitner wrote:
> On Fri, Jul 17, 2015 at 02:55:33PM +0200, Thomas Graf wrote:
> 
> [ snip ]
> 
> > @@ -2373,6 +2470,12 @@ static void vxlan_setup(struct net_device *dev)
> >  	netif_keep_dst(dev);                     ---> (a)
> >  	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
> >  
> > +	/* If in flow based mode, keep the dst including encapsulation
> > +	 * instructions for vxlan_xmit().
> > +	 */
> > +	if (vxlan->flags & VXLAN_F_FLOW_BASED)
> > +		netif_keep_dst(dev);             ---> (b)
> > +
> >  	INIT_LIST_HEAD(&vxlan->next);
> >  	spin_lock_init(&vxlan->hash_lock);
> >  
> 
> Sounds like after 0287587884b1 ("net: better IFF_XMIT_DST_RELEASE
> support"), which introduced (a) above, (b) is not needed?

Oops, it was already reported by Alexei.

  Marcelo
