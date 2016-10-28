From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net 2/2] geneve: avoid using stale geneve socket.
Date: Fri, 28 Oct 2016 10:01:51 -0700
Message-ID: <CAOrHB_DrV0+Tp4jgFMG45_PqgOZh-aYDEJFxT40La0v6RC2U8Q@mail.gmail.com>
References: <1477594316-118234-1-git-send-email-pshelar@ovn.org>
 <1477594316-118234-2-git-send-email-pshelar@ovn.org> <20161028142743.GB31148@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:38564 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935654AbcJ1RBz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 13:01:55 -0400
Received: from mfilter49-d.gandi.net (mfilter49-d.gandi.net [217.70.178.180])
        by relay3-d.mail.gandi.net (Postfix) with ESMTP id 14F0EA80E9
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 19:01:54 +0200 (CEST)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
        by mfilter49-d.gandi.net (mfilter49-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id Mj5lJI2yzpSS for <netdev@vger.kernel.org>;
        Fri, 28 Oct 2016 19:01:52 +0200 (CEST)
Received: from mail-yb0-f173.google.com (mail-yb0-f173.google.com [209.85.213.173])
        (Authenticated sender: pshelar@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id ADBCDA80C1
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 19:01:52 +0200 (CEST)
Received: by mail-yb0-f173.google.com with SMTP id d128so39512471ybh.2
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 10:01:52 -0700 (PDT)
In-Reply-To: <20161028142743.GB31148@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 28, 2016 at 7:27 AM, John W. Linville
<linville@tuxdriver.com> wrote:
> On Thu, Oct 27, 2016 at 11:51:56AM -0700, Pravin B Shelar wrote:
>> This patch is similar to earlier vxlan patch.
>> Geneve device close operation frees geneve socket. This
>> operation can race with geneve-xmit function which
>> dereferences geneve socket. Following patch uses RCU
>> mechanism to avoid this situation.
>>
>> Signed-off-by: Pravin B Shelar <pshelar@ovn.org>
>
> LGTM, although I reckon that Stephen's comment about RCU_INIT_POINTER
> applies to this patch as well.
>
Geneve code is bit different and it is using rcu_assign_pointer()
while destroying the object. so we need the barrier.

> Either way...
>
> Acked-by: John W. Linville <linville@tuxdriver.com>
>
