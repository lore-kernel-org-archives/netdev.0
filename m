From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH net 0/5] net/ncsi: More bug fixes
Date: Thu, 20 Oct 2016 11:54:55 +1100
Message-ID: <20161020005455.GA32270@gwshan>
References: <1476413614-24586-1-git-send-email-gwshan@linux.vnet.ibm.com>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, joel@jms.id.au
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:45661 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1756425AbcJTAyM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 20:54:12 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9K0n3sj145172
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 20:54:11 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
        by mx0b-001b2d01.pphosted.com with ESMTP id 266fq51bh1-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 20:54:11 -0400
Received: from localhost
        by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 20 Oct 2016 10:54:08 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
        by d23dlp02.au.ibm.com (Postfix) with ESMTP id 6A70E2BB0054
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 11:54:05 +1100 (EST)
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
        by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9K0s5CK19464364
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 11:54:05 +1100
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
        by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9K0s4fN017024
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 11:54:05 +1100
Content-Disposition: inline
In-Reply-To: <1476413614-24586-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 14, 2016 at 01:53:29PM +1100, Gavin Shan wrote:
>This series fixes 2 issues that were found during NCSI's availability
>testing on BCM5718 and improves HNCDSC AEN handler:
>
>   * PATCH[1] and PATCH[2] refactors the code so that minimal code
>     change is put to PATCH[3].
>   * PATCH[3] fixes the NCSI channel's stale link state before doing
>     failover.
>   * PATCH[4] chooses the hot channel, which was ever chosen as active
>     channel, when the available channels are all in link-down state.
>   * PATCH[5] improves Host Network Controller Driver Status Change
>     (HNCDSC) AEN handler
>

v2 addressing comments received from Joel has been posted. Joel, thanks
a lot for your time and comments :)

Thanks,
Gavin

>Gavin Shan (5):
>  net/ncsi: Not fetch active package and channel again
>  net/ncsi: Split out logic for ncsi_dev_state_suspend_select
>  net/ncsi: Fix stale link state of inactive channels on failover
>  net/ncsi: Choose hot channel as active one if necessary
>  net/ncsi: Improve HNCDSC AEN handler
>
> net/ncsi/internal.h    |  2 ++
> net/ncsi/ncsi-aen.c    | 18 ++++++++++--
> net/ncsi/ncsi-manage.c | 80 ++++++++++++++++++++++++++++++++++++++------------
> 3 files changed, 79 insertions(+), 21 deletions(-)
>
>-- 
>2.1.0
>
