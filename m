From: "David S. Miller" <davem@davemloft.net>
Subject: tw32_f() in tg3_write_mem()
Date: Sat, 29 Apr 2006 19:22:02 -0700 (PDT)
Message-ID: <20060429.192202.74748695.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:10394
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750885AbWD3CYN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Apr 2006 22:24:13 -0400
To: mchan@broadcom.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


At least for the TG3PCI_MEM_WIN_DATA register, I don't know how safe
it is to use tw32_f() there.  Reads from a location can have side
effects, so doing a forced readback after a write could be dangerous.

And it isn't needed, as the tw32_f() done as we set the
TG3PCI_MEM_WIN_BASE_ADDR back to zero will flush all posted
writes.

Agreed?
