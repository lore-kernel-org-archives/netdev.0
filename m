From: Arend Van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] brcmfmac: implement more accurate skb tracking
Date: Fri, 30 Sep 2016 10:29:37 +0200
Message-ID: <96baa7f0-68e5-8d58-d10f-49cb7a257865@broadcom.com>
References: <20160926102348.8695-1-zajec5@gmail.com>
 <09084e8b-829d-9a13-ae16-a493438216ac@broadcom.com>
 <CACna6rwnLb3sEPmdx6uhYMstVn04WbP2xzznsjnwgguEXn04=w@mail.gmail.com>
 <CACna6ryNLOqrwsa9KFueUdqStxjP7KoRyvsn6eynLc6Y7Ug_sw@mail.gmail.com>
 <0a070079-e3af-ab5c-0485-744bec8b3d86@broadcom.com>
 <CACna6rxg5r=YWh7m1TYAhD5OrG3+KXAWMihs9mgh-EBVfKvt+g@mail.gmail.com>
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
In-Reply-To: <CACna6rxg5r=YWh7m1TYAhD5OrG3+KXAWMihs9mgh-EBVfKvt+g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 29-9-2016 23:57, Rafał Miłecki wrote:
> On 27 September 2016 at 11:24, Arend Van Spriel
> <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> wrote:
>> On 26-9-2016 14:38, Rafał Miłecki wrote:
>>> On 26 September 2016 at 14:13, Rafał Miłecki <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>>> On 26 September 2016 at 13:46, Arend Van Spriel
>>>> <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> wrote:
>>>>> On 26-9-2016 12:23, Rafał Miłecki wrote:
>>>>>> From: Rafał Miłecki <rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org>
>>>>>>
>>>>>> We need to track 802.1x packets to know if there are any pending ones
>>>>>> for transmission. This is required for performing key update in the
>>>>>> firmware.
>>>>>
>>>>> The problem we are trying to solve is a pretty old one. The problem is
>>>>> that wpa_supplicant uses two separate code paths: EAPOL messaging
>>>>> through data path and key configuration though nl80211.
>>>>
>>>> Can I find it described/reported somewhere?
>>>>
>>>>
>>>>>> Unfortunately our old tracking code wasn't very accurate. It was
>>>>>> treating skb as pending as soon as it was passed by the netif. Actual
>>>>>> handling packet to the firmware was happening later as brcmfmac
>>>>>> internally queues them and uses its own worker(s).
>>>>>
>>>>> That does not seem right. As soon as we get a 1x packet we need to wait
>>>>> with key configuration regardless whether it is still in the driver or
>>>>> handed over to firmware already.
>>>>
>>>> OK, thanks.
>>>
>>> Actually, it's not OK. I was trying to report/describe/discuss this
>>> problem for over a week. I couldn't get much of answer from you.
>>>
>>> I had to come with a patch I worked on for quite some time. Only then
>>> you decided to react and reply with a reason for a nack. I see this
>>> patch may be wrong (but it's still hard to know what's going wrong
>>> without a proper hostapd bug report). I'd expect you to somehow work &
>>> communicate with open source community.
>>
>> We do or at least make an honest attempt, but there is more on our plate
>> so responses may be delayed. It also does not help when you get anal and
>> preachy when we do respond. Also not OK. In this case the delay is
>> caused because I had to pick up the thread(s) as Hante is on vacation
>> (he needed a break :-p ). However, you started sending patches so I
>> decided to look at and respond to those. Sorry if you felt like we left
>> you hanging to dry.
> 
> I believe I get easily irritated due to my communication experience I
> got so far :(
> 
> 
> Over a year ago I reported brcmfmac can't recover from failed
> register_netdev(ice). This bug remains unfixed.
> 
> In 2014 I reported problem with 80 MHz support. I didn't have hardware
> to fix & test it on my own (you weren't able/allowed to send me one of
> your PCIe cards). In remained broken until I fixed it year later.
> 
> You missed my crash bug report about caused by missing eth_type_trans
> and came with patch on your own a month later.
> 
> Earlier this year I reported you problem with BCM4366 and multiple
> interfaces. I didn't get much help. 3 months later I came with patch
> to workaround the problem but you said there's a better way to do
> this. It took me 2 weeks to figure out a new wlioctl API for that
> while all I needed was a simple hint on "interface_remove".
> 
> Right now I'm waiting to get any answer from you about 4366c0
> firmware. It's still less than 2 weeks since I asked for it, but a
> simple ETA would be nice. I'm actually not sure if I should report
> more problems to you to don't distract you from pending things.

This is a difficult question. All upstream firmware releases for router
chips are put on hold until further notice. Some decisions have been
made, but I have not seen a detailed plan to give an ETA.

> Problems with brcmf_netdev_wait_pend8021x were reported multiples
> times for last few months. When I finally got time for that it took me
> a week to debug them.

For the pend8021x you were sending a number of messages showing debug
progress so not sure whether you wanted our feedback on that. If so a
ping might have done it.

> As you can see, it takes me months to get help on some things. And in
> few cases I never got much help at all. Yes, I was hoping to have you
> more involved into brcmfmac development and problems solving. I guess
> things didn't meet my expectations and I got grumpy & preachy.

Thanks for listing all our failures. Somehow we are very good at getting
each other grumpy. When we provide a patch and you break it up and
submit that to Kalle, we get grumpy and it all piles up to the point
where we have this kind of conversation. As long as it helps to get
things of our chest I can live with that. Hope you can too. We strive to
give support to the community, but the priority is low as it is not
full-time activity.

Regards,
Arend
