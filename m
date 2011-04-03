From: Marc Haber <mh+netdev@zugschlus.de>
Subject: Netxen packet loss with VLANs and LRO (was: [PATCH] netxen:  fix
	LRO disable warning)
Date: Sun, 3 Apr 2011 21:05:55 +0200
Message-ID: <20110403190555.GA16196@torres.zugschlus.de>
References: <1300703828-6291-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:58976 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235Ab1DCTOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2011 15:14:21 -0400
Content-Disposition: inline
In-Reply-To: <1300703828-6291-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Mar 21, 2011 at 03:37:08AM -0700, Amit Kumar Salecha wrote:
> netxen_nic_set_flags() rejects data if other flag than ETH_FLAG_LRO is set.
> Driver also supports NETIF_F_HW_VLAN_TX.
> Now compare data with ethtool_op_get_flags(), to get all supported features.

Could that be the cause for packet loss on kernel 2.6.38.2 if:

  - receiving card is NX3031 [4040:0100]
  - frames are received with VLAN tags
  - large received offload is on.

Packet Loss of this kind is noticed when doing TCP data transfers
towards the host with the Netxen Interface and the TCP session is
terminated on the Netxen host itself. TCP sessions routed through the
Netxen host are not affected.

My ethtool doesn't allow me to influence the LRO setting alone - it is
disabled when I set rx off but doesn't come on again when rx is set to
on again. So, ethtool -K rx off, ethtool -K rx on fixes the issue.

Is this a known bug, maybe with an available patch?

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190
