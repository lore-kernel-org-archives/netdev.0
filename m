From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.27] tcp_htcp: last_cong bug fix
Date: Wed, 12 Nov 2008 01:44:03 -0800 (PST)
Message-ID: <20081112.014403.210407962.davem@davemloft.net>
References: <20081110.215033.22437445.davem@davemloft.net>
	<B4ABF490-649C-4981-A953-B5FA55022EBD@nuim.ie>
	<63599554-7243-4E44-BFEF-5B4B36743606@nuim.ie>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: Doug.Leith@nuim.ie
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38814
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751261AbYKLJoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 04:44:05 -0500
In-Reply-To: <63599554-7243-4E44-BFEF-5B4B36743606@nuim.ie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Douglas Leith <Doug.Leith@nuim.ie>
Date: Wed, 12 Nov 2008 08:58:18 +0000

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
> 
> Signed-off-by:  Doug Leith <doug.leith@nuim.ie>

Applied, but I still had to fix up a bunch of details :-(

+		ca->undo_last_cong = 0;  

That line had trailing whitespace.

+	case TCP_CA_Open: 

That one too.

+        		if (ca->undo_last_cong) { 

That line had an initial set of space characters, instead
of pure leading tab characters.

+				ca->last_cong = jiffies;   

More trailing whitespace.

+		break;	

And some more trailing whitespace.
