From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: Re: [PATCH] af_iucv: Move sockaddr length checks to before accessing
 sa_family in bind and connect handlers
Date: Wed, 14 Jun 2017 16:49:06 +0200
Message-ID: <a2bafded-712e-6e8b-9395-b020c73dc06a@linux.vnet.ibm.com>
References: <20170613174228.9218-1-mjurczyk@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Mateusz Jurczyk <mjurczyk@google.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-s390@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:56591 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751705AbdFNOtP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 10:49:15 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5EEme8m015258
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 10:49:14 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2b35c7y5rk-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 10:49:14 -0400
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Wed, 14 Jun 2017 15:49:12 +0100
In-Reply-To: <20170613174228.9218-1-mjurczyk@google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/13/2017 07:42 PM, Mateusz Jurczyk wrote:
> Verify that the caller-provided sockaddr structure is large enough to
> contain the sa_family field, before accessing it in bind() and connect()
> handlers of the AF_IUCV socket. Since neither syscall enforces a minimum
> size of the corresponding memory region, very short sockaddrs (zero or
> one byte long) result in operating on uninitialized memory while
> referencing .sa_family.
> 
> Signed-off-by: Mateusz Jurczyk <mjurczyk@google.com>
Thanks Mateusz!

Fixes: 52a82e23b9f2
Acked-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
