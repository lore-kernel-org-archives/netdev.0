From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH v9 net-next 5/7] openvswitch: add layer 3 support to
 ovs_packet_cmd_execute()
Date: Wed, 18 May 2016 11:24:21 +0900
Message-ID: <20160518022419.GB27411@vergenet.net>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
 <1462347393-22354-6-git-send-email-simon.horman@netronome.com>
 <20160517165108.2f24054e@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Lorand Jakab <lojakab@cisco.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33442 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752440AbcERCYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 22:24:31 -0400
Received: by mail-pf0-f171.google.com with SMTP id 206so13068101pfu.0
        for <netdev@vger.kernel.org>; Tue, 17 May 2016 19:24:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160517165108.2f24054e@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 17, 2016 at 04:51:08PM +0200, Jiri Benc wrote:
> On Wed,  4 May 2016 16:36:31 +0900, Simon Horman wrote:
> > +	/* Packets from user space for execution only have metadata key
> > +	 * attributes.  OVS_KEY_ATTR_PACKET_ETHERTYPE is then used to specify
> > +	 * the starting layer of the packet.  Packets with Ethernet headers
> > +	 * have this attribute set to 0
> > +	 */
> > +	if (*attrs & (1ULL << OVS_KEY_ATTR_PACKET_ETHERTYPE)) {
> > +		__be16 eth_type;
> > +
> > +		if (is_mask) {
> > +			/* Always exact match packet EtherType */
> > +			eth_type = htons(0xffff);
> > +		} else {
> > +			eth_type = nla_get_be16(a[OVS_KEY_ATTR_PACKET_ETHERTYPE]);
> > +			is_layer3 = ((eth_type == htons(ETH_P_IP)) ||
> > +				     (eth_type == htons(ETH_P_IPV6)));
> 
> Unknown types need to be rejected, not treated as layer2, otherwise we
> may run into problems later (with combination of this kernel + newer
> user space) when we add more types, such as ETH_P_NSH.

I believe this is fixed by the following patch.

Possibly it makes sense to squash that patch into and earlier patches.
