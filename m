From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH 08/26] brcmsmac: make some local variables 'static const'
 to reduce stack size
Date: Tue, 7 Mar 2017 10:55:36 +0100
Message-ID: <2e8b7c30-41d5-b605-d502-6b914507e4e1@broadcom.com>
References: <20170302163834.2273519-1-arnd@arndb.de>
 <20170302163834.2273519-9-arnd@arndb.de>
 <227c8e5a-fa20-0300-1cb0-1d3ef17deb19@broadcom.com>
 <87y3wi74y8.fsf@purkki.adurom.net>
 <CAK8P3a0cemG0=6jZOQEpGN+RG2Be1LM_DE7aJVX18en_i6G7=Q@mail.gmail.com>
 <877f414e1n.fsf@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kasan-dev <kasan-dev@googlegroups.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-media@vger.kernel.org,
        linux-wireless <linux-wireless@vger.kernel.org>,
        kernel-build-reports@lists.linaro.org,
        "David S . Miller" <davem@davemloft.net>
To: Kalle Valo <kvalo@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35367 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752742AbdCGKD0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 05:03:26 -0500
Received: by mail-wm0-f44.google.com with SMTP id v186so85159326wmd.0
        for <netdev@vger.kernel.org>; Tue, 07 Mar 2017 02:03:00 -0800 (PST)
In-Reply-To: <877f414e1n.fsf@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7-3-2017 10:44, Kalle Valo wrote:
> Arnd Bergmann <arnd@arndb.de> writes:
> 
>> On Mon, Mar 6, 2017 at 5:19 PM, Kalle Valo <kvalo@codeaurora.org> wrote:
>>> Arend Van Spriel <arend.vanspriel@broadcom.com> writes:
>>>
>>>> On 2-3-2017 17:38, Arnd Bergmann wrote:
>>>>> With KASAN and a couple of other patches applied, this driver is one
>>>>> of the few remaining ones that actually use more than 2048 bytes of
>>>>> kernel stack:
>>>>>
>>>>> broadcom/brcm80211/brcmsmac/phy/phy_n.c: In function
>>>>> 'wlc_phy_workarounds_nphy_gainctrl':
>>>>> broadcom/brcm80211/brcmsmac/phy/phy_n.c:16065:1: warning: the
>>>>> frame size of 3264 bytes is larger than 2048 bytes
>>>>> [-Wframe-larger-than=]
>>>>> broadcom/brcm80211/brcmsmac/phy/phy_n.c: In function 'wlc_phy_workarounds_nphy':
>>>>> broadcom/brcm80211/brcmsmac/phy/phy_n.c:17138:1: warning: the
>>>>> frame size of 2864 bytes is larger than 2048 bytes
>>>>> [-Wframe-larger-than=]
>>>>>
>>>>> Here, I'm reducing the stack size by marking as many local variables as
>>>>> 'static const' as I can without changing the actual code.
>>>>
>>>> Acked-by: Arend van Spriel <arend.vanspriel@broadcom.com>
>>>
>>> Arnd, via which tree are you planning to submit these? I'm not sure
>>> what I should do with the wireless drivers patches from this series.
>>
>> I'm not quite sure myself yet. I'd probably want the first few patches that
>> do most of the work get merged through Andrew's linux-mm tree once
>> we have come to agreement on them. The driver specific patches like
>> the brcmsmac ones depend on the introduction of noinline_for_kasan
>> or noinline_if_stackbloat and could either go in along with the first
>> set, or as a follow-up through the normal maintainer trees.
> 
> Either way is fine for me. Just mark clearly if you want the wireless
> drivers patches to go through via my tree, otherwise I'll ignore them.

That (dreaded) phy code does not get a lot of changes so I think it does
not matter which tree is will go through in terms of risk for conflicts.
So going through linux-mm is fine for me as well.

Regards,
Arend
