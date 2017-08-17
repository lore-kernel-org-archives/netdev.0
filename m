From: Eric Garver <e@erig.me>
Subject: Re: [ovs-dev] [PATCH v3] openvswitch: enable NSH support
Date: Thu, 17 Aug 2017 10:14:14 -0400
Message-ID: <20170817141414.GA21173@dev-rhel7>
References: <1502861730-76203-1-git-send-email-yi.y.yang@intel.com>
 <20170816151528.GG27729@dev-rhel7>
 <20170816234940.GB123125@cran64.bj.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org, jbenc@redhat.com
To: "Yang, Yi" <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40544 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752484AbdHQOON (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 10:14:13 -0400
Content-Disposition: inline
In-Reply-To: <20170816234940.GB123125@cran64.bj.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 17, 2017 at 07:49:41AM +0800, Yang, Yi wrote:
> On Wed, Aug 16, 2017 at 11:15:28PM +0800, Eric Garver wrote:
> > On Wed, Aug 16, 2017 at 01:35:30PM +0800, Yi Yang wrote:
> > > +
> > > +#define NSH_DST_PORT    4790     /* UDP Port for NSH on VXLAN. */
> > > +#define ETH_P_NSH       0x894F   /* Ethertype for NSH. */
> > 
> > ETH_P_NSH probably belongs in include/uapi/linux/if_ether.h with all the
> > other ETH_P_* defines.
> > 
> 
> Ok, I'll move it to include/uapi/linux/if_ether.h, but in userspace, we
> still need to keep it in nsh.h.
> 
> > >  
> > > +struct ovs_key_nsh {
> > > +	__u8 flags;
> > > +	__u8 mdtype;
> > > +	__u8 np;
> > > +	__u8 pad;
> > > +	__be32 path_hdr;
> > > +	__be32 context[NSH_MD1_CONTEXT_SIZE];
> > > +};
> > > +
> > >  struct sw_flow_key {
> > >  	u8 tun_opts[IP_TUNNEL_OPTS_MAX];
> > >  	u8 tun_opts_len;
> > > @@ -144,6 +154,7 @@ struct sw_flow_key {
> > >  			};
> > >  		} ipv6;
> > >  	};
> > > +	struct ovs_key_nsh nsh;         /* network service header */
> > 
> > Are you intentionally not reserving space in the flow key for
> > OVS_NSH_KEY_ATTR_MD2? I know it's not supported yet, but much of the
> > code is stubbed out for it - just making sure this wasn't an oversight.
> > 
> 
> For MD type 2, we'll reuse tun_metedata keys in struct flow_tnl which
> will be reworked and it will be shared by NSH and GENEVE, so we won't
> have new keys in "struct ovs_key_nsh" for MD type 2.

Be careful here. VXLAN also uses tun_metadata for GBP. VXLAN-GPE (+ NSH)
and VXLAN-GBP are mutually exclusive AFAICS, but you should verify it
all behaves as expected.

[..]
