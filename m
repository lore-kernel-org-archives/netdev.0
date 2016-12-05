From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [net PATCH 2/2] ipv4: Drop suffix update from resize code
Date: Mon, 5 Dec 2016 19:27:38 +0000
Message-ID: <e78286e1-18eb-e900-bb65-a00c5611263c@brocade.com>
References: <20161201121605.15499.13176.stgit@ahduyck-blue-test.jf.intel.com>
 <20161201122757.15499.51778.stgit@ahduyck-blue-test.jf.intel.com>
 <46f96f3a-0e8a-5eff-0f2d-7aeb6aec8c23@brocade.com>
 <20161205.122846.557360857895468724.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <alexander.h.duyck@intel.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:46125 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751328AbcLEUVE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 15:21:04 -0500
In-Reply-To: <20161205.122846.557360857895468724.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/12/16 17:28, David Miller wrote:
> From: Robert Shearman <rshearma@brocade.com>
> Date: Mon, 5 Dec 2016 15:05:18 +0000
>
>> On 01/12/16 12:27, Alexander Duyck wrote:
>>> It has been reported that update_suffix can be expensive when it is
>>> called
>>> on a large node in which most of the suffix lengths are the same.  The
>>> time
>>> required to add 200K entries had increased from around 3 seconds to
>>> almost
>>> 49 seconds.
>>>
>>> In order to address this we need to move the code for updating the
>>> suffix
>>> out of resize and instead just have it handled in the cases where we
>>> are
>>> pushing a node that increases the suffix length, or will decrease the
>>> suffix length.
>>>
>>> Fixes: 5405afd1a306 ("fib_trie: Add tracking value for suffix length")
>>> Reported-by: Robert Shearman <rshearma@brocade.com>
>>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>>
>> $ time sudo ip route restore < ~/allroutes
>> RTNETLINK answers: File exists
>> RTNETLINK answers: File exists
>> RTNETLINK answers: File exists
>> RTNETLINK answers: File exists
>
> What are these errors all about?

These are just routes that are already added by the system but are 
present in the dump:

$ ip route showdump < ~/allroutes | grep -v 110.110.110.2
default via 192.168.100.1 dev eth0  proto static  metric 1024
10.37.96.0/20 dev eth2  proto kernel  scope link  src 10.37.96.204
110.110.110.0/24 dev eth1  proto kernel  scope link  src 110.110.110.1
192.168.100.0/24 dev eth0  proto kernel  scope link  src 192.168.100.153

So the errors are expected and are seen both with and without these patches.

Thanks,
Rob
