From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH] stmmac: Add support for SIMATIC IOT2000 platform
Date: Wed, 26 Apr 2017 21:29:31 +0300
Message-ID: <CAHp75VemWBZE2Nj3p9TvY51-5Vw-knXDLokbqNxvEOAMuY_66A@mail.gmail.com>
References: <8c536123-6189-e0b6-1977-dc7a521718dd@siemens.com>
 <CAHp75VcdpOXa+aQ6-iKamTAbX9KGZOWpukygSUS7Ef_E3UNvuw@mail.gmail.com>
 <feb4856b-fb66-3861-2121-d2834fb01899@siemens.com> <CAHp75VcTzBL4D6nobfDAPQOfEEp-RzBp4BANKYDSaaEtGCyj9A@mail.gmail.com>
 <d7216317-e749-1347-972f-28dfe57038c0@siemens.com> <CAHp75VfqC166E57nZRsx97EQCCGnqYTk+4nRX3H2-rsnCohPfQ@mail.gmail.com>
 <42fd4a72-526c-cbd9-52db-9d8b495035ee@siemens.com> <3eae5626-1ef2-03ae-635e-27faed085c68@siemens.com>
 <CAHp75Vd=TkJXnDYqctKCzRGvMX_Zt0i5eH8GcBz44e-T93aJ0A@mail.gmail.com> <5705c598-7721-fca5-d4e3-8a1a88907173@siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Sascha Weisenberger <sascha.weisenberger@siemens.com>
To: Jan Kiszka <jan.kiszka@siemens.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5705c598-7721-fca5-d4e3-8a1a88907173@siemens.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 25, 2017 at 3:15 PM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
> On 2017-04-25 13:42, Andy Shevchenko wrote:
>> On Tue, Apr 25, 2017 at 1:09 PM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
>>> On 2017-04-25 12:07, Jan Kiszka wrote:
>>>> On 2017-04-25 11:46, Andy Shevchenko wrote:
>>>>> On Tue, Apr 25, 2017 at 12:00 PM, Jan Kiszka <jan.kiszka@siemens.com> wrote:

>>>>>        {
>>>>>                .name = "SIMATIC IOT2000",
>>>>>                .func = 6,
>>>>>                .phy_addr = 1,
>>>>>        },
>>>>>        {
>>>>>                .name = "SIMATIC IOT2000",
>>>>>                .func = 7,
>>>>>                .phy_addr = 1,
>>>>>        },
>>>>>
>>>>> That's all what you need.
>>>>
>>>> Nope. Again: the asset tag is the way to tell both apart AND to ensure
>>>> that we do not match on future devices.
>>
>>> To be more verbose: your version (which is our old one) would even
>>> enable the second, not connected port on the IOT2020. Incorrectly.
>>
>> So, name has 2000 for 2020 device? It's clear bug in DMI table you have. :-(
>>

>> What else do you have in DMI which can be used to distinguish those devices?

So, except asset tag is there anything else to use?

Whatever you choose would be nice to split this long conditional:

if (!strcmp(dmi->name, name) && dmi->func == func) {
    /* ASSET_TAG is optional */
    if (dmi->asset_tag && strcmp(dmi->asset_tag, asset_tag))
        continue;
    return dmi->phy_addr;
}

> Andy, there are devices out there in the field, if we as engineers like
> it or not, that are all called "IOT2000" although they are sightly
> different inside. This patch accounts for that. And it does that even
> without adding "platform_data" hacks like in other patches of mine. ;)

Yes, which is good.

-- 
With Best Regards,
Andy Shevchenko
