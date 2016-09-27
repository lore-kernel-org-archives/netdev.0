From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4.9] brcmfmac: use correct skb freeing helper when
 deleting flowring
Date: Tue, 27 Sep 2016 14:07:46 +0200
Message-ID: <CACna6rzjT+cFriHfSG9g6CvBmrV__ph7WysZ8hCYAw+Nkmmiaw@mail.gmail.com>
References: <20160927091428.19223-1-zajec5@gmail.com> <86fd0b60-0f73-484b-1788-3ec740672232@broadcom.com>
 <87inthy441.fsf@kamboji.qca.qualcomm.com> <CACna6rwUR_GidhEFNTN+8mGQRpBdUzeM1-0NY65k6-McX7xGVg@mail.gmail.com>
 <CACna6rxDb_KMwGTFKu1Mf9azmk_PLO0aLR3foRtkqyywa1DNVQ@mail.gmail.com> <41e5f45f-1956-8c9d-49d4-cd73e2c5c7c0@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Franky Lin <franky.lin-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Hante Meuleman <hante.meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Pieter-Paul Giesberts <pieter-paul.giesberts-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Franky Lin <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
        <brcm80211-dev-list.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org>
To: Arend Van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <41e5f45f-1956-8c9d-49d4-cd73e2c5c7c0-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 27 September 2016 at 14:04, Arend Van Spriel
<arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> wrote:
> On 27-9-2016 13:58, Rafa=C5=82 Mi=C5=82ecki wrote:
>> On 27 September 2016 at 13:44, Rafa=C5=82 Mi=C5=82ecki <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org=
> wrote:
>>> On 27 September 2016 at 13:27, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> wrote:
>>>> Arend Van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> writes:
>>>>
>>>>> On 27-9-2016 11:14, Rafa=C5=82 Mi=C5=82ecki wrote:
>>>>>> From: Rafa=C5=82 Mi=C5=82ecki <rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org>
>>>>>>
>>>>>> Flowrings contain skbs waiting for transmission that were passed to =
us
>>>>>> by netif. It means we checked every one of them looking for 802.1x
>>>>>> Ethernet type. When deleting flowring we have to use freeing functio=
n
>>>>>> that will check for 802.1x type as well.
>>>>>>
>>>>>> Freeing skbs without a proper check was leading to counter not being
>>>>>> properly decreased. This was triggering a WARNING every time
>>>>>> brcmf_netdev_wait_pend8021x was called.
>>>>>
>>>>> Acked-by: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
>>>>>> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org>
>>>>>> ---
>>>>>> Kalle: this isn't important enough for 4.8 as it's too late for that=
.
>>>>>>
>>>>>> I'd like to get it for 4.9 however, as this fixes bug that could lea=
d
>>>>>> to WARNING on every add_key/del_key call. We was struggling with the=
se
>>>>>> WARNINGs for some time and this fixes one of two problems causing th=
em.
>>>>
>>>> Ok, I'll queue this for 4.9.
>>>>
>>>>> Please mark it for stable as well.
>>>>
>>>> I can add that. Any ideas how old releases stable releases should this
>>>> go to?
>>>
>>> I was analyzing this.
>>> 1) This patch uses brcmf_get_ifp which is available in 4.4+ only.
>>> 2) It applies cleanly to 4.5+ only due to 32f90caa7debd ("brcmfmac:
>>> Increase nr of supported flowrings.")
>>> 3) 4.4 would also require applying to the patch without broadcom/ subdi=
r
>>>
>>> That said I suggest 4.5+. Any objections?
>
> No objections. Just a tip. I tend to look at kernel.org main page to see
> the stable and long-term kernel listed. So 4.7+ and 4.5+ have same
> meaning as 4.5 and 4.6 are not stable/long-term kernels.

Some projects may work on their own stable kernels, e.g. Ubuntu, see:
https://wiki.ubuntu.com/Kernel/Dev/ExtendedStable

That's why I don't always look strictly at upstream stable releases only.

--=20
Rafa=C5=82
