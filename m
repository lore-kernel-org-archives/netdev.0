From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 01/10] bnxt_en: Improve bnxt_vf_update_mac().
Date: Thu, 25 Feb 2016 11:31:28 -0500 (EST)
Message-ID: <20160225.113128.1989544272292631983.davem@davemloft.net>
References: <1456388374-1440-1-git-send-email-michael.chan@broadcom.com>
	<1456388374-1440-2-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42561 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753461AbcBYQbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 11:31:35 -0500
In-Reply-To: <1456388374-1440-2-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Thu, 25 Feb 2016 03:19:25 -0500

> From: Jeffrey Huang <huangjw@broadcom.com>
> 
> Allow the VF to setup its own MAC address if the PF has not administratively
> set it for the VF.  If the perm_mac_address returned by firmware is all
> zeros, that means the PF has not set up the MAC address for the VF and
> we should store it.  This will allow the VF to change the MAC address using
> ndo_set_mac_address() when it sees that the stored permanent MAC address
> is all zeros.
> 
> Signed-off-by: Jeffrey Huang <huangjw@broadcom.com>
> Signed-off-by: Michael Chan <michael.chan@broadcom.com>

What triggers that ->ndo_set_mac_address() call in the VF?

You cannot register an ethernet netdev with an invalid ethernet address,
you must use a random one if you don't have a valid one available.
