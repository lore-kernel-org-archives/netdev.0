From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH 4.9] brcmfmac: use correct skb freeing helper when
 deleting flowring
Date: Tue, 27 Sep 2016 13:33:17 +0200
Message-ID: <c0e00728-e869-d39f-515f-2b540f1e47cc@broadcom.com>
References: <20160927091428.19223-1-zajec5@gmail.com>
 <86fd0b60-0f73-484b-1788-3ec740672232@broadcom.com>
 <87inthy441.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        Franky Lin <frankyl@broadcom.com>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87inthy441.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27-9-2016 13:27, Kalle Valo wrote:
> Arend Van Spriel <arend.vanspriel@broadcom.com> writes:
> 
>> On 27-9-2016 11:14, Rafał Miłecki wrote:
>>> From: Rafał Miłecki <rafal@milecki.pl>
>>>
>>> Flowrings contain skbs waiting for transmission that were passed to us
>>> by netif. It means we checked every one of them looking for 802.1x
>>> Ethernet type. When deleting flowring we have to use freeing function
>>> that will check for 802.1x type as well.
>>>
>>> Freeing skbs without a proper check was leading to counter not being
>>> properly decreased. This was triggering a WARNING every time
>>> brcmf_netdev_wait_pend8021x was called.
>>
>> Acked-by: Arend van Spriel <arend@broadcom.com>
>>> Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
>>> ---
>>> Kalle: this isn't important enough for 4.8 as it's too late for that.
>>>
>>> I'd like to get it for 4.9 however, as this fixes bug that could lead
>>> to WARNING on every add_key/del_key call. We was struggling with these
>>> WARNINGs for some time and this fixes one of two problems causing them.
> 
> Ok, I'll queue this for 4.9.
> 
>> Please mark it for stable as well.
> 
> I can add that. Any ideas how old releases stable releases should this
> go to?

Not sure if the vendor directory move causes issues as stable can not
fallback to three-way merge. I assumed it would so my last stable tag
was only for 4.7 and I took care of older kernels at later time with
backported patch. I can do that for this one as well.

Regards,
Arend
