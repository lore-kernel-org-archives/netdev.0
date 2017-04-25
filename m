From: Jan Kiszka <jan.kiszka@siemens.com>
Subject: Re: [PATCH] stmmac: Add support for SIMATIC IOT2000 platform
Date: Tue, 25 Apr 2017 12:09:09 +0200
Message-ID: <3eae5626-1ef2-03ae-635e-27faed085c68@siemens.com>
References: <8c536123-6189-e0b6-1977-dc7a521718dd@siemens.com>
 <CAHp75VcdpOXa+aQ6-iKamTAbX9KGZOWpukygSUS7Ef_E3UNvuw@mail.gmail.com>
 <feb4856b-fb66-3861-2121-d2834fb01899@siemens.com>
 <CAHp75VcTzBL4D6nobfDAPQOfEEp-RzBp4BANKYDSaaEtGCyj9A@mail.gmail.com>
 <d7216317-e749-1347-972f-28dfe57038c0@siemens.com>
 <CAHp75VfqC166E57nZRsx97EQCCGnqYTk+4nRX3H2-rsnCohPfQ@mail.gmail.com>
 <42fd4a72-526c-cbd9-52db-9d8b495035ee@siemens.com>
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
In-Reply-To: <42fd4a72-526c-cbd9-52db-9d8b495035ee@siemens.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-04-25 12:07, Jan Kiszka wrote:
> On 2017-04-25 11:46, Andy Shevchenko wrote:
>> On Tue, Apr 25, 2017 at 12:00 PM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
>>> On 2017-04-25 09:30, Andy Shevchenko wrote:
>>>> On Tue, Apr 25, 2017 at 8:44 AM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
>>>>> On 2017-04-24 23:27, Andy Shevchenko wrote:
>>>>>> On Mon, Apr 24, 2017 at 10:27 PM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
>>>>>>> The IOT2000 is industrial controller platform, derived from the Intel
>>>>>>> Galileo Gen2 board. The variant IOT2020 comes with one LAN port, the
>>>>>>> IOT2040 has two of them. They can be told apart based on the board asset
>>>>>>> tag in the DMI table.
>>>>
>>>>>>> +       const char *asset_tag;
>>>>>>
>>>>>> I guess this is redundant. See below.
>>>>>>
>>>>>>> +       {
>>>>>>> +               .name = "SIMATIC IOT2000",
>>>>>>> +               .asset_tag = "6ES7647-0AA00-0YA2",
>>>>>>> +               .func = 6,
>>>>>>> +               .phy_addr = 1,
>>>>>>> +       },
>>>>>>
>>>>>> The below has same definition disregard on asset_tag.
>>>>>>
>>>>>
>>>>> There is a small difference in the asset tag, just not at the last digit
>>>>> where one may expect it, look:
>>>>>
>>>>> ...-0YA2 -> IOT2020
>>>>> ...-1YA2 -> IOT2040
>>>>
>>>> Yes. And how does it change my statement? You may use one record here
>>>> instead of two.
>>>
>>> How? Please be more verbose in your comments.
>>
>>        {
>>                .name = "SIMATIC IOT2000",
>>                .func = 6,
>>                .phy_addr = 1,
>>        },
>>        {
>>                .name = "SIMATIC IOT2000",
>>                .func = 7,
>>                .phy_addr = 1,
>>        },
>>
>> That's all what you need.
> 
> Nope. Again: the asset tag is the way to tell both apart AND to ensure
> that we do not match on future devices.

To be more verbose: your version (which is our old one) would even
enable the second, not connected port on the IOT2020. Incorrectly. Plus
the risk to match different future devices.

Jan

-- 
Siemens AG, Corporate Technology, CT RDA ITP SES-DE
Corporate Competence Center Embedded Linux
