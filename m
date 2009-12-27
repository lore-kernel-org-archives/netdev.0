From: David Miller <davem@davemloft.net>
Subject: Re: [patch] hamradio: avoid null deref v2
Date: Sat, 26 Dec 2009 20:17:29 -0800 (PST)
Message-ID: <20091226.201729.15225529.davem@davemloft.net>
References: <20091223132550.GD17923@bicker>
	<4B3257C2.2050500@gmail.com>
	<20091226123812.GB6075@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52636
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750815AbZL0ER0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Dec 2009 23:17:26 -0500
In-Reply-To: <20091226123812.GB6075@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Sat, 26 Dec 2009 14:38:12 +0200

> Bump the stats on the original dev not on the newly assigned NULL version of
> dev.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

This doesn't look real nice.

The bpq_get_ether_dev() abstraction exists so that the details of
bpq->this and bpq->that are hidden behind it.

Exposing those details inline just to fix this bug makes the
abstraction significantly less useful, and the code more ugly.

Please just create an "orig_dev" pointer to save the original device
in, and use it to fix this problem properly.

That way you only fetch the bpq ether device pointer via the
abstraction interface.

And BTW, this is how other reviewers told you to implement this
fix. :-)

Thanks.
