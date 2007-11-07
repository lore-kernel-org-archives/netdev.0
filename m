From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/2] ipvs: Syncrhonise Closing of Connections
Date: Wed, 07 Nov 2007 02:37:16 -0800 (PST)
Message-ID: <20071107.023716.31193168.davem@davemloft.net>
References: <20071105030851.615630269@vergenet.net>
	<20071105030958.813581208@vergenet.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lvs-devel@linuxvirtualserver.org, netdev@vger.kernel.org,
	rumen@voicecho.com, graeme@graemef.net, jmack@wm7d.net, ja@ssi.bg,
	wensong@linux-vs.org
To: horms@vergenet.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42609
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753833AbXKGKhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 05:37:17 -0500
In-Reply-To: <20071105030958.813581208@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: horms@vergenet.net
Date: Mon, 05 Nov 2007 12:08:53 +0900

> From: Rumen G. Bogdanovski <rumen@voicecho.com>
> 
> This patch makes the master daemon to sync the connection when it is about
> to close.  This makes the connections on the backup to close or timeout
> according their state.  Before the sync was performed only if the
> connection is in ESTABLISHED state which always made the connections to
> timeout in the hard coded 3 minutes. However the Andy Gospodarek's patch
> ([IPVS]: use proper timeout instead of fixed value) effectively did nothing
> more than increasing this to 15 minutes (Established state timeout).  So
> this patch makes use of proper timeout since it syncs the connections on
> status changes to FIN_WAIT (2min timeout) and CLOSE (10sec timeout).
> However if the backup misses CLOSE hopefully it did not miss FIN_WAIT.
> Otherwise we will just have to wait for the ESTABLISHED state timeout. As
> it is without this patch.  This way the number of the hanging connections
> on the backup is kept to minimum. And very few of them will be left to
> timeout with a long timeout.
> 
> This is important if we want to make use of the fix for the real server
> overcommit on master/backup fail-over.
> 
> Signed-off-by: Rumen G. Bogdanovski <rumen@voicecho.com>
> Signed-off-by: Simon Horman <horms@verge.net.au>

Also applied, thanks.
