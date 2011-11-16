From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] route: add more relaxed option for secure_redirects
Date: Wed, 16 Nov 2011 17:02:13 -0500 (EST)
Message-ID: <20111116.170213.1763930566851730338.davem@davemloft.net>
References: <1320710630-28335-1-git-send-email-fbl@redhat.com>
	<20111111.203321.93615255271311412.davem@davemloft.net>
	<20111116184612.25615c02@asterix.rh>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44887 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980Ab1KPWCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 17:02:16 -0500
In-Reply-To: <20111116184612.25615c02@asterix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Wed, 16 Nov 2011 18:46:12 -0200

> Thus, the only option at the sender side would be using iptables
> to change the ICMP redirect source address to be the float address,
> but that is not working as well. (It isn't passing through -t nat)

If it's going to mangle the packet in one direct, the only option
for sane operation is to make the exact reverse transformation in
the other direction for ICMP messages.

I'm sorry to be so difficult about this, but this is the only way to
handle this problem.  If packet mangling is performed to change the
world, that mangling entity has taken on the responsibility to make
everything look correct to all entities for the mangled packets
and any packets generated in response to such mangled packets.
