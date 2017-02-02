From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next v2 11/12] bnxt_en: Add basic XDP support.
Date: Thu, 2 Feb 2017 13:30:02 -0800
Message-ID: <CACKFLimhDm1qgCJTYeTbL=bY+Jf7LF3-3x0F9+T2Dv8BVWorSg@mail.gmail.com>
References: <1486054540-366-1-git-send-email-michael.chan@broadcom.com>
 <1486054540-366-12-git-send-email-michael.chan@broadcom.com> <BL2PR07MB2306262459A2F72761A5C28C8D4C0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f181.google.com ([209.85.217.181]:35282 "EHLO
        mail-ua0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751245AbdBBVaD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 16:30:03 -0500
Received: by mail-ua0-f181.google.com with SMTP id y9so430531uae.2
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 13:30:03 -0800 (PST)
In-Reply-To: <BL2PR07MB2306262459A2F72761A5C28C8D4C0@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 2, 2017 at 9:18 AM, Mintz, Yuval <Yuval.Mintz@cavium.com> wrote:
>> +config BNXT_XDP
>> +     bool "Xpress Data Path (XDP) driver support"
>> +     default n
>> +     depends on BNXT && BPF
>> +     ---help---
>> +       Say Y here if you want to enable XDP in the driver to support
>> +       eBPF programs in the fast path.
>> +
>
> Wasn't it recently discussed that per-feature option is preferable
> to a per-feature per-device option?
> Assuming BPF > XDP and thus shouldn't directly imply that XDP
> should be supported, perhaps the right thing is to add a global
> XDP config option?

Since the driver has other per-device options, I'm adding another
per-device option right now.  It can easily be converted to a more
tree-wide option if that's what we want to do.

>
>> +     if (prog && bp->dev->mtu > BNXT_MAX_PAGE_MODE_MTU) {
>> +             netdev_err(dev, "MTU %d larger than largest XDP supported
>> MTU %d.\n",
>> +                        bp->dev->mtu, BNXT_MAX_PAGE_MODE_MTU);
>> +             return -EOPNOTSUPP;
>> +     }
>
> Is it O.k. to print with netdev_err() for a user-provided unsupported
> configuration? Shouldn't that be limited?

You are suggesting to use lower level warning, such as netdev_warn(), right?

>
>> +             bool sh = (bp->flags & BNXT_FLAG_SHARED_RINGS) ? true :
>> false;
>
> Didn't you already check this flag is set?
>

You are right.  I checked already.
