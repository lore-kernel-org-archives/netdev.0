From: Siva Mannem <siva.mannem.lnx@gmail.com>
Subject: Re: [PATCH net-next] bridge: Let bridge not age 'externally' learnt
 FDB entries, they are removed when 'external' entity notifies the aging
Date: Fri, 6 Feb 2015 08:57:22 +0530
Message-ID: <CA+CtxLTewFxJNH0OTCqcGb31Ov=TZMwDtz=H11My1NKY=tb9Jg@mail.gmail.com>
References: <CA+CtxLSziWmx94_V9S-uW9=6VYg4WXsU4CERx-uovvrFOtO1dA@mail.gmail.com>
	<54D246A7.2020502@cumulusnetworks.com>
	<CAE4R7bCASKHmZD+tiu=ZWM9dzvTrSLsaXxgtOYLpsmOR87kcTQ@mail.gmail.com>
	<20150204.235308.71797582017426266.davem@davemloft.net>
	<CA+CtxLRaJ+p=y1LCgap48vqH3b4VjxKQO55Yy5cyazng4WtxPw@mail.gmail.com>
	<CAN+pFwJQQMFmmm1f7tSPCmaSr2GE_L8Pua+Rz7tvK9CFnr63Tg@mail.gmail.com>
	<CAE4R7bBKXHfbOz-BT1jW2=+hTi=6hZZHRUVpYUvOj1yF+XEtUw@mail.gmail.com>
	<CAE4R7bDRHwUnt7jzPw_CzwsZfou2B2mRgZ_9t4AfRWe2Z_EtYg@mail.gmail.com>
	<CAN+pFwKAWX+En6zK3Q94q9ejdpqz6WBvnkH=Rp3HBEAeOyNbNw@mail.gmail.com>
	<CAE4R7bDypUjrSAned55XRpcp+iEHNkF7H_8JJy63jt+5Hd3Pzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: B Viswanath <marichika4@gmail.com>,
	David Miller <davem@davemloft.net>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:40029 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752469AbbBFD1Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 22:27:24 -0500
Received: by mail-wg0-f46.google.com with SMTP id l2so11106550wgh.5
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 19:27:23 -0800 (PST)
In-Reply-To: <CAE4R7bDypUjrSAned55XRpcp+iEHNkF7H_8JJy63jt+5Hd3Pzg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 6, 2015 at 7:15 AM, Scott Feldman <sfeldma@gmail.com> wrote:
> On Thu, Feb 5, 2015 at 10:31 AM, B Viswanath <marichika4@gmail.com> wrote:
>> On 5 February 2015 at 23:25, Scott Feldman <sfeldma@gmail.com> wrote:
>> <snip>
>>>
>>> CONs
>>>
>>> 1) Scale-ability.  The bridge driver can't keep up with ageing many
>>> (10^5, for example) entries.
>>> 2) Scale-ability.  Keeping the entries periodically refreshed requires
>>> a refresh sync from
>>> the device to the bridge driver, and the bridge driver/kernel can't keep up.
>>> 3) With the bridge driver, the ageing settings are per-bridge, not per-port.
>>>
>>> Did I miss any points?
>>
>> There is one more
>>
>> 4. On links with wirespeed traffic, software ageing FDB entries
>> independently without having the knowledge of the traffic means that
>> CPU will ageout entries it should not. I don't know if this breaks
>> some RFC, but it can certainly cause big packet loss.
>
> SW would only age out expired entries.  An entry not refreshed by HW
> will expire.  But HW will refresh (to SW) active entries based on
> traffic seen.  So I'm not seeing how SW will age out entries
> prematurely.  I'm missing something.

Hardware does not refresh(to SW) active entries based on the traffic
seen, at least on the switches that I worked on. Even if it were to
refresh, if the traffic is flowing at line rate(say x packets per
sec), the refresh rate to SW is equal to x, which is very huge for cpu
to handle.

There are only two notifications to SW.

1)learn notification(when packet arrives that has smac which is not in
hardware's FDB)
2)When the hardware ages the entry, it sends a age notification.

>
> Is there a race perhaps?  Maybe that's your point.  I think I see the
> race.  SW has decided entry is expired and sends signal to remove
> entry, while in the meantime HW got a hit on entry and wants to
> refresh it.  So this would cause a service disruption if the entry was
> removed and then re-added.  But this is a boundary condition on the
> hairy edge of the ageing timeout window.  Does it matter in practice?
>
> I really want to understand your case 4, but I'm not getting
> something.  Is there another way to explain it, by example perhaps?
>
>> Such a packet loss is considered bad, and is a primary reason why
>> hardware supports ageing. Otherwise there is no reason hw needs to
>> support it. Based on experience, I can say that it is a necessity, now
>> even more with 10G and 40G links.



-- 
Regards,
Siva Mannem.
