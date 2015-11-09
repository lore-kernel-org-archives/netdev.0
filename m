From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH net-next v2 0/8] openvswitch: NAT support.
Date: Mon, 9 Nov 2015 13:31:22 +0000
Message-ID: <20151109133122.GC8098@macbook.localdomain>
References: <1446854768-38299-1-git-send-email-jrajahalme@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	dev@openvswitch.org
To: Jarno Rajahalme <jrajahalme@nicira.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1446854768-38299-1-git-send-email-jrajahalme@nicira.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06.11, Jarno Rajahalme wrote:
> This series adds NAT support to openvswitch kernel module.  A few
> changes are needed to the netfilter code to facilitate this (patches
> 1-3/8).  Patches 4-7 make the openvswitch kernel module ready for the
> patch 8 that adds the NAT support for calling into netfilter NAT code
> from the openvswitch conntrack action.

I'm missing some high level description, especially how it is invoked, how
it makes sure expectations of the NAT code about its invocation are met
(it is my understanding that OVS simply invokes this based on actions
specified by the user) and how it interacts with the remaining netfilter
features.

> Jarno Rajahalme (8):
>   netfilter: Remove IP_CT_NEW_REPLY definition.
>   netfilter: Factor out nf_ct_get_info().
>   netfilter: Allow calling into nat helper without skb_dst.
>   openvswitch: Update the CT state key only after nf_conntrack_in().
>   openvswitch: Find existing conntrack entry after upcall.
>   openvswitch: Handle NF_REPEAT in conntrack action.
>   openvswitch: Delay conntrack helper call for new connections.
>   openvswitch: Interface with NAT.
> 
>  include/net/netfilter/nf_conntrack.h               |  15 +
>  include/uapi/linux/netfilter/nf_conntrack_common.h |  12 +-
>  include/uapi/linux/openvswitch.h                   |  47 ++
>  net/ipv4/netfilter/nf_nat_l3proto_ipv4.c           |  29 +-
>  net/ipv6/netfilter/nf_nat_l3proto_ipv6.c           |  29 +-
>  net/netfilter/nf_conntrack_core.c                  |  22 +-
>  net/openvswitch/conntrack.c                        | 632 +++++++++++++++++++--
>  net/openvswitch/conntrack.h                        |   3 +-
>  8 files changed, 686 insertions(+), 103 deletions(-)
> 
> -- 
> 2.1.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
