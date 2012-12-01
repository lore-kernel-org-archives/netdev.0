From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sky2: Correct mistakenly switched read/write sequence
Date: Sat, 1 Dec 2012 10:36:53 -0800
Message-ID: <20121201103653.444b5087@nehalam.linuxnetplumber.net>
References: <20121201124239.GB3914@neptun>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mlindner@marvell.com, davem@davemloft.net, netdev@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57237 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752693Ab2LASiH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2012 13:38:07 -0500
In-Reply-To: <20121201124239.GB3914@neptun>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 1 Dec 2012 13:42:39 +0100
Lino Sanfilippo <LinoSanfilippo@gmx.de> wrote:

> In sky2_all_down() the order of the read()/write() access to B0_IMSK seems to
> be mistakenly switched. The original intention was obviously to avoid PCI write
> posting.
> This patch fixes the order.
> 
> Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

You are both right. David is correct in that the original code here
was quite different and was doing save/restore of irq mask.
That changed as driver evolved to only bring up IRQ if device was
brought up. At which point the read of irq mask was a left over call.

Lino is correct, it makes sense to do read after write to ensure PCI posting.
So I agree with the patch, but would like the commit message changed
slightly.
