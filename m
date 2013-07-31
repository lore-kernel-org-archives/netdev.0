From: Phil Sutter <phil@nwl.cc>
Subject: Parse ethernet headers in af_packet.c
Date: Wed, 31 Jul 2013 19:27:44 +0200
Message-ID: <1375291667-9572-1-git-send-email-phil@nwl.cc>
References: <20130729165357.GA23134@orbit.nwl.cc>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:41420 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754008Ab3GaR2T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 13:28:19 -0400
In-Reply-To: <20130729165357.GA23134@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This is an AF_PACKET specific solution to the problems discussed in [1]
and [2].

Basically this incorporates calling eth_type_trans() for packets to send
when the outgoing device's type is ARPHRD_ETHER.

In order to having a more generic solution which could be used in other
places (like e.g. tun.c), I second Michael's approach in [2], but would
extend it to a generic equivalent to eth_type_trans(). A device-type
specific layer-2 header parser if you will. Note that eth_type_trans()
also sets skbuff's dev, pkt_type and mac_header fields. A
dev->header_ops->type_trans() could do just that plus set skb->protocol
(maybe only if it's ETH_P_ALL).

[1] http://patchwork.ozlabs.org/patch/67422/
[2] http://lists.openwall.net/netdev/2010/01/06/38

Best wishes, Phil
