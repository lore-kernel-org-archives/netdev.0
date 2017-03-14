From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next 2/4] gtp: add genl cmd to enable GTP
 encapsulation on UDP socket
Date: Tue, 14 Mar 2017 12:43:30 +0100
Message-ID: <20170314114330.GB2992@salvia>
References: <20170314112548.24027-1-aschultz@tpip.net>
 <20170314112548.24027-3-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harald Welte <laforge@gnumonks.org>,
        osmocom-net-gprs@lists.osmocom.org,
        netdev <netdev@vger.kernel.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40850 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750774AbdCNLnk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Mar 2017 07:43:40 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 4A20F24625
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 12:43:37 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 3AAE4DA872
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 12:43:37 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 67AAADA388
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 12:43:34 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20170314112548.24027-3-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 14, 2017 at 12:25:46PM +0100, Andreas Schultz wrote:

> @@ -1254,6 +1293,8 @@ static struct nla_policy gtp_genl_policy[GTPA_MAX + 1] = {
>  	[GTPA_NET_NS_FD]	= { .type = NLA_U32, },
>  	[GTPA_I_TEI]		= { .type = NLA_U32, },
>  	[GTPA_O_TEI]		= { .type = NLA_U32, },
> +	[GTPA_PDP_HASHSIZE]	= { .type = NLA_U32, },

This per PDP hashsize attribute clearly doesn't belong here.

Moreover, we now have a rhashtable implementation, so we hopefully we
can get rid of this. It should be very easy to convert this to use
rhashtable, and it is very much desiderable.

> +	[GTPA_FD]		= { .type = NLA_U32, },

This new atttribute has nothing to do with the PDP context.
And enum gtp_attrs *only* describe a PDP context. Adding more
attributes there to mix semantics is not the way to go.

You likely have to inaugurate a new enum. This gtp_attrs enum only
related to the PDP description.

Why not add some interface to attach more sockets to the gtp device
globally? So still the gtp device is the top-level structure. Then add
a netlink attribute to specify to what VRF this tunnel belongs to,
instead of implicitly using the socket to achieve this.

Another possibility is to explicitly have an interface to add
new/delete VRFs, attach sockets to them.

In general, I'm still not convinced this is the right design for this.
