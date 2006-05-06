From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC PATCH] [IPV6] ADDRCONF: Convert addrconf_lock to RCU.
Date: Fri, 05 May 2006 17:40:11 -0700 (PDT)
Message-ID: <20060505.174011.10378443.davem@davemloft.net>
References: <20060505.122452.46183936.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:8854
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750794AbWEFAkI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 May 2006 20:40:08 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20060505.122452.46183936.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Fri, 05 May 2006 12:24:52 +0900 (JST)

> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

It is critical that we free the inet6 device structure using an RCU
callback in order for this locking strategy to work.

An RCU head needs to be added to "struct inet6_dev", and
in6_dev_finish_destroy() will need to schedule the real kfree() call
via an RCU callback.
