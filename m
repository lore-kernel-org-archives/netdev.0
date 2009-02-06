From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: remove useless synchronize_net()
Date: Thu, 05 Feb 2009 23:45:20 -0800 (PST)
Message-ID: <20090205.234520.149982266.davem@davemloft.net>
References: <498ABDA2.5040603@dev.6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@dev.6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39946
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751943AbZBFHpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 02:45:25 -0500
In-Reply-To: <498ABDA2.5040603@dev.6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
Date: Thu, 05 Feb 2009 11:21:22 +0100

> In dev_change_net_namespace(), synchronize_net() is called at the
> end of the function, but there is no reason (no deletion occurs).
>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

It is necessary to make sure all cpus stop looking at the
previous namespace the device was attached to, and only
see the new mapping.

That's why this function has two synchronize_net() calls.
