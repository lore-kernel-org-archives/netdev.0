From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] brcmfmac: implement more accurate skb tracking
Date: Mon, 26 Sep 2016 14:13:35 +0200
Message-ID: <CACna6rwnLb3sEPmdx6uhYMstVn04WbP2xzznsjnwgguEXn04=w@mail.gmail.com>
References: <20160926102348.8695-1-zajec5@gmail.com> <09084e8b-829d-9a13-ae16-a493438216ac@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
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
To: Arend Van Spriel <arend.vanspriel@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <09084e8b-829d-9a13-ae16-a493438216ac@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26 September 2016 at 13:46, Arend Van Spriel
<arend.vanspriel@broadcom.com> wrote:
> On 26-9-2016 12:23, Rafa=C5=82 Mi=C5=82ecki wrote:
>> From: Rafa=C5=82 Mi=C5=82ecki <rafal@milecki.pl>
>>
>> We need to track 802.1x packets to know if there are any pending ones
>> for transmission. This is required for performing key update in the
>> firmware.
>
> The problem we are trying to solve is a pretty old one. The problem is
> that wpa_supplicant uses two separate code paths: EAPOL messaging
> through data path and key configuration though nl80211.

Can I find it described/reported somewhere?


>> Unfortunately our old tracking code wasn't very accurate. It was
>> treating skb as pending as soon as it was passed by the netif. Actual
>> handling packet to the firmware was happening later as brcmfmac
>> internally queues them and uses its own worker(s).
>
> That does not seem right. As soon as we get a 1x packet we need to wait
> with key configuration regardless whether it is still in the driver or
> handed over to firmware already.

OK, thanks.
