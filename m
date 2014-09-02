From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next v2 2/2] Re-check for a VIO_DESC_READY data
 descriptor after short udelay()
Date: Tue, 2 Sep 2014 12:32:38 -0400
Message-ID: <20140902163238.GD31516@oracle.com>
References: <20140902162029.GC31516@oracle.com>
 <5405EFE7.4090302@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:23128 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073AbaIBQck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 12:32:40 -0400
Received: from acsinet21.oracle.com (acsinet21.oracle.com [141.146.126.237])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id s82GWdxa024928
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 2 Sep 2014 16:32:40 GMT
Received: from aserz7022.oracle.com (aserz7022.oracle.com [141.146.126.231])
	by acsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id s82GWcRG006891
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 2 Sep 2014 16:32:39 GMT
Received: from abhmp0007.oracle.com (abhmp0007.oracle.com [141.146.116.13])
	by aserz7022.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id s82GWcSk029740
	for <netdev@vger.kernel.org>; Tue, 2 Sep 2014 16:32:38 GMT
Content-Disposition: inline
In-Reply-To: <5405EFE7.4090302@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (09/02/14 12:27), David L Stevens wrote:
> Sowmini,
> 	One of the things I found while looking at the code is that the
> write memory barrier is in the wrong place. I have a patch to fix it, but
> it means the last descriptor will NOT be marked as ready until the cache
> is flushed, which may be delayed.

I see.

I can certainly try that (could you please share that patch offline?)
But this fudge-factored delay (which, fwiw, I too cringed to add)
was actually motivated by some observations on other non-linux OS-es.

> 	That fix may make this one moot. Maybe not, but certainly there is
> an unnecessary delay in notifying the peer because of that bug. The fix is
> simply to move the "wmb()" after, instead of before, setting VIO_DESC_READY.
> I mentioned it in our stand-up last week, which you couldn't attend, because
> I pointed it out for the VDC driver, which also has the same problem.
> 
> 	You may want to retry with that change to see if the delay still
> helps.
