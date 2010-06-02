From: David Miller <davem@davemloft.net>
Subject: Re: cls_u32: check unaligned data access
Date: Wed, 02 Jun 2010 08:18:46 -0700 (PDT)
Message-ID: <20100602.081846.66727112.davem@davemloft.net>
References: <1275491747-29888-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46363
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757876Ab0FBPSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 11:18:36 -0400
In-Reply-To: <1275491747-29888-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Wed,  2 Jun 2010 23:15:47 +0800

> check unaligned data access
> 
> before accessing data, check if the corresponding address is aligned, and if
> not, return -1.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

The user will find out when he gets warnings in his kernel log
messages on platforms where this matters.

And, if anything, silently just skipping over things is not
acceptable.  And imposing a 4-byte alignment could break
existing setups that actually work on x86 and powerpc which
are platforms that don't have alignment issues.

I basically tried to explain to you earlier that I wasn't going to
accept patches that try to deal with alignment in any way here in this
code, we explicitly and intentionally blindly dereference the data.

