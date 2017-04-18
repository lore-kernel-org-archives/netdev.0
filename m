From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH] net/ncsi: fix checksum validation in response packet
Date: Tue, 18 Apr 2017 10:06:00 +1000
Message-ID: <20170418000600.GA4978@gwshan>
References: <1492160197-13816-1-git-send-email-clg@kaod.org>
 <20170417.133619.1515025171498720534.davem@davemloft.net>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: clg@kaod.org, gwshan@linux.vnet.ibm.com, joel@jms.id.au,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:55325 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751874AbdDRAHD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 20:07:03 -0400
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3I040xQ008759
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 20:07:02 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29vwn0gf65-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 20:07:02 -0400
Received: from localhost
        by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Tue, 18 Apr 2017 10:07:00 +1000
Content-Disposition: inline
In-Reply-To: <20170417.133619.1515025171498720534.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 17, 2017 at 01:36:19PM -0400, David Miller wrote:
>From: Cédric Le Goater <clg@kaod.org>
>Date: Fri, 14 Apr 2017 10:56:37 +0200
>
>> htonl was used instead of ntohl. Surely a typo.
>> 
>> Signed-off-by: Cédric Le Goater <clg@kaod.org>
>
>I don't think so, "checksum" is of type "u32" thus is in host byte
>order.  Therefore "htonl()" is correct.
>

Yeah, "htonl()" is correct here. "*pchecksum" is in big-endian.
I want to know how Cédric thinks it's a problem. I guess he might
encounter the issue on the emulated NCSI channel by QEMU. On BCM5718
or BCM5719, the checksum in AEN and response packet are zero'd, meaning
the software shouldn't validate it at all.

Thanks,
Gavin
