From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 net-next 06/10] net/ncsi: Ethtool operation to get
 NCSI hw statistics
Date: Thu, 4 May 2017 10:05:34 +1000
Message-ID: <20170504000534.GA11287@gwshan>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1493786681-27468-7-git-send-email-gwshan@linux.vnet.ibm.com>
 <20170503124722.GE8029@lunn.ch>
 <20170503.091823.747316360571887178.davem@davemloft.net>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andrew@lunn.ch, gwshan@linux.vnet.ibm.com, netdev@vger.kernel.org,
        joe@perches.com, kubakici@wp.pl, f.fainelli@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:47275 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751753AbdEDAGg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 20:06:36 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4403XcM108585
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 20:06:36 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a7hbjcb13-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 20:06:36 -0400
Received: from localhost
        by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 4 May 2017 10:06:33 +1000
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
        by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v4406Nxm8061194
        for <netdev@vger.kernel.org>; Thu, 4 May 2017 10:06:31 +1000
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
        by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v4405xvD020366
        for <netdev@vger.kernel.org>; Thu, 4 May 2017 10:05:59 +1000
Content-Disposition: inline
In-Reply-To: <20170503.091823.747316360571887178.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 03, 2017 at 09:18:23AM -0400, David Miller wrote:
>From: Andrew Lunn <andrew@lunn.ch>
>Date: Wed, 3 May 2017 14:47:22 +0200
>
>> On Wed, May 03, 2017 at 02:44:37PM +1000, Gavin Shan wrote:
>>> This adds ethtool command (ETHTOOL_GNCSISTATS) to retrieve the
>>> NCSI hardware statistics.
>> 
>> Hi Gavin
>> 
>> I've not been following this patchset, so maybe i'm about to ask a
>> question which has already been asked and answered.
>> 
>> Why cannot use just use ethtool -S for this?
>
>Indeed, when I said to use ethtool for these NCSI hw stats I meant
>that the "ethtool -S" be used, not some new ethtool command.
>

Thanks for the comments. Feel free to ask any questions which would
make the code clear and better. There are couple of factors I thought
separate command is better than ETHTOOL_GSTATS: The statistic items from
ETHTOOL_GSTATS are variable, meaning the kernel needs provide the layout
of the statistic items via ETHTOOL_GSSET_INFO and ETHTOOL_GSTRINGS.
NCSI HW statistics aren't following this and their layout is fixed.
Besides, statistics for ETHTOOL_GSTATS are maintained in local MAC,
but NCSI HW statistics are collected from NIC on far-end. So they're
different from this point. Lastly, the NCSI software statistics needs
separate command. It'd better to have separate command for HW statistics
as well, to make things consistent.

Cheers,
Gavin
