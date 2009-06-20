From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] Net: qla3xxx, remove sleeping in atomic
Date: Sat, 20 Jun 2009 01:21:07 -0700 (PDT)
Message-ID: <20090620.012107.75903817.davem@davemloft.net>
References: <1245424412-15106-1-git-send-email-jirislaby@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-driver@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jirislaby@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41956
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753610AbZFTIVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2009 04:21:04 -0400
In-Reply-To: <1245424412-15106-1-git-send-email-jirislaby@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Slaby <jirislaby@gmail.com>
Date: Fri, 19 Jun 2009 17:13:32 +0200

> Hi, we've found this sleep-inside-spinlock.
> 
> The fix below totally untested, please review carefully.
> 
> --
> 
> We cannot sleep in ql_reset_work under spinlock, unlock before sleep,
> relock after.
> 
> Signed-off-by: Jiri Slaby <jirislaby@gmail.com>

This looks good.  The spinlock is just required to be held
around the register accesses.  It's going to drop the lock
as soon as the bits settle post-reset anyways and then the
driver goes off and modifies other state outside of the lock.

Applied, thanks!
