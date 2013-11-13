From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] netlink: a flag requesting header w/o data in
 error ACK
Date: Wed, 13 Nov 2013 15:31:12 -0500 (EST)
Message-ID: <20131113.153112.1336285577814329683.davem@davemloft.net>
References: <231e025015eee115182368b34333b38579e3112d.1384357520.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch, jhs@mojatatu.com,
	pablo@netfilter.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45423 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750848Ab3KMUbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 15:31:14 -0500
In-Reply-To: <231e025015eee115182368b34333b38579e3112d.1384357520.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Wed, 13 Nov 2013 16:46:09 +0100

> Currently, ACK in case of error contains a full copy of the originating
> message, although many applications do not need it. This can cause lost ACKs
> with large netlink messages, especially after commit c05cdb1b864f ("netlink:
> allow large data transfers from user-space").
> 
> Introduce a new message flag, NLM_F_SHORT_NACK, which requests only message
> header to be included in ACK regardless of the error code. This flag has no
> effect if NLM_F_ACK is not set.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
> I'm not entirely happy with taking a bit in netlink message header for this.
> Alternative approach would be to make this a socket option (as suggested by
> David) but that would mean a socket lookup in netlink_ack for each and every
> ACK, which doesn't sound nice, either. If this is preferred, I'll rework the
> patch.

It's not really all that difficult, you can either attack the sender socket
to in_skb->sk, or pass a new boolean around in the various code paths that
lead to the ACK.
