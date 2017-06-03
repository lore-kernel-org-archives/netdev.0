From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH] net: stmmac: ensure jumbo_frm error return is correctly
 checked for -ve value
Date: Sat, 3 Jun 2017 20:18:32 +0300
Message-ID: <CAHp75VdU0MmFJhZ2V1eLwSK_DnvFGxuOX337nw3wusyrWVtGxw@mail.gmail.com>
References: <20170602145827.21151-1-colin.king@canonical.com>
 <CAHp75VeuumsZHDdue=n-2esyG7Q-6472JoYJ64U0+OQoC2psgQ@mail.gmail.com> <40331b09-5829-9041-f815-7f1426960bd8@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev <netdev@vger.kernel.org>, kernel-janitors@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Colin Ian King <colin.king@canonical.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <40331b09-5829-9041-f815-7f1426960bd8@canonical.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 3, 2017 at 7:35 PM, Colin Ian King <colin.king@canonical.com> wrote:
> On 03/06/17 16:55, Andy Shevchenko wrote:
>> On Fri, Jun 2, 2017 at 5:58 PM, Colin King <colin.king@canonical.com> wrote:
>>> The current comparison of entry < 0 will never be true since entry is an
>>> unsigned integer. Cast entry to an int to ensure -ve error return values
>>> from the call to jumbo_frm are correctly being caught.
>>
>>>         if (unlikely(is_jumbo) && likely(priv->synopsys_id <
>>>                                          DWMAC_CORE_4_00)) {
>>>                 entry = priv->hw->mode->jumbo_frm(tx_q, skb, csum_insertion);
>>> -               if (unlikely(entry < 0))
>>> +               if (unlikely((int)entry < 0))
>>
>> It feels like a hiding some other issue.
>>
>
> The alternative is:
>
>                 int rc = priv->hw->mode->jumbo_frm(tx_q, skb, csum_insertion);
>                 if (unlikely(rc < 0))
>                         goto dma_map_err;
>
>                 entry = rc;

Looks cleaner, though I was thinking about changing type of entry as
Julia suggested. Needs to be checked carefully anyway.

> however, that is effectively the same. The cast I'm using is a well used
> idiom in the kernel, it used in almost a hundred similar cases.

> git grep "< 0" | grep "(int)" | wc -l
> 95

With refined grep I'e got only 56 so far. And I see it's spread only
in 45 modules, most cases are single use cases.
So, I hardly can tell this is an idiom in kernel.

-- 
With Best Regards,
Andy Shevchenko
