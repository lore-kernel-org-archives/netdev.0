From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 - rev2] qdisc_restart - couple of optimizations.
Date: Sun, 24 Jun 2007 19:57:45 -0700 (PDT)
Message-ID: <20070624.195745.26349343.davem@davemloft.net>
References: <1181724049.10679.31.camel@localhost.localdomain>
	<1182142451.6082.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, herbert@gondor.apana.org.au,
	peter.p.waskiewicz.jr@intel.com, tgraf@suug.ch, kaber@trash.net,
	netdev@vger.kernel.org
To: kumarkr@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37460
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751376AbXFYC51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2007 22:57:27 -0400
In-Reply-To: <1182142451.6082.12.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krishna Kumar <kumarkr@linux.vnet.ibm.com>
Date: Mon, 18 Jun 2007 10:24:11 +0530

> (Same from previous patch, resending for completion)
> 
> Changes :
> 
> - netif_queue_stopped need not be called inside qdisc_restart as
>   it has been called already in qdisc_run() before the first skb
>   is sent, and in __qdisc_run() after each intermediate skb is 
>   sent (note : we are the only sender, so the queue cannot get
>   stopped while the tx lock was got in the ~LLTX case).
> 
> - BUG_ON((int) q->q.qlen < 0) was a relic from old times when -1
>   meant more packets are available, and __qdisc_run used to loop
>   when qdisc_restart() returned -1. During those days, it was
>   necessary to make sure that qlen is never less than zero, since
>   __qdisc_run would get into an infinite loop if no packets are on
>   the queue and this bug in qdisc was there (and worse - no more
>   skbs could ever get queue'd as we hold the queue lock too). With
>   Herbert's recent change to return values, this check is not
>   required.  Hopefully Herbert can validate this change. If at all
>   this is required, it should be added to skb_dequeue (in failure
>   case), and not to qdisc_qlen.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

Also applied to net-2.6.23, thanks a lot!
