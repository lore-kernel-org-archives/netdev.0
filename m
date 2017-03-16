From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [Patch net] bridge: resolve a false alarm of lockdep
Date: Thu, 16 Mar 2017 19:36:07 +0200
Message-ID: <d5a67b06-d305-9cb5-2f41-b39988b948e0@cumulusnetworks.com>
References: <1489685562-1436-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: avagin@gmail.com
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f170.google.com ([209.85.128.170]:36484 "EHLO
        mail-wr0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753102AbdCPRgK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 13:36:10 -0400
Received: by mail-wr0-f170.google.com with SMTP id u108so36973548wrb.3
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 10:36:09 -0700 (PDT)
In-Reply-To: <1489685562-1436-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/03/17 19:32, Cong Wang wrote:
> Andrei reported a false alarm of lockdep at net/bridge/br_fdb.c:109,
> this is because in Andrei's case, a spin_bug() was already triggered
> before this, therefore the debug_locks is turned off, lockdep_is_held()
> is no longer accurate after that. We should use lockdep_assert_held_once()
> instead of lockdep_is_held() to respect debug_locks.
> 
> Reported-by: Andrei Vagin <avagin@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/bridge/br_fdb.c     | 2 +-
>  net/bridge/br_private.h | 9 ---------
>  2 files changed, 1 insertion(+), 10 deletions(-)
> 

Interesting, thanks Cong!

Fixes: 410b3d48f5111 ("bridge: fdb: add proper lock checks in searching functions")

Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
