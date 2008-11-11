From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.27] tcp_htcp: last_cong bug fix
Date: Mon, 10 Nov 2008 21:50:33 -0800 (PST)
Message-ID: <20081110.215033.22437445.davem@davemloft.net>
References: <0E5A87BC-8FA8-40A5-8032-9FA18D07D7CE@nuim.ie>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	lachlan.andrew@gmail.com, lstewart@room52.net
To: Doug.Leith@nuim.ie
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39034
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752514AbYKKFue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 00:50:34 -0500
In-Reply-To: <0E5A87BC-8FA8-40A5-8032-9FA18D07D7CE@nuim.ie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Douglas Leith <Doug.Leith@nuim.ie>
Date: Sun, 09 Nov 2008 19:09:24 +0000

> This patch fixes a minor bug in tcp_htcp.c which has been
> highlighted by Lachlan Andrew and Lawrence Stewart.  Currently, the
> time since the last congestion event, which is stored in variable
> last_cong, is reset whenever there is a state change into
> TCP_CA_Open.  This includes transitions of the type
> TCP_CA_Open->TCP_CA_Disorder->TCP_CA_Open which are not associated
> with backoff of cwnd.  The patch changes last_cong to be updated
> only on transitions into TCP_CA_Open that occur after experiencing
> the congestion-related states TCP_CA_Loss, TCP_CA_Recovery,
> TCP_CA_CWR.

Thank you for this fix.  Could you fix a few things up for
me and resubmit this?

1) Please provide a proper Signed-off-by: line as per
   linux/Documentation/SubmittingPatches

2) Please -p1 root your patches at the top level of
   the kernel source tree, again the SubmittingPatches
   document helps explain ways to do this

3) Please fix up a few coding style errors, such as:

> +               ca->undo_last_cong=0; // flag that ca->last_cong is not to be reset when enter TCP_CA_Open state

   Please don't use C++ style comments, use normal C ones,
   and please don't let the line exceed much more than 80
   columns.

   Also, please put one space on each side of the equal sign in the
   assignment.

> +                       if (ca->undo_last_cong) {
> +                               ca->last_cong=jiffies;
> +                               ca->undo_last_cong=0;
> +                       }

   Again, please put spaces around the assignment equal sign.

Thanks.
