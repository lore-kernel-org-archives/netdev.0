From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 net-next 04/10] net/ncsi: Ethtool operation to get
 NCSI topology
Date: Thu, 4 May 2017 11:36:51 +1000
Message-ID: <20170504013651.GA26492@gwshan>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1493786681-27468-5-git-send-email-gwshan@linux.vnet.ibm.com>
 <20170504004933.GP8029@lunn.ch>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org,
        joe@perches.com, kubakici@wp.pl, f.fainelli@gmail.com,
        davem@davemloft.net
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:50102 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932179AbdEDBhz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 21:37:55 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v441YIBr079999
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 21:37:54 -0400
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2a7rubkp7u-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 21:37:53 -0400
Received: from localhost
        by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 4 May 2017 11:37:51 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
        by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v441bfUD4260132
        for <netdev@vger.kernel.org>; Thu, 4 May 2017 11:37:49 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
        by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v441bF9H022965
        for <netdev@vger.kernel.org>; Thu, 4 May 2017 11:37:16 +1000
Content-Disposition: inline
In-Reply-To: <20170504004933.GP8029@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 04, 2017 at 02:49:33AM +0200, Andrew Lunn wrote:
>> +void ncsi_ethtool_register_dev(struct net_device *dev)
>> +{
>> +	struct ethtool_ops *ops;
>> +
>> +	ops = (struct ethtool_ops *)(dev->ethtool_ops);
>
>Why do you need the cast here?
>
>Ah, is it because net_device has:
>
>          const struct ethtool_ops *ethtool_ops;
>
>i.e. you are casting off the const.
>
>> +	if (!ops)
>> +		return;
>> +
>> +	ops->get_ncsi_channels = ncsi_get_channels;
>
>and here you modify it. Which is going to blow up, because it will be
>in a read only segment and should throw an opps when you write to it?
>
>You need to export ncsi_get_channels, and let the underlying driver
>add it to its own ethtool_ops.
>

I didn't see oops because of this on the ARM board where I did the
testing. The intention was to make ethtool invisible to drivers, for
simplicity. However, we need to expose ethtool to driver when the HW
and SW statistics are conveyed by ETHTOOL_GSTATS as agree'd in another
thread.

Cheers,
Gavin
