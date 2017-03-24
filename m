From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] tcp: sysctl: Fix a race to avoid
 unexpected 0 window from space
Date: Fri, 24 Mar 2017 13:29:28 -0700 (PDT)
Message-ID: <20170324.132928.1411503529271648421.davem@davemloft.net>
References: <1490310312-20661-1-git-send-email-gfree.wind@foxmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fgao@ikuai8.com
To: gfree.wind@foxmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44186 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964973AbdCXU3d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 16:29:33 -0400
In-Reply-To: <1490310312-20661-1-git-send-email-gfree.wind@foxmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: gfree.wind@foxmail.com
Date: Fri, 24 Mar 2017 07:05:12 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> Because sysctl_tcp_adv_win_scale could be changed any time, so there
> is one race in tcp_win_from_space.
> For example,
> 1.sysctl_tcp_adv_win_scale<=0 (sysctl_tcp_adv_win_scale is negative now)
> 2.space>>(-sysctl_tcp_adv_win_scale) (sysctl_tcp_adv_win_scale is postive now)
> 
> As a result, tcp_win_from_space returns 0. It is unexpected.
> 
> Certainly if the compiler put the sysctl_tcp_adv_win_scale into one
> register firstly, then use the register directly, it would be ok.
> But we could not depend on the compiler behavior.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Applied.
