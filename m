From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3 00/17] Future-proof tunnel offload handlers
Date: Tue, 21 Jun 2016 04:22:11 -0400 (EDT)
Message-ID: <20160621.042211.945844554759834352.davem@davemloft.net>
References: <20160616191851.20872.67154.stgit@localhost.localdomain>
	<20160617.202641.1821023739498595024.davem@davemloft.net>
	<CALx6S34Y3Qq6nMHuMcC2LC5duLBO3KVN3+A+0qmPrNvFfY7gJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aduyck@mirantis.com, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, hannes@redhat.com,
	jesse@kernel.org, eugenia@mellanox.com, jbenc@redhat.com,
	alexander.duyck@gmail.com, saeedm@mellanox.com,
	ariel.elior@qlogic.com, michael.chan@broadcom.com,
	Dept-GELinuxNICDev@qlogic.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34327 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752441AbcFUIWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 04:22:22 -0400
In-Reply-To: <CALx6S34Y3Qq6nMHuMcC2LC5duLBO3KVN3+A+0qmPrNvFfY7gJg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Mon, 20 Jun 2016 10:05:01 -0700

> Generally, this means it needs to at least match by local addresses
> and port for an unconnected/unbound socket, the source address for
> an unconnected/bound socket, a the full 4-tuple for a connected
> socket.

These lookup keys are all insufficient.

At the very least the network namespace must be in the lookup key as
well if you want to match "sockets".  And this is just the tip of the
iceberg in my opinion.

The namespace bypassing to me is the biggest flaw in the UDP tunnel
offloads.  That is creating real dangers right now.

But anyways, the vastness of the key is why we want to keep "sockets"
out of network cards, because proper support of "sockets" requires
access to information the card simply does not and should not have.
