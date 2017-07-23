From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v3 1/1] geneve: add rtnl changelink support
Date: Sun, 23 Jul 2017 10:14:46 -0700
Message-ID: <CAOrHB_Dbhs1PTqvAtPNdKWi9_rRF16zVsf1iOnQzn0-HYEaK5Q@mail.gmail.com>
References: <1500615860-7081-1-git-send-email-girish.moodalbail@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Girish Moodalbail <girish.moodalbail@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:51797 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751406AbdGWROt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Jul 2017 13:14:49 -0400
Received: from mail-wr0-f181.google.com (mail-wr0-f181.google.com [209.85.128.181])
        (Authenticated sender: pshelar@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id E8D51C5A54
        for <netdev@vger.kernel.org>; Sun, 23 Jul 2017 19:14:47 +0200 (CEST)
Received: by mail-wr0-f181.google.com with SMTP id 33so41476215wrz.4
        for <netdev@vger.kernel.org>; Sun, 23 Jul 2017 10:14:47 -0700 (PDT)
In-Reply-To: <1500615860-7081-1-git-send-email-girish.moodalbail@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 20, 2017 at 10:44 PM, Girish Moodalbail
<girish.moodalbail@oracle.com> wrote:
> This patch adds changelink rtnl operation support for geneve devices
> and the code changes involve:
>
>   - added geneve_quiesce() which quiesces the geneve device data path
>     for both TX and RX. This lets us perform the changelink operation
>     atomically w.r.t data path. Also added geneve_unquiesce() to
>     reverse the operation of geneve_quiesce().
>
>   - refactor geneve_newlink into geneve_nl2info to be used by both
>     geneve_newlink and geneve_changelink
>
>   - geneve_nl2info takes a changelink boolean argument to isolate
>     changelink checks.
>
>   - Allow changing only a few attributes (ttl, tos, and remote tunnel
>     endpoint IP address (within the same address family)):
>     - return -EOPNOTSUPP for attributes that cannot be changed for
>       now. Incremental patches can make the non-supported one
>       available in the future if needed.
>
> Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>
> ---
> v2 -> v3:
>    - removed the use of inline for new functions in my patch
>    - removed an extra check for socket in the datapath and instead
>      I am piggybacking on an already existing check
>    - added more comments to quiesce/unquiesce functions
>
> v1 -> v2:
>    - added geneve_quiesce() and geneve_unquiesce() functions to
>      perform the changelink operation atomically w.r.t data path

Thanks for working on it.

Acked-by: Pravin B Shelar <pshelar@ovn.org>
