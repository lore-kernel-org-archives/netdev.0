From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] sctp: full support for ipv6 ip_nonlocal_bind &
 IP_FREEBIND
Date: Tue, 24 Oct 2017 18:40:42 +0900 (KST)
Message-ID: <20171024.184042.1443372549389419403.davem@davemloft.net>
References: <20171023171933.GA4592@ubuntu-desk-vm>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        lucien.xin@gmail.com
To: laszlth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58266 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751604AbdJXJkr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 05:40:47 -0400
In-Reply-To: <20171023171933.GA4592@ubuntu-desk-vm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Laszlo Toth <laszlth@gmail.com>
Date: Mon, 23 Oct 2017 19:19:33 +0200

> Commit 9b9742022888 ("sctp: support ipv6 nonlocal bind")
> introduced support for the above options as v4 sctp did,
> so patched sctp_v6_available().
> 
> In the v4 implementation it's enough, because
> sctp_inet_bind_verify() just returns with sctp_v4_available().
> However sctp_inet6_bind_verify() has an extra check before that
> for link-local scope_id, which won't respect the above options.
> 
> Added the checks before calling ipv6_chk_addr(), but
> not before the validation of scope_id.
> 
> before (w/ both options):
>  ./v6test fe80::10 sctp
>  bind failed, errno: 99 (Cannot assign requested address)
>  ./v6test fe80::10 tcp
>  bind success, errno: 0 (Success)
> 
> after (w/ both options):
>  ./v6test fe80::10 sctp
>  bind success, errno: 0 (Success)
> 
> Signed-off-by: Laszlo Toth <laszlth@gmail.com>

Applied.
