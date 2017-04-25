From: Jan Kiszka <jan.kiszka@siemens.com>
Subject: Re: [PATCH] stmmac: Add support for SIMATIC IOT2000 platform
Date: Tue, 25 Apr 2017 07:44:53 +0200
Message-ID: <feb4856b-fb66-3861-2121-d2834fb01899@siemens.com>
References: <8c536123-6189-e0b6-1977-dc7a521718dd@siemens.com>
 <CAHp75VcdpOXa+aQ6-iKamTAbX9KGZOWpukygSUS7Ef_E3UNvuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Sascha Weisenberger <sascha.weisenberger@siemens.com>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHp75VcdpOXa+aQ6-iKamTAbX9KGZOWpukygSUS7Ef_E3UNvuw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-04-24 23:27, Andy Shevchenko wrote:
> On Mon, Apr 24, 2017 at 10:27 PM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
>> The IOT2000 is industrial controller platform, derived from the Intel
>> Galileo Gen2 board. The variant IOT2020 comes with one LAN port, the
>> IOT2040 has two of them. They can be told apart based on the board asset
>> tag in the DMI table.
>>
>> Based on patch by Sascha Weisenberger.
>>
> 
>> Signed-off-by: Jan Kiszka <jan.kiszka@siemens.com>
>> Signed-off-by: Sascha Weisenberger <sascha.weisenberger@siemens.com>
> 
> Shoudn't be ordered other way around?

Nope. My changes invalidated Sascha's signed-off on the original patch,
but he signed off again on the final version.

> 
>> +       const char *asset_tag;
> 
> I guess this is redundant. See below.
> 
>> +       {
>> +               .name = "SIMATIC IOT2000",
>> +               .asset_tag = "6ES7647-0AA00-0YA2",
>> +               .func = 6,
>> +               .phy_addr = 1,
>> +       },
> 
> The below has same definition disregard on asset_tag.
> 

There is a small difference in the asset tag, just not at the last digit
where one may expect it, look:

...-0YA2 -> IOT2020
...-1YA2 -> IOT2040

>> +       {
>> +               .name = "SIMATIC IOT2000",
>> +               .asset_tag = "6ES7647-0AA00-1YA2",
>> +               .func = 6,
>> +               .phy_addr = 1,
>> +       },
>> +       {
>> +               .name = "SIMATIC IOT2000",
>> +               .asset_tag = "6ES7647-0AA00-1YA2",
>> +               .func = 7,
>> +               .phy_addr = 1,
>> +       },
> 
> How this supposed to work if phy_addr is the same?
> 

That address space is MAC-local, and we have two different MACs here.

Jan

-- 
Siemens AG, Corporate Technology, CT RDA ITP SES-DE
Corporate Competence Center Embedded Linux
