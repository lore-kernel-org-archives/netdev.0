From: "Yang, Yi" <yi.y.yang@intel.com>
Subject: Re: [PATCH net-next v14] openvswitch: enable NSH support
Date: Wed, 1 Nov 2017 12:04:36 +0800
Message-ID: <20171101040435.GA66272@localhost.localdomain>
References: <1509326974-3750-1-git-send-email-yi.y.yang@intel.com>
 <20171031195741.GR22092@dev-rhel7>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "jbenc@redhat.com" <jbenc@redhat.com>,
        "pshelar@ovn.org" <pshelar@ovn.org>,
        "davem@davemloft.net" <davem@davemloft.net>
To: Eric Garver <e@erig.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:19824 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750766AbdKAEJf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 00:09:35 -0400
Content-Disposition: inline
In-Reply-To: <20171031195741.GR22092@dev-rhel7>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 01, 2017 at 03:57:41AM +0800, Eric Garver wrote:
> On Mon, Oct 30, 2017 at 09:29:34AM +0800, Yi Yang wrote:
> [...]
> > +int nsh_pop(struct sk_buff *skb)
> > +{
> > +	struct nshhdr *nh;
> > +	size_t length;
> > +	__be16 inner_proto;
> > +
> > +	if (!pskb_may_pull(skb, NSH_BASE_HDR_LEN))
> > +		return -ENOMEM;
> > +	nh = (struct nshhdr *)(skb->data);
> > +	length = nsh_hdr_len(nh);
> > +	if (!pskb_may_pull(skb, length))
> > +		return -ENOMEM;
> > +
> > +	nh = (struct nshhdr *)(skb->data);
> > +	inner_proto = tun_p_to_eth_p(nh->np);
> 
> If you fetch inner_proto before the second pskb_may_pull then there is
> no need to reload the nh pointer as you won't use it later.
> 
> > +	if (!inner_proto)
> > +		return -EAFNOSUPPORT;
> > +
> > +	length = nsh_hdr_len(nh);
> 
> You already have the length from above. No need to get it again.

Good catch, fixed in v15.
