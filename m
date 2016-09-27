From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH] brcmfmac: implement more accurate skb tracking
Date: Tue, 27 Sep 2016 11:24:32 +0200
Message-ID: <0a070079-e3af-ab5c-0485-744bec8b3d86@broadcom.com>
References: <20160926102348.8695-1-zajec5@gmail.com>
 <09084e8b-829d-9a13-ae16-a493438216ac@broadcom.com>
 <CACna6rwnLb3sEPmdx6uhYMstVn04WbP2xzznsjnwgguEXn04=w@mail.gmail.com>
 <CACna6ryNLOqrwsa9KFueUdqStxjP7KoRyvsn6eynLc6Y7Ug_sw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Kalle Valo <kvalo@codeaurora.org>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        Franky Lin <frankyl@broadcom.com>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
        <brcm80211-dev-list.pdl@broadcom.com>,
        Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:38095 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932849AbcI0JYu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 05:24:50 -0400
Received: by mail-wm0-f43.google.com with SMTP id l132so1954823wmf.1
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 02:24:49 -0700 (PDT)
In-Reply-To: <CACna6ryNLOqrwsa9KFueUdqStxjP7KoRyvsn6eynLc6Y7Ug_sw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26-9-2016 14:38, Rafał Miłecki wrote:
> On 26 September 2016 at 14:13, Rafał Miłecki <zajec5@gmail.com> wrote:
>> On 26 September 2016 at 13:46, Arend Van Spriel
>> <arend.vanspriel@broadcom.com> wrote:
>>> On 26-9-2016 12:23, Rafał Miłecki wrote:
>>>> From: Rafał Miłecki <rafal@milecki.pl>
>>>>
>>>> We need to track 802.1x packets to know if there are any pending ones
>>>> for transmission. This is required for performing key update in the
>>>> firmware.
>>>
>>> The problem we are trying to solve is a pretty old one. The problem is
>>> that wpa_supplicant uses two separate code paths: EAPOL messaging
>>> through data path and key configuration though nl80211.
>>
>> Can I find it described/reported somewhere?
>>
>>
>>>> Unfortunately our old tracking code wasn't very accurate. It was
>>>> treating skb as pending as soon as it was passed by the netif. Actual
>>>> handling packet to the firmware was happening later as brcmfmac
>>>> internally queues them and uses its own worker(s).
>>>
>>> That does not seem right. As soon as we get a 1x packet we need to wait
>>> with key configuration regardless whether it is still in the driver or
>>> handed over to firmware already.
>>
>> OK, thanks.
> 
> Actually, it's not OK. I was trying to report/describe/discuss this
> problem for over a week. I couldn't get much of answer from you.
> 
> I had to come with a patch I worked on for quite some time. Only then
> you decided to react and reply with a reason for a nack. I see this
> patch may be wrong (but it's still hard to know what's going wrong
> without a proper hostapd bug report). I'd expect you to somehow work &
> communicate with open source community.

We do or at least make an honest attempt, but there is more on our plate
so responses may be delayed. It also does not help when you get anal and
preachy when we do respond. Also not OK. In this case the delay is
caused because I had to pick up the thread(s) as Hante is on vacation
(he needed a break :-p ). However, you started sending patches so I
decided to look at and respond to those. Sorry if you felt like we left
you hanging to dry.

Regards,
Arend
