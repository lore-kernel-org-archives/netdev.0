From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: llc: check for device before dereferencing
Date: Mon, 29 Sep 2014 16:45:41 -0400 (EDT)
Message-ID: <20140929.164541.20059477388052953.davem@davemloft.net>
References: <1411782103-3059-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sasha.levin@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33949 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751898AbaI2Upo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 16:45:44 -0400
In-Reply-To: <1411782103-3059-1-git-send-email-sasha.levin@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sasha Levin <sasha.levin@oracle.com>
Date: Fri, 26 Sep 2014 21:41:43 -0400

> llc_ui_sendmsg would not make sure that a device indeed exists before
> dereferencing it. This caused a user triggerable NULL ptr deref:
...
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

The bug is real, but I don't think the fix is in the correct spot.

The real problem seems to be that the guard for calling
llc_ui_autobind() is inaccurate.

Fix that and there will always be a proper llc->dev attached at
this location.
