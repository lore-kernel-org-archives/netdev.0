From: Andy Zhou <azhou@ovn.org>
Subject: Re: [net-next sample action optimization v2 1/4] openvswitch:
 Deferred fifo API change.
Date: Thu, 16 Mar 2017 12:21:07 -0700
Message-ID: <CABKoBm1sro_Bo4HMgPTTJYsd+XBNENMMy_vo1o2Fx_GRMN9v1Q@mail.gmail.com>
References: <1489532891-33497-1-git-send-email-azhou@ovn.org>
 <1489532891-33497-2-git-send-email-azhou@ovn.org> <CAOrHB_B9_HpA38SL8V66=wOi9enTpgQ_Di-Kf5CUJ0oLPS97xA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Joe Stringer <joe@ovn.org>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:49060 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752440AbdCPTdB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 15:33:01 -0400
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net [217.70.183.195])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id 9F92547BCB6
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 20:22:52 +0100 (CET)
Received: from mfilter9-d.gandi.net (mfilter9-d.gandi.net [217.70.178.138])
        by relay3-d.mail.gandi.net (Postfix) with ESMTP id 2A95AA80D5
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 20:21:51 +0100 (CET)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
        by mfilter9-d.gandi.net (mfilter9-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 1s1j6Gdt5XpC for <netdev@vger.kernel.org>;
        Thu, 16 Mar 2017 20:21:49 +0100 (CET)
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
        (Authenticated sender: azhou@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id A9491A80CD
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 20:21:49 +0100 (CET)
Received: by mail-pf0-f177.google.com with SMTP id w189so28722433pfb.0
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 12:21:49 -0700 (PDT)
In-Reply-To: <CAOrHB_B9_HpA38SL8V66=wOi9enTpgQ_Di-Kf5CUJ0oLPS97xA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 16, 2017 at 10:28 AM, Pravin Shelar <pshelar@ovn.org> wrote:
> On Tue, Mar 14, 2017 at 4:08 PM, Andy Zhou <azhou@ovn.org> wrote:
>> add_deferred_actions() API currently requires actions to be passed in
>> as a fully encoded netlink message. So far both 'sample' and 'recirc'
>> actions happens to carry actions as fully encoded netlink messages.
>> However, this requirement is more restrictive than necessary, future
>> patch will need to pass in action lists that are not fully encoded
>> by themselves.
>
> It is not obvious why this change is required?
> can you explain it.

The original 'attr' requires a nested netlink message for the callee
to get the size of
the actions list.  In the sample case, since we rewrite sample into an
internal format that
does not have actions encoded as a nested netlink, we will need to
pass both pointer
to the first action, and the size of the actions list.
