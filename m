From: kiki good <jqiaoulk@gmail.com>
Subject: Re: [PATCH v2 net-next] net: systemport: Support 64bit statistics
Date: Thu, 20 Jul 2017 11:13:57 +0100
Message-ID: <CACM3AayYV-x1b8FpPCMdsSqkFEfJskkP0k9Dfsc5QjqTUbhKuA@mail.gmail.com>
References: <1500423520-4169-1-git-send-email-jqiaoulk@gmail.com> <20170719.222516.1490852598794069450.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:35710 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933320AbdGTKN6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 06:13:58 -0400
Received: by mail-io0-f172.google.com with SMTP id m88so1321753iod.2
        for <netdev@vger.kernel.org>; Thu, 20 Jul 2017 03:13:58 -0700 (PDT)
In-Reply-To: <20170719.222516.1490852598794069450.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David:

I am sorry for missing the commit log message;Since I did conversation
with Florian Fainelli about this patch in another email thread
"[PATCH] net: systemport: Support 64bit statistics", i incorrectly
thought it was unnecessary to add the commit log again when submitting
the revised patch.

The reason for keeping both  .ndo_get_stats and 64-bit
.ndo_get_stats64 comes from Florian, suggesting that because there is
no harm in keeping bcm_sysport_get_stats and we can always deprecate
it later, it is just to minimize the amount of changes to review.

Why do we need this change ?
When using Broadcom Systemport device in 32bit Platform, ifconfig can
only report up to 4G tx,rx status, which will be wrapped to 0 when the
number of incoming or outgoing packets exceeds 4G, only taking
around 2 hours in busy network environment (such as streaming).
Therefore, it makes hard for network diagnostic tool to get reliable
statistical result, so the patch is used to add 64bit support for
Broadcom Systemport device in 32bit Platform.

Thanks
Jmqiao

On Thu, Jul 20, 2017 at 6:25 AM, David Miller <davem@davemloft.net> wrote:
> From: "Jianming.qiao" <jqiaoulk@gmail.com>
> Date: Wed, 19 Jul 2017 01:18:40 +0100
>
>> Signed-off-by: Jianming.qiao <kiki-good@hotmail.com>
>
> Supporting both deprecated .ndo_get_stats and 64-bit .ndo_get_stats64
> at the same time makes no sense.
>
> .ndo_get_stats will never be called if .ndo_get_stats64 is non-NULL
>
> The lack of a commit log message, explaining in detail, why you are
> doing this and why you are doing it this way, concerns me as well.
>
> This submission so far has been a bit of a mess.  You don't
> communicate enough, your commit message is empty, and therefore we
> have no idea why you are doing things, and in particular the reasons
> for your decisions.
>
> I'm not applying this, sorry.
