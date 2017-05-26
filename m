From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: fix rare pci_driver.probe failure
 of VF driver
Date: Fri, 26 May 2017 14:42:35 -0400 (EDT)
Message-ID: <20170526.144235.1508311899416004009.davem@davemloft.net>
References: <20170525174214.GA1444@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        prasad.kanneganti@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43406 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948612AbdEZSmh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 14:42:37 -0400
In-Reply-To: <20170525174214.GA1444@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Thu, 25 May 2017 10:42:14 -0700

> From: Prasad Kanneganti <prasad.kanneganti@cavium.com>
> 
> There's a rare pci_driver.probe failure of the VF driver that's caused by
> PF/VF handshake going out of sync.  The culprit is octeon_mbox_write() who
> ignores an ack timeout condition; it just keeps unconditionally writing all
> elements of mbox_cmd->data[] even when the other side is not ready for
> them.  Fix it by making each write of mbox_cmd->data[i] conditional to
> having previously received an ack.
> 
> Also fix the octeon_mbox_state enum such that each state gets a unique
> value.  Also add ULL suffix to numeric literals in macro definitions.
> 
> Signed-off-by: Prasad Kanneganti <prasad.kanneganti@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied.
