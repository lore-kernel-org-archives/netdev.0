From: Sebastian Ott <sebott@linux.vnet.ibm.com>
Subject: Re: [PATCH net] net: bridge: start hello timer only if device is
 up
Date: Thu, 1 Jun 2017 21:44:01 +0200 (CEST)
Message-ID: <alpine.LFD.2.20.1706012141230.1834@schleppi>
References: <06ef2ff1-f29d-a163-3226-7bd43c7a407c@cumulusnetworks.com> <1496329675-11254-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        roopa@cumulusnetworks.com, Xin Long <lucien.xin@gmail.com>,
        Ivan Vecera <cera@cera.cz>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:47325 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751050AbdFAToJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 15:44:09 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v51JhSnl037576
        for <netdev@vger.kernel.org>; Thu, 1 Jun 2017 15:44:08 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2atjysk8y3-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 15:44:08 -0400
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <sebott@linux.vnet.ibm.com>;
        Thu, 1 Jun 2017 20:44:06 +0100
In-Reply-To: <1496329675-11254-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 1 Jun 2017, Nikolay Aleksandrov wrote:
> When the transition of NO_STP -> KERNEL_STP was fixed by always calling
> mod_timer in br_stp_start, it introduced a new regression which causes
> the timer to be armed even when the bridge is down, and since we stop
> the timers in its ndo_stop() function, they never get disabled if the
> device is destroyed before it's upped.
> 
> To reproduce:
> $ while :; do ip l add br0 type bridge hello_time 100; brctl stp br0 on;
> ip l del br0; done;
> 
> CC: Xin Long <lucien.xin@gmail.com>
> CC: Ivan Vecera <cera@cera.cz>
> CC: Sebastian Ott <sebott@linux.vnet.ibm.com>
> Reported-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
> Fixes: 6d18c732b95c ("bridge: start hello_timer when enabling KERNEL_STP in br_stp_start")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> Sebastian it'd be great if you can test the patch as well.

I did and can confirm that it fixes the problem.

Thanks,
Sebastian
