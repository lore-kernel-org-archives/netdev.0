From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] bridge: resolve a false alarm of lockdep
Date: Thu, 16 Mar 2017 21:29:33 -0700 (PDT)
Message-ID: <20170316.212933.452192307618996956.davem@davemloft.net>
References: <1489685562-1436-1-git-send-email-xiyou.wangcong@gmail.com>
        <d5a67b06-d305-9cb5-2f41-b39988b948e0@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org, avagin@gmail.com
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56286 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751251AbdCQE3g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 00:29:36 -0400
In-Reply-To: <d5a67b06-d305-9cb5-2f41-b39988b948e0@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Thu, 16 Mar 2017 19:36:07 +0200

> On 16/03/17 19:32, Cong Wang wrote:
>> Andrei reported a false alarm of lockdep at net/bridge/br_fdb.c:109,
>> this is because in Andrei's case, a spin_bug() was already triggered
>> before this, therefore the debug_locks is turned off, lockdep_is_held()
>> is no longer accurate after that. We should use lockdep_assert_held_once()
>> instead of lockdep_is_held() to respect debug_locks.
>> 
>> Reported-by: Andrei Vagin <avagin@gmail.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> ---
>>  net/bridge/br_fdb.c     | 2 +-
>>  net/bridge/br_private.h | 9 ---------
>>  2 files changed, 1 insertion(+), 10 deletions(-)
>> 
> 
> Interesting, thanks Cong!
> 
> Fixes: 410b3d48f5111 ("bridge: fdb: add proper lock checks in searching functions")
> 
> Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied, thanks.
