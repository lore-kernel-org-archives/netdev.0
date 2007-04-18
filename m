From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [net-2.6] IrDA: Correctly handling socket error
Date: Wed, 18 Apr 2007 15:07:56 -0700 (PDT)
Message-ID: <20070418.150756.122832779.davem@davemloft.net>
References: <20070418214526.GA4496@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	olaf.kirch@oracle.com, stable@kernel.org
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48921
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754059AbXDRWHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2007 18:07:53 -0400
In-Reply-To: <20070418214526.GA4496@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel@sortiz.org>
Date: Thu, 19 Apr 2007 00:45:26 +0300

> From: Olaf Kirch <olaf.kirch@oracle.com>
> 
> This patch fixes an oops first reported in mid 2006 - see
> http://lkml.org/lkml/2006/8/29/358 The cause of this bug report is that
> when an error is signalled on the socket, irda_recvmsg_stream returns
> without removing a local wait_queue variable from the socket's sk_sleep
> queue. This causes havoc further down the road.
> 
> In response to this problem, a patch was made that invoked sock_orphan on
> the socket when receiving a disconnect indication. This is not a good fix,
> as this sets sk_sleep to NULL, causing applications sleeping in recvmsg
> (and other places) to oops.
> 
> This is against the latest net-2.6 and should be considered for -stable
> inclusion. 
> 
> Signed-off-by: Olaf Kirch <olaf.kirch@oracle.com>
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

Applied and I'll push this to -stable too, thanks!
