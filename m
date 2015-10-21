From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC PATCH 4/5] openvswitch: conntrack netlink API updates.
Date: Wed, 21 Oct 2015 13:18:59 +0200
Message-ID: <20151021111859.GA17991@pox.localdomain>
References: <1445379629-112880-1-git-send-email-jrajahalme@nicira.com>
 <1445379629-112880-4-git-send-email-jrajahalme@nicira.com>
 <20151021104133.GA2135@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarno Rajahalme <jrajahalme@nicira.com>, netdev@vger.kernel.org,
	dev@openvswitch.org, netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151021104133.GA2135@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/21/15 at 12:41pm, Pablo Neira Ayuso wrote:
> On Tue, Oct 20, 2015 at 03:20:28PM -0700, Jarno Rajahalme wrote:
> > diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> > index 77850f1..1e6c2ac 100644
> > --- a/net/openvswitch/flow_netlink.c
> > +++ b/net/openvswitch/flow_netlink.c
> > @@ -291,7 +291,7 @@ size_t ovs_key_attr_size(void)
> >  		+ nla_total_size(4)   /* OVS_KEY_ATTR_SKB_MARK */
> >  		+ nla_total_size(4)   /* OVS_KEY_ATTR_DP_HASH */
> >  		+ nla_total_size(4)   /* OVS_KEY_ATTR_RECIRC_ID */
> > -		+ nla_total_size(1)   /* OVS_KEY_ATTR_CT_STATE */
> > +		+ nla_total_size(4)   /* OVS_KEY_ATTR_CT_STATE */
> >  		+ nla_total_size(2)   /* OVS_KEY_ATTR_CT_ZONE */
> >  		+ nla_total_size(4)   /* OVS_KEY_ATTR_CT_MARK */
> >  		+ nla_total_size(16)  /* OVS_KEY_ATTR_CT_LABEL */
> 
> This is very strange.
> 
> You're changing the size of the netlink attribute, this will break
> existing userspace applications.

This seems to be a temporary forward port of the following commit. The
change is backwards compatible.

commit fbccce5965a58d56aaed9e9acd1bec75d8a66e87
Author: Joe Stringer <joestringer@nicira.com>
Date:   Tue Oct 6 11:00:00 2015 -0700

    openvswitch: Extend ct_state match field to 32 bits

    The ct_state field was initially added as an 8-bit field, however six of
    the bits are already being used and use cases are already starting to
    appear that may push the limits of this field. This patch extends the
    field to 32 bits while retaining the internal representation of 8 bits.
    This should cover forward compatibility of the ABI for the foreseeable
    future.

    This patch also reorders the OVS_CS_F_* bits to be sequential.

    Suggested-by: Jarno Rajahalme <jrajahalme@nicira.com>
    Signed-off-by: Joe Stringer <joestringer@nicira.com>
    Acked-by: Pravin B Shelar <pshelar@nicira.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
