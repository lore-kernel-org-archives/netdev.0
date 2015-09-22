From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: Handle negative checksum offset in
 skb-checksum-help
Date: Mon, 21 Sep 2015 17:14:12 -0700 (PDT)
Message-ID: <20150921.171412.613695619204829336.davem@davemloft.net>
References: <1442818397-2210-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56737 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757339AbbIVAON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 20:14:13 -0400
In-Reply-To: <1442818397-2210-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Sun, 20 Sep 2015 23:53:17 -0700

> VXLAN device can receive skb with checksum partial. But the checksum
> offset could be in outer header which is pulled on receive.

Such a scenerio is a bug.

Anything that pulls off a header should use a utility function such
as skb_pull_rcsum() or skb_postpull_rcsum() to make sure this gets
fixed up properly.
