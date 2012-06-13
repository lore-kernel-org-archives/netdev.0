From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [net-next patch 8/12] bnx2x: Allow up to 63 RSS queues
 default 8 queues
Date: Wed, 13 Jun 2012 16:53:29 +0300
Message-ID: <1339595609.13000.15.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1339591464-10554-1-git-send-email-meravs@broadcom.com>
 <1339591464-10554-9-git-send-email-meravs@broadcom.com>
 <1339581175.22704.342.camel@edumazet-glaptop>
 <1339600460.17240.69.camel@lb-tlvb-meravs.il.broadcom.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Merav Sicron" <meravs@broadcom.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2820 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753849Ab2FMOAd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 10:00:33 -0400
In-Reply-To: <1339600460.17240.69.camel@lb-tlvb-meravs.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-13 at 18:14 +0300, Merav Sicron wrote:
> Hi Eric,
> 
> On Wed, 2012-06-13 at 11:52 +0200, Eric Dumazet wrote:
> > On Wed, 2012-06-13 at 15:44 +0300, Merav Sicron wrote:
> > > This patch removed the limitation in the code for 16 RSS queues. The default
> > > (without other instruction from the user) number of queues is determined
> > > according to the number of MSI-X vectors supported for that function, the number
> > > of CPUs in the system, and a maximum of 8 queues.
> > 
> > Thats a very confusing changelog
> > 
> > You meant : " a minimum of 8 queues" ?
> > 
> No, I meant maximum...for example in a system with 16 CPUs we will
> allocate 8 RSS queues. We saw that in most scenarios we tested there was
> no need for more than 8 queues to get the maximal throughput, and by
> limiting to 8 by default we reduce the allocated memory. We do provide
> ethtool -L support so that the user could request more RSS queues if
> desired.
> 
> > You should give more explanations, because its a sensible area for
> > performances.
> > 

Just to emphasis, since this is the patch series that enable the users
to control the number of queues, we can reduce the default number and
allow the user to increase it if he has a setup that needs more than 8
parallel CPUs to receive the traffic. When using a new FW on the board,
the number can be increased up to 64, so using the maximal number can be
an overkill (even if the machine has 64 CPUs, it does not mean that the
user would like us to consume 64 MSI-X vectors and all the memory to set
up 64 queues) - so a lower default value can be used to satisfy most
users while allowing them to increase the number if they wish.

Thanks,
Eilon
