From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH net-next 05/14] gtp: Remove special mtu handling
Date: Tue, 19 Sep 2017 19:42:05 +0800
Message-ID: <20170919114205.z2txj6rwo2row7u4@nataraja>
References: <20170919003904.5124-1-tom@quantonium.net>
 <20170919003904.5124-6-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, pablo@netfilter.org,
        rohit@quantonium.net
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:45328 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751480AbdISMNN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 08:13:13 -0400
Content-Disposition: inline
In-Reply-To: <20170919003904.5124-6-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

On Mon, Sep 18, 2017 at 05:38:55PM -0700, Tom Herbert wrote:
> Removes MTU handling in gtp_build_skb_ip4. This is non standard relative
> to how other tunneling protocols handle MTU. The model espoused is that
> the inner interface should set it's MTU to be less than the expected
> path MTU on the overlay network. Path MTU discovery is not typically
> used for modifying tunnel MTUs.

The point of the kernel GTP module is to interoperate with existing
other GTP implementations and the practises established by cellular
operators when operating GTP in their networks.

While what you describe (chose interface MTU to be less than the
expected path MTU) is generally best practise in the Linux IP/networking
world, this is not generally reflected in the cellular
universe. You see quite a bit of GTP fragmentation due to the fact
that the transport network simply has to deal with the MTU that has
been established via the control plane between SGSN and MS/UE, without
the GGSN even being part of that negotiation.

Also, you may very well have one "gtp0" tunnel device at the GGSN,
but you are establishing individual GTP tunnels to dozesn to hundreds of
different SGSNs at operators all over the world.  You cannot reliably
set the "gtp0" interface MTU to "the path MTU of the overlay network",
as the overlay network is in fact different for each of the SGSNs you're
talking to - and each may have a different path MTU.

So unless I'm missing something, I would currently vote for staying with
the current code, which uses the path MTU to the specific destination IP
address (the SGSN).

Regards,
	Harald

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
