From: David Miller <davem@davemloft.net>
Subject: doubt about qla3xxx checksum "fix"
Date: Sun, 03 Jun 2007 18:00:51 -0700 (PDT)
Message-ID: <20070603.180051.89019554.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34556
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751229AbXFDBAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jun 2007 21:00:37 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I don't think it's %100 right, I'm referring specifically to

e68a8c10c4c5daf363e946d10c1a5cba77d7f92c

Sure, qla3xxx is only handling ipv4 in that ql_hw_csum_setup()
function, but if you check the call site it really wants
CHECKSUM_PARTIAL skb's to work on.  And CHECKSUM_PARTIAL skbs are only
setup for paths that advertise the NETIF_F_HW_CSUM capability.

With Stephen's change it now won't checksum offload anything at all.
