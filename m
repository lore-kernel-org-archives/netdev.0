From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: Fix inconsistent rtnl_lock usage on
 dev_get_stats().
Date: Fri, 06 Jan 2017 09:32:56 -0800
Message-ID: <1483723976.9712.19.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1483676478-14228-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36666 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752535AbdAFRc6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 12:32:58 -0500
Received: by mail-pf0-f196.google.com with SMTP id b22so3855209pfd.3
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2017 09:32:57 -0800 (PST)
In-Reply-To: <1483676478-14228-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-01-05 at 23:21 -0500, Michael Chan wrote:
> Some callers take rtnl_lock() before calling dev_get_stats() and some
> don't.  Most network drivers expect the ndo_get_stats64() to be called
> under rtnl_lock() to avoid race conditions with device close or ethtool
> reconfigurations.  Fix it so that all callers take rtnl_lock().
> 
> Rename the original dev_get_stats() as __dev_get_stats() and add a new
> dev_get_stats() that takes rtnl_lock() before calling __dev_get_stats().
> Modify all callers that already take rtnl_lock() to call __dev_get_stats().

This makes no sense to me.

RTNL is absolutely not needed to get device stats.

We try to not add RTNL, especially when not required.

Sure, RTNETLINK dumps currently hold RTNL, but we had various attempts
in the past to get rid of this behavior.

If a device driver expects RTNL being locked, it is clearly a bug that
needs a fix anyway.
