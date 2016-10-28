From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net 1/2] vxlan: avoid using stale vxlan socket.
Date: Fri, 28 Oct 2016 09:59:33 -0700
Message-ID: <CAOrHB_D3XJJyCXR4xXT_pwSOfBZnOPquUboy5bTCNrE+d72d9A@mail.gmail.com>
References: <1477594316-118234-1-git-send-email-pshelar@ovn.org> <20161027160219.06a946f4@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:34615 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032557AbcJ1Q7n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 12:59:43 -0400
Received: from mfilter20-d.gandi.net (mfilter20-d.gandi.net [217.70.178.148])
        by relay3-d.mail.gandi.net (Postfix) with ESMTP id 4F08FA80E1
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 18:59:36 +0200 (CEST)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
        by mfilter20-d.gandi.net (mfilter20-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 4oSI5FOvZUti for <netdev@vger.kernel.org>;
        Fri, 28 Oct 2016 18:59:34 +0200 (CEST)
Received: from mail-yw0-f177.google.com (mail-yw0-f177.google.com [209.85.161.177])
        (Authenticated sender: pshelar@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id C59DFA80D0
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 18:59:34 +0200 (CEST)
Received: by mail-yw0-f177.google.com with SMTP id w3so92658623ywg.1
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 09:59:34 -0700 (PDT)
In-Reply-To: <20161027160219.06a946f4@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 27, 2016 at 4:02 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Thu, 27 Oct 2016 11:51:55 -0700
> Pravin B Shelar <pshelar@ovn.org> wrote:
>
>> -     vxlan->vn4_sock = NULL;
>> +     rcu_assign_pointer(vxlan->vn4_sock, NULL);
>>  #if IS_ENABLED(CONFIG_IPV6)
>> -     vxlan->vn6_sock = NULL;
>> +     rcu_assign_pointer(vxlan->vn6_sock, NULL);
>>       if (ipv6 || metadata)
>
> User RCU_INIT_POINTER when setting pointer to NULL.
> It avoids unnecessary barrier.

OK. I have posted v2 patch to use RCU_INIT_POINTER().
