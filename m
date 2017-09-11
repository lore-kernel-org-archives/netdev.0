From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH] net: bonding: Fix transmit load balancing in balance-alb
 mode if specified by sysfs
Date: Mon, 11 Sep 2017 09:07:33 -0700
Message-ID: <CAF2d9jhEQCGuP3jX=cca-1VSmXbZtfCBN7xHnBfiw+_Ch=ihzw@mail.gmail.com>
References: <17EC94B0A072C34B8DCF0D30AD16044A02985CB5@BPXM09GP.gisp.nec.co.jp> <adab6b74-574b-74cb-09ea-3b5090113ca6@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Kosuke Tatsukawa <tatsu@ab.jp.nec.com>,
        Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Reinis Rozitis <r@roze.lv>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <adab6b74-574b-74cb-09ea-3b5090113ca6@cumulusnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 9, 2017 at 4:28 AM, Nikolay Aleksandrov
<nikolay@cumulusnetworks.com> wrote:
> On 07/09/17 01:47, Kosuke Tatsukawa wrote:
>> Commit cbf5ecb30560 ("net: bonding: Fix transmit load balancing in
>> balance-alb mode") tried to fix transmit dynamic load balancing in
>> balance-alb mode, which wasn't working after commit 8b426dc54cf4
>> ("bonding: remove hardcoded value").
>>
>> It turned out that my previous patch only fixed the case when
>> balance-alb was specified as bonding module parameter, and not when
>> balance-alb mode was set using /sys/class/net/*/bonding/mode (the most
>> common usage).  In the latter case, tlb_dynamic_lb was set up according
>> to the default mode of the bonding interface, which happens to be
>> balance-rr.
>>
>> This additional patch addresses this issue by setting up tlb_dynamic_lb
>> to 1 if "mode" is set to balance-alb through the sysfs interface.
>>
>> I didn't add code to change tlb_balance_lb back to the default value for
>> other modes, because "mode" is usually set up only once during
>> initialization, and it's not worthwhile to change the static variable
>> bonding_defaults in bond_main.c to a global variable just for this
>> purpose.
>>
>> Commit 8b426dc54cf4 also changes the value of tlb_dynamic_lb for
>> balance-tlb mode if it is set up using the sysfs interface.  I didn't
>> change that behavior, because the value of tlb_balance_lb can be changed
>> using the sysfs interface for balance-tlb, and I didn't like changing
>> the default value back and forth for balance-tlb.
>>
>> As for balance-alb, /sys/class/net/*/bonding/tlb_balance_lb cannot be
>> written to.  However, I think balance-alb with tlb_dynamic_lb set to 0
>> is not an intended usage, so there is little use making it writable at
>> this moment.
>>
>> Fixes: 8b426dc54cf4 ("bonding: remove hardcoded value")
>> Reported-by: Reinis Rozitis <r@roze.lv>
>> Signed-off-by: Kosuke Tatsukawa <tatsu@ab.jp.nec.com>
>> Cc: stable@vger.kernel.org  # v4.12+
>> ---
>>  drivers/net/bonding/bond_options.c |    3 +++
>>  1 files changed, 3 insertions(+), 0 deletions(-)
>>
>
> This fix is simpler and more suitable for -net, it fixes the case where
> we switch to ALB mode with tlb_dynamic_lb = 0. After it is in I'll fix the
> default tlb_dynamic_lb issue and restore the original behaviour.
>
Changing tlb_dyanamic_lb to initialize always is also safe for -net
and can go in before or after this change (no dependency on this
change as such)

> Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Acked-by: Mahesh Bandewar <maheshb@google.com>
>
>
