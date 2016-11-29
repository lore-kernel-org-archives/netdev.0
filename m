From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: bnx2 breaks Dell R815 BMC IPMI since 4.8
Date: Wed, 30 Nov 2016 10:28:08 +1100
Message-ID: <20161129232808.GA14919@gwshan>
References: <583D26EF.60207@inria.fr>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Network Development list <netdev@vger.kernel.org>,
        Baoquan He <bhe@redhat.com>
To: Brice Goglin <Brice.Goglin@inria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:46324 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752250AbcK2X0w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 18:26:52 -0500
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uATNO9ao135469
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 18:26:51 -0500
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
        by mx0a-001b2d01.pphosted.com with ESMTP id 271gfc00cs-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 18:26:51 -0500
Received: from localhost
        by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Wed, 30 Nov 2016 09:26:49 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
        by d23dlp01.au.ibm.com (Postfix) with ESMTP id 9EF472CE8046
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 10:26:45 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
        by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uATNQj1Y65732790
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 10:26:45 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
        by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uATNQjL7025653
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 10:26:45 +1100
Content-Disposition: inline
In-Reply-To: <583D26EF.60207@inria.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 07:57:51AM +0100, Brice Goglin wrote:
>Hello
>
>My Dell PowerEdge R815 doesn't have IPMI anymore when I boot a 4.8
>kernel, the BMC doesn't even ping anymore. Its Ethernet devices are 4 of
>those:
>
>01:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
>	DeviceName: Embedded NIC 1                          
>	Subsystem: Dell NetXtreme II BCM5709 Gigabit Ethernet
>	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
>	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>	Latency: 0, Cache Line Size: 64 bytes
>	Interrupt: pin A routed to IRQ 42
>	Region 0: Memory at e6000000 (64-bit, non-prefetchable) [size=32M]
>	Capabilities: <access denied>
>	Kernel driver in use: bnx2
>	Kernel modules: bnx2
>
>The only change in bnx2 between 4.7 and 4.8 appears to be this one:
>
>commit 3e1be7ad2d38c6bd6aeef96df9bd0a7822f4e51c
>Author: Baoquan He <bhe@redhat.com>
>Date:   Fri Sep 9 22:43:12 2016 +0800
>
>    bnx2: Reset device during driver initialization
>
>Could you patch actually break the BMC? What do I need to further debug
>this issue?
>

Brice, could you please confirm NCSI is enabled on BMC? It seems NCSI
AEN pakets aren't handled by NCSI stack on BMC side when resetting NIC
on host side. Those AEN packets usually help to reconfigure the (active)
NCSI channel and bring it back to service after the reset.

Thanks,
Gavin
