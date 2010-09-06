From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bonding: Fix jiffies overflow problems (again)
Date: Mon, 06 Sep 2010 13:16:47 -0700 (PDT)
Message-ID: <20100906.131647.115921981.davem@davemloft.net>
References: <201009021619.46206.jdelvare@suse.de>
	<1283438186.2454.856.camel@edumazet-laptop>
	<201009021745.55038.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jbohac@suse.cz
To: jdelvare@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33190
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751066Ab0IFUQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 16:16:30 -0400
In-Reply-To: <201009021745.55038.jdelvare@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Delvare <jdelvare@suse.de>
Date: Thu, 2 Sep 2010 17:45:54 +0200

> From: Jiri Bohac <jbohac@suse.cz>
> 
> The time_before_eq()/time_after_eq() functions operate on unsigned
> long and only work if the difference between the two compared values
> is smaller than half the range of unsigned long (31 bits on i386).
> 
> Some of the variables (slave->jiffies, dev->trans_start, dev->last_rx)
> used by bonding store a copy of jiffies and may not be updated for a
> long time. With HZ=1000, time_before_eq()/time_after_eq() will start
> giving bad results after ~25 days.
> 
> jiffies will never be before slave->jiffies, dev->trans_start,
> dev->last_rx by more than possibly a couple ticks caused by preemption
> of this code. This allows us to detect/prevent these overflows by
> replacing time_before_eq()/time_after_eq() with time_in_range().
> 
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>
> Signed-off-by: Jean Delvare <jdelvare@suse.de>

Applied, thanks.
