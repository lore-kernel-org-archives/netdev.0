From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [net PATCH 2/2] ipv4: Drop suffix update from resize code
Date: Mon, 5 Dec 2016 15:05:18 +0000
Message-ID: <46f96f3a-0e8a-5eff-0f2d-7aeb6aec8c23@brocade.com>
References: <20161201121605.15499.13176.stgit@ahduyck-blue-test.jf.intel.com>
 <20161201122757.15499.51778.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: Alexander Duyck <alexander.h.duyck@intel.com>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:49416 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750849AbcLEPHh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 10:07:37 -0500
In-Reply-To: <20161201122757.15499.51778.stgit@ahduyck-blue-test.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/16 12:27, Alexander Duyck wrote:
> It has been reported that update_suffix can be expensive when it is called
> on a large node in which most of the suffix lengths are the same.  The time
> required to add 200K entries had increased from around 3 seconds to almost
> 49 seconds.
>
> In order to address this we need to move the code for updating the suffix
> out of resize and instead just have it handled in the cases where we are
> pushing a node that increases the suffix length, or will decrease the
> suffix length.
>
> Fixes: 5405afd1a306 ("fib_trie: Add tracking value for suffix length")
> Reported-by: Robert Shearman <rshearma@brocade.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

$ time sudo ip route restore < ~/allroutes
RTNETLINK answers: File exists
RTNETLINK answers: File exists
RTNETLINK answers: File exists
RTNETLINK answers: File exists

real	0m4.026s
user	0m0.156s
sys	0m2.500s
$ time sudo ip route flush via 110.110.110.2

real	0m5.423s
user	0m0.064s
sys	0m1.096s

This reduces the time taken to both add and delete the 200k routes back 
down to levels comparable before commit 5405afd1a306. The changes look 
good to me too. Nicely done Alex!

Reviewed-by: Robert Shearman <rshearma@brocade.com>
Tested-by: Robert Shearman <rshearma@brocade.com>

Thanks,
Rob
