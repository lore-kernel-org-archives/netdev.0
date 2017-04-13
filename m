From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next 0/8] net/ncsi: Add debugging functionality
Date: Thu, 13 Apr 2017 17:57:00 +1000
Message-ID: <20170413075700.GA21810@gwshan>
References: <1492051600-26706-1-git-send-email-gwshan@linux.vnet.ibm.com>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:50895 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751193AbdDMH6D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 03:58:03 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3D7vmGi051789
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 03:58:03 -0400
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29sv15tq74-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 03:58:02 -0400
Received: from localhost
        by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 13 Apr 2017 17:58:00 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
        by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3D7vnTM31916036
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 17:57:57 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
        by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3D7vOmV012423
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 17:57:24 +1000
Content-Disposition: inline
In-Reply-To: <1492051600-26706-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 13, 2017 at 12:46:32PM +1000, Gavin Shan wrote:
>This series supports NCSI debugging infrastructure by adding several
>procfs files. It was inspired by the reported issues: No available
>package and channel are probed successfully. Obviously, we don't
>have a debugging infrastructure for NCSI stack yet.
>
>The first 3 patches, fixing some issues, aren't relevant to the
>subject. I included them because I expect they can be merged beofre
>the code for debugging infrastructure. PATCH[4,5,6/8] adds procfs
>directories and files to support the debugging infrastructure for
>several purposes: presenting the NCSI topology; statistics on sent
>and received NCSI packets; generate NCSI command packet manually.
>PATCH[7,8/8] fixes two issues found from the debugging functionality.
>

An updated series (v2) was posted, to replace procfs with debugfs
according to Joe's comment on PATCH[5/8]. Please review v2 if possible.

Cheers,
Gavin

>Gavin Shan (8):
>  net/ncsi: Disable HWA mode when no channels are found
>  net/ncsi: Properly track channel monitor timer state
>  net/ncsi: Enforce failover on link monitor timeout
>  net/ncsi: Add debugging infrastructurre
>  net/ncsi: Dump NCSI packet statistics
>  net/ncsi: Support NCSI packet generation
>  net/ncsi: No error report on DP response to non-existing package
>  net/ncsi: Fix length of GVI response packet
>
> net/ncsi/Kconfig       |   9 +
> net/ncsi/Makefile      |   1 +
> net/ncsi/internal.h    |  68 ++++
> net/ncsi/ncsi-aen.c    |  15 +-
> net/ncsi/ncsi-cmd.c    |  23 +-
> net/ncsi/ncsi-debug.c  | 961 +++++++++++++++++++++++++++++++++++++++++++++++++
> net/ncsi/ncsi-manage.c |  63 +++-
> net/ncsi/ncsi-rsp.c    |  37 +-
> 8 files changed, 1165 insertions(+), 12 deletions(-)
> create mode 100644 net/ncsi/ncsi-debug.c
>
>-- 
>2.7.4
>
