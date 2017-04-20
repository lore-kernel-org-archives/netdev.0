From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net] ipv4: Avoid caching dsts when lookup skipped nh oif
 check
Date: Thu, 20 Apr 2017 16:35:16 +0100
Message-ID: <f3a3ab2d-4a32-a3ec-6a72-071e56577017@brocade.com>
References: <1492693132-4708-1-git-send-email-rshearma@brocade.com>
 <bed3d38c-dc00-1f98-371c-852170af0a0e@cumulusnetworks.com>
 <ec8e470e-73d0-b357-4f65-a4f7e020db7f@brocade.com>
 <8dcaa797-c566-a9dc-d9a1-99e8d1acfe15@cumulusnetworks.com>
 <277d8c4b-5a18-cda2-6edc-66837cae6469@brocade.com>
 <7204751a-70f9-5803-d5af-06b62530b762@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:56900 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S970369AbdDTPfi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 11:35:38 -0400
In-Reply-To: <7204751a-70f9-5803-d5af-06b62530b762@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/04/17 16:16, David Ahern wrote:
> On 4/20/17 9:05 AM, Robert Shearman wrote:
>> The key thing I think is the ip rules:
>>
>> $ ip rule
>> 0:    from all lookup local
>> 1000:    from all lookup [l3mdev-table]
>> 32766:    from all lookup main
>> 32767:    from all lookup default
>>
>> Maybe you have the local rule moved down at startup?
>
> yes that would be a problem. With this test the 127.0.0.1 lookup is
> matching on the wrong table:
>
> perf probe fib_table_lookup%return ret=%ax
> perf record -e fib:*,probe:* -a -- ping -c1 -w1 -I red 127.0.0.1
> ...
> perf script
>
...
> Table 255 is the wrong table. That is the ultimate problem here.
>

The table used for the lookup could be retrieved from the oif, but the 
check I introduced would still be required to cope with the unusual, but 
not disallowed, case of two VRF master devices referring to the same table.

Thanks,
Rob
