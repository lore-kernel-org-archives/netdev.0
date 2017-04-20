From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next 0/3] l3mdev: Improve use with main table
Date: Thu, 20 Apr 2017 14:01:16 +0100
Message-ID: <256c2549-b831-2e7e-b18b-69243bb33ce3@brocade.com>
References: <1491834122-26252-1-git-send-email-rshearma@brocade.com>
 <822ee9b5-09d6-6987-deb3-6af9d537c891@cumulusnetworks.com>
 <a7204fbc-68b5-c6f4-c76c-d33b9c85d663@brocade.com>
 <e9cbd091-bb51-6f30-f31b-9080145caa93@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:32785 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751704AbdDTNBb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 09:01:31 -0400
In-Reply-To: <e9cbd091-bb51-6f30-f31b-9080145caa93@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/04/17 15:36, David Ahern wrote:
> On 4/13/17 6:48 AM, Robert Shearman wrote:
>>> the patches look ok to me, but in testing them I see I refcnt problem.
>>> simple reproducer:
>>>
>>> ip li add red type vrf table 254
>>> ip link set dev eth1 vrf red
>>> ip addr add 127.0.0.1/8 dev red
>>> ip link set dev eth1 up
>>> ip li set red up
>>> ping -c1 -w1 -I red 127.0.0.1
>>> ip li del red
>>> --> hangs with 'uregister_netdevice: waiting for red to become free.'
>>
>> Right, I've reproduced the same and it occurs even without using the
>> main table and I believe it has been introduced within the last week.
>
> The cached dst on sockets is one known place that causes a hang on a
> delete. Basically the delete stalls until the sockets are closed. I have
> a patch for sk_rx_dst which is the one I chased down last week.
> sk_dst_cache is another possibility.
>
> Neither of those should be at play with the above example because the
> ping command runs and then exits.

Thanks for the pointers. My earlier assessment that this was something 
recent turned out to be wrong. I've sent a patch against net that fixes 
the issue.

Thanks,
Rob
