From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: allow adding VLANs while interface is down
Date: Sun, 05 Jun 2016 23:12:13 -0400 (EDT)
Message-ID: <20160605.231213.1678457595287788841.davem@davemloft.net>
References: <1464960738-8541-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuval.Mintz@qlogic.com,
	Ariel.Elior@qlogic.com
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37725 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750763AbcFFDMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 23:12:14 -0400
In-Reply-To: <1464960738-8541-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Fri,  3 Jun 2016 15:32:18 +0200

> Since implementing VLAN filtering in commit 05cc5a39ddb74
> ("bnx2x: add vlan filtering offload") bnx2x refuses to add a VLAN while
> the interface is down:
> 
>   # ip link add link enp3s0f0 enp3s0f0_10 type vlan id 10
>   RTNETLINK answers: Bad address
> 
> and in dmesg (with bnx2x.debug=0x20):
>   bnx2x: [bnx2x_vlan_rx_add_vid:12941(enp3s0f0)]Ignoring VLAN
>   configuration the interface is down
> 
> Other drivers have no problem with this.
> Fix this peculiar behavior in the following way:
>  - Accept requests to add/kill VID regardless of the device state.
>    Maintain the requested list of VIDs in the bp->vlan_reg list.
>  - If the device is up, try to configure the VID list into the hardware.
>    If we run out of VLAN credits or encounter a failure configuring an
>    entry, fall back to accepting all VLANs.
>    If we successfully configure all entries from the list, turn the
>    fallback off.
>  - Use the same code for reconfiguring VLANs during NIC load.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Applied, thanks.
