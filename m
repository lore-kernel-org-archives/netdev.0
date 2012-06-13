From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next patch 8/12] bnx2x: Allow up to 63 RSS queues default
 8 queues
Date: Wed, 13 Jun 2012 15:59:15 +0200
Message-ID: <1339595955.22704.352.camel@edumazet-glaptop>
References: <1339591464-10554-1-git-send-email-meravs@broadcom.com>
	 <1339591464-10554-9-git-send-email-meravs@broadcom.com>
	 <1339581175.22704.342.camel@edumazet-glaptop>
	 <1339600460.17240.69.camel@lb-tlvb-meravs.il.broadcom.com>
	 <1339595609.13000.15.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Merav Sicron <meravs@broadcom.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:43718 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753671Ab2FMN7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 09:59:23 -0400
Received: by eaak11 with SMTP id k11so216372eaa.19
        for <netdev@vger.kernel.org>; Wed, 13 Jun 2012 06:59:22 -0700 (PDT)
In-Reply-To: <1339595609.13000.15.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-13 at 16:53 +0300, Eilon Greenstein wrote:
> On Wed, 2012-06-13 at 18:14 +0300, Merav Sicron wrote:
> > Hi Eric,
> > 
> > On Wed, 2012-06-13 at 11:52 +0200, Eric Dumazet wrote:
> > > On Wed, 2012-06-13 at 15:44 +0300, Merav Sicron wrote:
> > > > This patch removed the limitation in the code for 16 RSS queues. The default
> > > > (without other instruction from the user) number of queues is determined
> > > > according to the number of MSI-X vectors supported for that function, the number
> > > > of CPUs in the system, and a maximum of 8 queues.
> > > 
> > > Thats a very confusing changelog
> > > 
> > > You meant : " a minimum of 8 queues" ?
> > > 
> > No, I meant maximum...for example in a system with 16 CPUs we will
> > allocate 8 RSS queues. We saw that in most scenarios we tested there was
> > no need for more than 8 queues to get the maximal throughput, and by
> > limiting to 8 by default we reduce the allocated memory. We do provide
> > ethtool -L support so that the user could request more RSS queues if
> > desired.
> > 
> > > You should give more explanations, because its a sensible area for
> > > performances.
> > > 
> 
> Just to emphasis, since this is the patch series that enable the users
> to control the number of queues, we can reduce the default number and
> allow the user to increase it if he has a setup that needs more than 8
> parallel CPUs to receive the traffic. When using a new FW on the board,
> the number can be increased up to 64, so using the maximal number can be
> an overkill (even if the machine has 64 CPUs, it does not mean that the
> user would like us to consume 64 MSI-X vectors and all the memory to set
> up 64 queues) - so a lower default value can be used to satisfy most
> users while allowing them to increase the number if they wish.

I am all for a reduction of default number of queues.

Even a laptop has now 8 cpus, so on servers, using one queue per cpu is
overkill for most uses.

Thanks
