From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 net-next 08/10] net/ncsi: Support NCSI packet
 generation
Date: Thu, 4 May 2017 16:31:57 +1000
Message-ID: <20170504063156.GA7620@gwshan>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1493786681-27468-9-git-send-email-gwshan@linux.vnet.ibm.com>
 <20170503125254.GF8029@lunn.ch>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org,
        joe@perches.com, kubakici@wp.pl, f.fainelli@gmail.com,
        davem@davemloft.net
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:45599 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750941AbdEDGdB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 02:33:01 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v446SsMV049437
        for <netdev@vger.kernel.org>; Thu, 4 May 2017 02:33:00 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a7vsq597e-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 02:33:00 -0400
Received: from localhost
        by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 4 May 2017 16:32:57 +1000
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
        by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v446Wlg24063658
        for <netdev@vger.kernel.org>; Thu, 4 May 2017 16:32:55 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
        by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v446WLsf009190
        for <netdev@vger.kernel.org>; Thu, 4 May 2017 16:32:23 +1000
Content-Disposition: inline
In-Reply-To: <20170503125254.GF8029@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 03, 2017 at 02:52:54PM +0200, Andrew Lunn wrote:
>On Wed, May 03, 2017 at 02:44:39PM +1000, Gavin Shan wrote:
>> This introduces /sys/kernel/debug/ncsi/eth0/pkt. The debugfs entry
>> can accept parameters to produce NCSI command packet. The received
>> NCSI response packet is dumped on read. Below is an example to send
>> CIS command and dump its response.
>> 
>>    # echo CIS,0,0 > /sys/kernel/debug/ncsi/eth0/pkt
>>    # cat /sys/kernel/debug/ncsi/eth0/pkt
>>    NCSI response [CIS] packet received
>> 
>>    00 01 dd 80 00 0004 0000 0000
>
>Could this be done with a raw socket for Tx and
>libpcap/tcpdump/wireshart for Rx?
>

Andrew, it's really good question. Unfortunately, I don't think it can
be done solely by raw socket to transmit NCSI command packet because the
[packet sequence number] field in the packet can't be same to any used ones.
Otherwise the remote NIC will be confused and start to reponse abnormally.

We could reserve some sequence number to be used by raw socket. However, to
avoid  duplicated packet sequence number from raw socket should be done. I
think it's overall more complexed than current implementation (debugfs). Also,
it's going to introduce protocol specific rules to raw socket implementation.
I'm not sure it's worthy.

Cheers,
Gavin
