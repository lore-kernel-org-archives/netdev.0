From: Ohad Ben-Cohen <ohad@wizery.com>
Subject: Re: linux-next: build failure after merge of the final tree (net tree related)
Date: Mon, 27 Sep 2010 21:06:09 +0200
Message-ID: <AANLkTim9nHmhNLmECnYk-OHYmyk96tz65kd=ybz24M3Y@mail.gmail.com>
References: <20100927154408.55a28127.sfr@canb.auug.org.au> <AANLkTinHk82jM7Ztwb1aB1xb-hSLeg5Hb07mhYCaeszi@mail.gmail.com>
 <20100927180412.GD11086@tuxdriver.com> <20100927.111818.149846920.davem@davemloft.net>
 <20100927182546.GE11086@tuxdriver.com> <AANLkTi=YHhRWFix1QDuEnRW7r_UaNtp6KSL9uLdUzdqM@mail.gmail.com>
 <20100927184445.GF11086@tuxdriver.com> <AANLkTi=2KqQb+gvuigxb+-tSzawx7=q3HtnkkE6t_4XF@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=2KqQb+gvuigxb+-tSzawx7=q3HtnkkE6t_4XF@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 27, 2010 at 9:01 PM, Ohad Ben-Cohen <ohad@wizery.com> wrote=
:
> On Mon, Sep 27, 2010 at 8:44 PM, John W. Linville
> <linville@tuxdriver.com> wrote:
>> On Mon, Sep 27, 2010 at 08:38:50PM +0200, Ohad Ben-Cohen wrote:
>>> On Mon, Sep 27, 2010 at 8:25 PM, John W. Linville
>>> <linville@tuxdriver.com> wrote:
>>> >> BTW, if this fuglet going to work if the driver is built modular=
?
>>> >>
>>> >> The idea of this things seems to be to allow arch platform code =
to call
>>> >> into it to set things. =A0Such calls from arch platform code are=
 going
>>> >> to be "obj-y"
>>> >>
>>> >> So if this is built into the modular driver, I can't see how it
>>> >> can work.
>>> >
>>> > Dave is right -- these Kconfig dependencies (or lack thereof) see=
m
>>> > to be wrong.
>>>
>>> This is why I had to put it in drivers/net/wireless/Makefile (in bo=
th
>>> the original patch and in the fix I sent earlier) and not in
>>> drivers/net/wireless/wl12xx/Makefile (as it was in the fix that Dav=
e
>>> was referring to).
>>>
>>> This way it works with a modular driver.
>>
>> That doesn't seem very helpful if someone selects
>>
>> CONFIG_MACH_OMAP_ZOOM2=3Dy
>> CONFIG_WL12XX_PLATFORM_DATA=3Dn


That's a good point (it's a separate issue); we need to have a select t=
here.

I'll send a patch.

>>
>
> CONFIG_WL12XX_PLATFORM_DATA is selected automatically if the relevant
> driver is selected (this is independent of the underlying arch/board)=
:
>
> config WL12XX_PLATFORM_DATA
> =A0 =A0 =A0 =A0bool
> =A0 =A0 =A0 =A0depends on WL1271_SDIO !=3D n
> =A0 =A0 =A0 =A0default y
>
> All we have to make sure is that it will be compiled built-in. If we
> use drivers/net/wireless/wl12xx/Makefile, and we build a modular
> wl1271_sdio, it won't (despite it being selected as y).
>
> That's why I put it in drivers/net/wireless/Makefile.
>
> In the original patch I put the code itself in
> drivers/net/wireless/wl12xx to make it look nicer, but as Stephen
> reported that seem to break building with a separate object folder...
>
> So the fix I sent just moves that builtin code to
> drivers/net/wireless. This maintains the builtin property even if the
> driver is modular, and fixes the issue reported by Stephen.
>
> Please tell me if you have any thoughts/suggestions.
>
> Thanks,
> Ohad.
>
>> or am I missing something?
>>
>> John
>> --
>> John W. Linville =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Someday the world wi=
ll need a hero, and you
>> linville@tuxdriver.com =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0might be a=
ll we have. =A0Be ready.
>>
>
