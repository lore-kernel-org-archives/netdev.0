From: "Merav Sicron" <meravs@broadcom.com>
Subject: Re: [net-next patch 8/12] bnx2x: Allow up to 63 RSS queues
 default 8 queues
Date: Thu, 14 Jun 2012 18:34:06 +0300
Message-ID: <1339688046.20038.3.camel@lb-tlvb-meravs.il.broadcom.com>
References: <1339581175.22704.342.camel@edumazet-glaptop>
 <1339600460.17240.69.camel@lb-tlvb-meravs.il.broadcom.com>
 <1339595609.13000.15.camel@lb-tlvb-eilong.il.broadcom.com>
 <20120613.153517.901328280865603627.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4142 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751538Ab2FNMcX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2012 08:32:23 -0400
In-Reply-To: <20120613.153517.901328280865603627.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-13 at 15:35 -0700, David Miller wrote:
> From: "Eilon Greenstein" <eilong@broadcom.com>
> Date: Wed, 13 Jun 2012 16:53:29 +0300
> 
> > Just to emphasis, since this is the patch series that enable the users
> > to control the number of queues, we can reduce the default number and
> > allow the user to increase it if he has a setup that needs more than 8
> > parallel CPUs to receive the traffic. When using a new FW on the board,
> > the number can be increased up to 64, so using the maximal number can be
> > an overkill (even if the machine has 64 CPUs, it does not mean that the
> > user would like us to consume 64 MSI-X vectors and all the memory to set
> > up 64 queues) - so a lower default value can be used to satisfy most
> > users while allowing them to increase the number if they wish.
> 
> I think you should look at other drivers for guidance in this area.
> 
> There is zero value in each and every driver author deciding what
> is a good default strategy, because this means the user gets a
> very inconsistent experience based purely upon the driver author's
> whims.
> 

We looked at few other drivers - their current behavior is similar to
what bnx2x had before this change: Minimum between the number of CPU and
a defined maximum (probably the HW limit).
bnx2x HW limit is 64 (in most other drivers it is smaller, but this can
change). The number of CPUs in new systems becomes bigger and bigger,
and allocaintg so many RSS queues seems like a waste. With the
relatively new ethtool -L feature the user can change the number of
queues. That's why we think (and so does Eric Dumazet) that it is better
to have a smaller default number which is good for most cases.
Do you agree with that?

Thanks,
Merav
