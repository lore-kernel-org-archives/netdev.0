From: Moritz Fischer <mdf@kernel.org>
Subject: Re: [PATCH] net: ethernet: cadence: Add fixed-link functionality
Date: Wed, 15 Feb 2017 14:30:25 -0800
Message-ID: <CAAtXAHdSExjVc-Dhy=5vAkEgk97gTSderDtSRY7VXaSPOdX_vg@mail.gmail.com>
References: <1487191445-5353-1-git-send-email-mdf@kernel.org> <20170215221249.GB6096@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netdev@vger.kernel.org, Nicolas Ferre <nicolas.ferre@microchip.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:54034 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751210AbdBOWaf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 17:30:35 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
        by mail.kernel.org (Postfix) with ESMTP id BA94D20220
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 22:30:28 +0000 (UTC)
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id A2E2820211
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 22:30:26 +0000 (UTC)
Received: by mail-qk0-f171.google.com with SMTP id u25so283239qki.2
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 14:30:26 -0800 (PST)
In-Reply-To: <20170215221249.GB6096@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew,

On Wed, Feb 15, 2017 at 2:12 PM, Andrew Lunn <andrew@lunn.ch> wrote:
>> @@ -3342,8 +3371,18 @@ static int macb_probe(struct platform_device *pdev)
>>               macb_get_hwaddr(bp);
>>
>>       /* Power up the PHY if there is a GPIO reset */
>> -     phy_node =  of_get_next_available_child(np, NULL);
>> -     if (phy_node) {
>> +     phy_node = of_parse_phandle(np, "phy-handle", 0);
>> +     if (!phy_node && of_phy_is_fixed_link(np)) {
>> +             err = of_phy_register_fixed_link(np);
>
> Hi Moritz
>
> I don't see any calls to of_phy_deregister_fixed_link(), either in the
> error path, or the remove code.

Whoops, yeah I rebased it from like a year ago. Must've not survived my
merge conflict resolution.

I'll rework it.

Thanks,

Moritz
