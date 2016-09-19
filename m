From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next 05/10] bnxt_en: Fix ethtool -l|-L inconsistent
 channel counts.
Date: Mon, 19 Sep 2016 01:57:55 -0700
Message-ID: <CACKFLikfTZYpmULGD5FvzixFRiCjqvQZxUKKquaaQ5qe9-PxuA@mail.gmail.com>
References: <1474271889-8229-1-git-send-email-michael.chan@broadcom.com>
 <1474271889-8229-6-git-send-email-michael.chan@broadcom.com> <BL2PR07MB23060109CAF0760E41A8BB288DF40@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:34352 "EHLO
        mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752597AbcISI55 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 04:57:57 -0400
Received: by mail-oi0-f54.google.com with SMTP id a62so54192961oib.1
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 01:57:56 -0700 (PDT)
In-Reply-To: <BL2PR07MB23060109CAF0760E41A8BB288DF40@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 19, 2016 at 1:33 AM, Mintz, Yuval <Yuval.Mintz@cavium.com> wrote:
>> The existing code is inconsistent in reporting and accepting the combined
>> channel count.  bnxt_get_channels() reports maximum combined as the
>> maximum rx count.  bnxt_set_channels() accepts combined count that cannot be
>> bigger than max rx or max tx.
>>
>> For example, if max rx = 2 and max tx = 1, we report max supported combined to
>> be 2.  But if the user tries to set combined to 2, it will fail because 2 is bigger
>> than max tx which is 1.
>>
>> Fix the code to be consistent.  Max allowed combined = max(max_rx, max_tx).
>> We will accept a combined channel count <= max(max_rx, max_tx).
>
> Don't you mean the 'max allowed combined = min(max_rx, max_tx)'.
> How does using 'max' change the faulty scenario you've described?

I'm fixing the inconsistency described in the first 2 paragraphs.  The
driver logic allows a combined ring to be rx or tx only.  In the above
example, we allow combined to be set to 2.  The 2nd combined ring
supports rx only.
