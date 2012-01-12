From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: brcm80211 breakage..
Date: Thu, 12 Jan 2012 11:44:22 -0600
Message-ID: <4F0F1BF6.2050903@lwfinger.net>
References: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com> <4F0D6806.4080201@broadcom.com> <CA+55aFxzFKkUPSCU6Wr_FBPd6NFPeTctGR0kpqYJJ8fcw+ck7w@mail.gmail.com> <CA+55aFw7TdNzNi86cwF4o6xSWnbKuPS5CuhdbChzoboNw_1-Tw@mail.gmail.com> <4F0DC030.6090500@lwfinger.net> <CA+55aFyAX_OdE7yNp1vM1AmywrYZ9Pvr0EX47jNQciZKOQUQHg@mail.gmail.com> <4F0E3B7E.8040005@lwfinger.net> <CA+55aFyR9C8GjhKb8orr1kgd_G23=-mcmT-uz9zJd6wk7rYDPA@mail.gmail.com> <4F0E5E57.9060204@lwfinger.net> <4F0EDC75.3040003@broadcom.com> <4F0F15E6.30301@lwfinger.net> <CA+55aFzeCjEn4MmLmpxvUnCFPUYjY9mG+=MyVEJtdC0enR_qEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arend van Spriel <arend@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	=?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:62072 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751776Ab2ALRo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 12:44:26 -0500
Received: by vbmv11 with SMTP id v11so522061vbm.19
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 09:44:25 -0800 (PST)
In-Reply-To: <CA+55aFzeCjEn4MmLmpxvUnCFPUYjY9mG+=MyVEJtdC0enR_qEQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2012 11:31 AM, Linus Torvalds wrote:
> On Thu, Jan 12, 2012 at 9:18 AM, Larry Finger<Larry.Finger@lwfinger.net>  wrote:
>>
>> For completeness, sromctrl is 0x12, thus bit 1 (SRC_PRESENT) is not set, and
>> my device has an OTP, not an SPROM.
>
> So this is again something that apple is *famous* for.
>
> They try to control their hardware very tightly, and OS X will (for
> example) not use non-apple wireless cards as "Airport" cards, and will
> do things like dropping features ("Oh, you tried to save money by
> buying a generic wireless minipci card instead of the apple branded
> one? Well, that's fine, but now I'll make your network flaky and will
> refuse to support 802.11n just to make a point.").
>
> Never mind that the hardware is the same - they'll literally look at
> the PCI subvendor ID and things like that, and if it doesn't say
> "Apple", they will simply not enable all the features, or won't even
> connect to it.
>
> They've done this forever. Others do it too (I think both HP and IBM
> have done the exact same thing with minipci wireless cards - back when
> WiFi used to be a "premium" thing in a laptop, and vendors charged
> quite a bit extra for it, gah!). But Apple does it for a *lot* of
> things, presumably because they want to make it extra hard for clone
> makers (or just tinkerers that would try to run OS X on a regular PC
> that just happened to have the exact same hardware as a Macbook).
>
> Seriously. I really like my Macbook Air hardware, but the moment some
> non-apple supplier makes anything comparable, I'll drop it like the
> crap it is. Exactly because Apple uses software to make it harder to
> use. Installing Linux on that thing is "interesting" - Linux works
> perfectly fine on it, but with all the special Apple firmware crap,
> you have to jump through hoops.
>
>> I do not see anything wrong with commit 888153b3db3f, but I realize that my
>> card really does not test any of those changes.
>
> I suspect the big change is the version check and the size of the
> sprom image. Apple probably has an older version. I assume that the
> subvendor ID etc comes from the srom?

HP is not at all subtle. Their BIOS checks the hardware in the internal PCIe 
slot. If it is wifi and not on their whitelist, the computer will not boot. For 
my testing, Realtek sent me an extender that plugs into an Express Card slot. 
When this machine dies, I'm not sure what I'll do as I have not found a modern 
laptop with such a slot.

I too would like to blame Apple, but there is one factoid that I just noticed 
and I'm still exploring. When I run bcma/b43, the software says I have a Rev 8 
SPROM at offset 0x830, but bcma/brcmsmac says my card has no SPROM and it uses 
the OTP branch! Why, and what does it mean? Any thoughts from the Broadcom guys?

Larry
