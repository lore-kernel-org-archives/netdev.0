From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next 05/10] bnxt_en: Fix ethtool -l|-L inconsistent
 channel counts.
Date: Mon, 19 Sep 2016 09:39:08 -0700
Message-ID: <CACKFLintU=LqY7MR-ZLT5QMWe8PY2x=rCb_rr7Wy4d-T2JLJ+Q@mail.gmail.com>
References: <1474271889-8229-1-git-send-email-michael.chan@broadcom.com>
 <1474271889-8229-6-git-send-email-michael.chan@broadcom.com>
 <BL2PR07MB23060109CAF0760E41A8BB288DF40@BL2PR07MB2306.namprd07.prod.outlook.com>
 <CACKFLikfTZYpmULGD5FvzixFRiCjqvQZxUKKquaaQ5qe9-PxuA@mail.gmail.com>
 <BL2PR07MB23063DF1E02AA72ABE37DB4B8DF40@BL2PR07MB2306.namprd07.prod.outlook.com>
 <CACKFLi=H2dnv4hVi4hGCZC4LJabr4SK3f=z5+JzJE7y9jEMvMw@mail.gmail.com> <BL2PR07MB2306246BCB25E3C323A3F3A88DF40@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:32989 "EHLO
        mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751008AbcISQjK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 12:39:10 -0400
Received: by mail-io0-f173.google.com with SMTP id r145so97291801ior.0
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 09:39:09 -0700 (PDT)
In-Reply-To: <BL2PR07MB2306246BCB25E3C323A3F3A88DF40@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 19, 2016 at 2:51 AM, Mintz, Yuval <Yuval.Mintz@cavium.com> wrote:

>>
>> If the user chooses 2 rx and 1 tx, he will use 3 msix vectors (3 completion rings,
>> etc).  If the user chooses 2 combined (1 with rx/tx,
>> 1 with rx only), he will use 2 msix vectors (2 completion rings, etc).
>> With a large number of NPAR functions and SRIOV functions, the number of
>> rings available per function may not be symmetrical.  We just want maximum
>> flexibility to make use of all available resources in 2 different modes (one that
>> uses more resources and one that uses less).
>
> Sounds like the user should chose 1 combined in 1 rx in this scenario.

We only support all combined or all rx/tx.  Supporting arbitrary
combination of the 2 will add a lot more complication to the driver
code.  I don't think it will add any value to the user either.  In the
end, it's all the same and the user sees a simpler interface.  If
combined is chosen, the driver logic will combine all available rx/tx
ring pairs.  Any remaining rings will still be used to reach the
desired combined count.
