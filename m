From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 net-next 06/10] net/ncsi: Ethtool operation to get
 NCSI hw statistics
Date: Thu, 4 May 2017 10:38:38 +1000
Message-ID: <20170504003838.GA16780@gwshan>
References: <20170503124722.GE8029@lunn.ch>
 <20170503.091823.747316360571887178.davem@davemloft.net>
 <20170504000534.GA11287@gwshan>
 <20170503.201643.358209122385716637.davem@davemloft.net>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gwshan@linux.vnet.ibm.com, andrew@lunn.ch, netdev@vger.kernel.org,
        joe@perches.com, kubakici@wp.pl, f.fainelli@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:33888 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751753AbdEDAjm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 20:39:42 -0400
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v440cVGY078736
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 20:39:42 -0400
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a79vu3bv2-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 20:39:41 -0400
Received: from localhost
        by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 4 May 2017 10:39:39 +1000
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
        by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v440dSr84325794
        for <netdev@vger.kernel.org>; Thu, 4 May 2017 10:39:36 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
        by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v440d3Em017443
        for <netdev@vger.kernel.org>; Thu, 4 May 2017 10:39:04 +1000
Content-Disposition: inline
In-Reply-To: <20170503.201643.358209122385716637.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 03, 2017 at 08:16:43PM -0400, David Miller wrote:
>From: Gavin Shan <gwshan@linux.vnet.ibm.com>
>Date: Thu, 4 May 2017 10:05:34 +1000
>> On Wed, May 03, 2017 at 09:18:23AM -0400, David Miller wrote:
>>>From: Andrew Lunn <andrew@lunn.ch>
>>>Date: Wed, 3 May 2017 14:47:22 +0200
>>>
>>>> On Wed, May 03, 2017 at 02:44:37PM +1000, Gavin Shan wrote:
>>>>> This adds ethtool command (ETHTOOL_GNCSISTATS) to retrieve the
>>>>> NCSI hardware statistics.
>>>> 
>>>> Hi Gavin
>>>> 
>>>> I've not been following this patchset, so maybe i'm about to ask a
>>>> question which has already been asked and answered.
>>>> 
>>>> Why cannot use just use ethtool -S for this?
>>>
>>>Indeed, when I said to use ethtool for these NCSI hw stats I meant
>>>that the "ethtool -S" be used, not some new ethtool command.
>>>
>> 
>> Thanks for the comments. Feel free to ask any questions which would
>> make the code clear and better. There are couple of factors I thought
>> separate command is better than ETHTOOL_GSTATS: The statistic items from
>> ETHTOOL_GSTATS are variable, meaning the kernel needs provide the layout
>> of the statistic items via ETHTOOL_GSSET_INFO and ETHTOOL_GSTRINGS.
>> NCSI HW statistics aren't following this and their layout is fixed.
>> Besides, statistics for ETHTOOL_GSTATS are maintained in local MAC,
>> but NCSI HW statistics are collected from NIC on far-end. So they're
>> different from this point. Lastly, the NCSI software statistics needs
>> separate command. It'd better to have separate command for HW statistics
>> as well, to make things consistent.
>
>ETHTOOL_GSTATS are for device specific statistics.  Whether they are
>fixed in your implementation or not.
>

For NCSI HW statistics, they're always fixed. It's assured by NCSI
specification. It seems my explanation isn't convincing enough. I'm
fine to convey NCSI HW statistics through ETHTOOL_GSTATS (ETHTOOL_GSSET_INFO
and ETHTOOL_GSTRINGS). Dave, please confirm it's what you're happy to
see?

Cheers,
Gavin
