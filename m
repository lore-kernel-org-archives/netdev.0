From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ip: Report qdisc packet drops
Date: Wed, 02 Sep 2009 18:09:11 -0700 (PDT)
Message-ID: <20090902.180911.222525657.davem@davemloft.net>
References: <4A9BBD8E.2010303@gmail.com>
	<20090901.184121.06750444.davem@davemloft.net>
	<alpine.DEB.1.10.0909021318490.21832@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, sri@us.ibm.com, dlstevens@us.ibm.com,
	netdev@vger.kernel.org, niv@linux.vnet.ibm.com,
	mtk.manpages@gmail.com
To: cl@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59764
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752921AbZICBI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 21:08:57 -0400
In-Reply-To: <alpine.DEB.1.10.0909021318490.21832@V090114053VZO-1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux-foundation.org>
Date: Wed, 2 Sep 2009 13:22:25 -0500 (CDT)

> There may be a minor issue here in that IP_RECVERR sometimes sends error
> packets that have to be intercepted using special code. Or can those be
> simply ignored? If so then I will ask UDP app vendors to use IP_RECVERR.

If you don't set MSG_ERRQUEUE, no special error reports will be
given to the application.

And this only matters for recvmsg() handling.

On send, the only behavior difference is this error code reporting
(and before Eric's patch, SNMP statistics handling).
