From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 2/2] ipv4: Drop suffix update from resize code
Date: Mon, 05 Dec 2016 12:28:46 -0500 (EST)
Message-ID: <20161205.122846.557360857895468724.davem@davemloft.net>
References: <20161201121605.15499.13176.stgit@ahduyck-blue-test.jf.intel.com>
        <20161201122757.15499.51778.stgit@ahduyck-blue-test.jf.intel.com>
        <46f96f3a-0e8a-5eff-0f2d-7aeb6aec8c23@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46680 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752483AbcLER2r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 12:28:47 -0500
In-Reply-To: <46f96f3a-0e8a-5eff-0f2d-7aeb6aec8c23@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Shearman <rshearma@brocade.com>
Date: Mon, 5 Dec 2016 15:05:18 +0000

> On 01/12/16 12:27, Alexander Duyck wrote:
>> It has been reported that update_suffix can be expensive when it is
>> called
>> on a large node in which most of the suffix lengths are the same.  The
>> time
>> required to add 200K entries had increased from around 3 seconds to
>> almost
>> 49 seconds.
>>
>> In order to address this we need to move the code for updating the
>> suffix
>> out of resize and instead just have it handled in the cases where we
>> are
>> pushing a node that increases the suffix length, or will decrease the
>> suffix length.
>>
>> Fixes: 5405afd1a306 ("fib_trie: Add tracking value for suffix length")
>> Reported-by: Robert Shearman <rshearma@brocade.com>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> $ time sudo ip route restore < ~/allroutes
> RTNETLINK answers: File exists
> RTNETLINK answers: File exists
> RTNETLINK answers: File exists
> RTNETLINK answers: File exists

What are these errors all about?
