From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4: Add support for EEH error recovery
Date: Tue, 24 Jul 2012 14:03:53 -0700 (PDT)
Message-ID: <20120724.140353.1432900101600410863.davem@davemloft.net>
References: <1342814143-5744-1-git-send-email-klebers@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jackm@dev.mellanox.co.il,
	yevgenyp@mellanox.co.il, ogerlitz@mellanox.com,
	cascardo@linux.vnet.ibm.com, brking@linux.vnet.ibm.com
To: klebers@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33779 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756263Ab2GXVD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 17:03:56 -0400
In-Reply-To: <1342814143-5744-1-git-send-email-klebers@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
Date: Fri, 20 Jul 2012 16:55:43 -0300

> Currently the mlx4 drivers don't have the necessary callbacks to
> implement EEH errors detection and recovery, so the PCI layer uses the
> probe and remove callbacks to try to recover the device after an error on
> the bus. However, these callbacks have race conditions with the internal
> catastrophic error recovery functions, which will also detect the error
> and this can cause the system to crash if both EEH and catas functions
> try to reset the device.
> 
> This patch adds the necessary error recovery callbacks and makes sure
> that the internal catastrophic error functions will not try to reset the
> device in such scenarios. It also adds some calls to
> pci_channel_offline() to suppress reads/writes on the bus when the slot
> cannot accept I/O operations so we prevent unnecessary accesses to the
> bus and speed up the device removal.
> 
> Signed-off-by: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>

Or, you promised an ACK today, I still haven't seen it.

There is no reason Kleber should be penalized and have his work
miss the merge window just because you guys can't be bothered
to approve this patch in a reasonable amount of time.

Therefore I'm just going to apply it later today, and don't do this
with someone's submission ever again, it impedes progress and
frustrates contributors.
