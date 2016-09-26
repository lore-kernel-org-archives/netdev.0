From: Arend Van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] brcmfmac: implement more accurate skb tracking
Date: Mon, 26 Sep 2016 14:20:59 +0200
Message-ID: <dd7ae3d7-fa6d-c27c-a19f-712d01c423d7@broadcom.com>
References: <20160926102348.8695-1-zajec5@gmail.com>
 <09084e8b-829d-9a13-ae16-a493438216ac@broadcom.com>
 <CACna6rwnLb3sEPmdx6uhYMstVn04WbP2xzznsjnwgguEXn04=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
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
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACna6rwnLb3sEPmdx6uhYMstVn04WbP2xzznsjnwgguEXn04=w@mail.gmail.com>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 26-9-2016 14:13, Rafał Miłecki wrote:
> On 26 September 2016 at 13:46, Arend Van Spriel
> <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> wrote:
>> On 26-9-2016 12:23, Rafał Miłecki wrote:
>>> From: Rafał Miłecki <rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org>
>>>
>>> We need to track 802.1x packets to know if there are any pending ones
>>> for transmission. This is required for performing key update in the
>>> firmware.
>>
>> The problem we are trying to solve is a pretty old one. The problem is
>> that wpa_supplicant uses two separate code paths: EAPOL messaging
>> through data path and key configuration though nl80211.
> 
> Can I find it described/reported somewhere?

Not sure. It is something that I recall from working at Intersil so back
in the prism days.

Regards,
Arend

>>> Unfortunately our old tracking code wasn't very accurate. It was
>>> treating skb as pending as soon as it was passed by the netif. Actual
>>> handling packet to the firmware was happening later as brcmfmac
>>> internally queues them and uses its own worker(s).
>>
>> That does not seem right. As soon as we get a 1x packet we need to wait
>> with key configuration regardless whether it is still in the driver or
>> handed over to firmware already.
> 
> OK, thanks.
> 
