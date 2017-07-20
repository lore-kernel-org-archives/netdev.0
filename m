From: kiki good <jqiaoulk@gmail.com>
Subject: Re: [PATCH v2 net-next] net: systemport: Support 64bit statistics
Date: Thu, 20 Jul 2017 22:59:17 +0100
Message-ID: <CACM3AazCqONTODs8zR_MZ9VU7Tc53n+HNzBySwk-ESLzkOEFoQ@mail.gmail.com>
References: <1500423520-4169-1-git-send-email-jqiaoulk@gmail.com> <20170720084406.1ff2c446@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:37382 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934927AbdGTV7T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 17:59:19 -0400
Received: by mail-io0-f196.google.com with SMTP id 5so2614981iow.4
        for <netdev@vger.kernel.org>; Thu, 20 Jul 2017 14:59:18 -0700 (PDT)
In-Reply-To: <20170720084406.1ff2c446@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen:

Thanks for the suggestion of using per-cpu statistics. In this part of
code, there are two major reasons
not to use per-cpu variable for calculating Tx packets:

1. The update of ring->bytes and ring ->packets are protected with irq
version's spin lock in the current code logic. Although BH
     is disabled and it is safe to use per-cpu variable, i don't see
much more benefit of using it if it is still under irq version's spin
lock protection.

2. This driver requires update each ring's bytes and packets; The
number of rings are decided dynamically. so in order to use per-cpu
     variable, we need to track allocation and free every time when
the sizes of rings change that might have some performance concerns.

For Rx packets, using per-cpu variable is possible.

Thanks
Jmqiao

On Thu, Jul 20, 2017 at 4:44 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Wed, 19 Jul 2017 01:18:40 +0100
> "Jianming.qiao" <jqiaoulk@gmail.com> wrote:
>
>> Signed-off-by: Jianming.qiao <kiki-good@hotmail.com>
>
> You may want to consider using per-cpu statistics.
>
