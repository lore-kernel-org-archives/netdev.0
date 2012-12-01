From: David Miller <davem@davemloft.net>
Subject: Re: sky2: Correct mistakenly switched read/write sequence
Date: Sat, 01 Dec 2012 12:27:01 -0500 (EST)
Message-ID: <20121201.122701.2065141028797970034.davem@davemloft.net>
References: <20121201124239.GB3914@neptun>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, mlindner@marvell.com, netdev@vger.kernel.org
To: LinoSanfilippo@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53928 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752615Ab2LAR1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 12:27:04 -0500
In-Reply-To: <20121201124239.GB3914@neptun>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Date: Sat, 1 Dec 2012 13:42:39 +0100

> In sky2_all_down() the order of the read()/write() access to B0_IMSK seems to
> be mistakenly switched. The original intention was obviously to avoid PCI write
> posting.
> This patch fixes the order.
> 
> Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

I would say that no such intention exists at all.

The read is there because a long time ago the result as used
to compute an 'imask' variable.

Please see commit:

commit d72ff8fa7f8b344382963721f842256825c4660b
Author: Mike McCormack <mikem@ring3k.org>
Date:   Thu May 13 06:12:51 2010 +0000

    sky2: Refactor down/up code out of sky2_restart()
    
    Code to bring down all sky2 interfaces and bring it up
    again can be reused in sky2_suspend and sky2_resume.
    
    Factor the code to bring the interfaces down into
    sky2_all_down and the up code into sky2_all_up.
    
    Signed-off-by: Mike McCormack <mikem@ring3k.org>
    Acked-by: Stephen Hemminger <shemminger@vyatta.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
