From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2.58] datapath: Add basic MPLS support to kernel
Date: Mon, 2 Jun 2014 17:58:10 -0700
Message-ID: <CAEP_g=8Ub64M29TQx82KrFMLcdsAPfKmC8w92d-Ofr9cVhNKFQ@mail.gmail.com>
References: <1401063743-30997-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Joe Stringer <joe@wand.net.nz>, Thomas Graf <tgraf@suug.ch>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog123.obsmtp.com ([74.125.149.149]:34020 "HELO
	na3sys009aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753212AbaFCA6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 20:58:31 -0400
Received: by mail-qg0-f50.google.com with SMTP id z60so12159932qgd.9
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2014 17:58:30 -0700 (PDT)
In-Reply-To: <1401063743-30997-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 25, 2014 at 5:22 PM, Simon Horman <horms@verge.net.au> wrote:
> diff --git a/datapath/flow_netlink.c b/datapath/flow_netlink.c
> index 803a94c..8ce596c 100644
> --- a/datapath/flow_netlink.c
> +++ b/datapath/flow_netlink.c
> +               case OVS_ACTION_ATTR_POP_MPLS:
> +                       if (!eth_p_mpls(eth_type))
> +                               return -EINVAL;

Should this also take into account the VLAN tag? It's really part of
the EtherType although it has been stripped out here. Actually, maybe
it's better to not track the vlan_tci separately at all during
validation but just fold it into the EtherType.

The practical implication of this is that you wouldn't be able to pop
out from underneath a VLAN. This may be a good thing if we are trying
to avoid tag order issues - after all, you can't push underneath a
VLAN either. I'm not sure what effects this has on the need to track
mac_len, if any.

Otherwise, I'm happy with this. I think that we need to conclude the
discussion on the other patch and update this appropriately first.
