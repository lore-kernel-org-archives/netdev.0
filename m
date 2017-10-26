From: Matthew Rosato <mjrosato@linux.vnet.ibm.com>
Subject: Re: Regression in throughput between kvm guests over virtual bridge
Date: Thu, 26 Oct 2017 13:53:12 -0400
Message-ID: <da80025f-6942-615f-570e-5005a25eb147@linux.vnet.ibm.com>
References: <7d444584-3854-ace2-008d-0fdef1c9cef4@linux.vnet.ibm.com>
 <1173ab1f-e2b6-26b3-8c3c-bd5ceaa1bd8e@redhat.com>
 <129a01d9-de9b-f3f1-935c-128e73153df6@linux.vnet.ibm.com>
 <3f824b0e-65f9-c69c-5421-2c5f6b349b09@redhat.com>
 <78678f33-c9ba-bf85-7778-b2d0676b78dd@linux.vnet.ibm.com>
 <038445a6-9dd5-30c2-aac0-ab5efbfa7024@linux.vnet.ibm.com>
 <20171012183132.qrbgnmvki6lpgt4a@Wei-Dev>
 <c0b42b27-56f6-c2f9-9476-28d25678808a@linux.vnet.ibm.com>
 <376f8939-1990-abf6-1f5f-57b3822f94fe@redhat.com>
 <c117c0c5-7fc0-013b-6f54-2e722d115101@linux.vnet.ibm.com>
 <20171026094415.uyogf2iw7yoavnoc@Wei-Dev>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Jason Wang <jasowang@redhat.com>, mst@redhat.com,
        netdev@vger.kernel.org, davem@davemloft.net
To: Wei Xu <wexu@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:60728 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932291AbdJZRxT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 13:53:19 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9QHh8go138745
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 13:53:19 -0400
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dujhr5vd5-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 13:53:18 -0400
Received: from localhost
        by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <mjrosato@linux.vnet.ibm.com>;
        Thu, 26 Oct 2017 11:53:17 -0600
In-Reply-To: <20171026094415.uyogf2iw7yoavnoc@Wei-Dev>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> Are you using the same binding as mentioned in previous mail sent by you? it
> might be caused by cpu convention between pktgen and vhost, could you please
> try to run pktgen from another idle cpu by adjusting the binding? 

I don't think that's the case -- I can cause pktgen to hang in the guest
without any cpu binding, and with vhost disabled even.

> BTW, did you see any improvement when running pktgen from the host if no 
> regression was found? Since this can be reproduced with only 1 vcpu for
> guest, may you try this bind? This might help simplify the problem.
>   vcpu0  -> cpu2
>   vhost  -> cpu3
>   pktgen -> cpu1 
> 

Yes -- I ran the pktgen test from host to guest with the binding
described.  I see an approx 5% increase in throughput from 4.12->4.13.
Some numbers:

host-4.12: 1384486.2pps 663.8MB/sec
host-4.13: 1434598.6pps 688.2MB/sec
