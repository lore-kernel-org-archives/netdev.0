From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH] net: bonding: Fix transmit load balancing in balance-alb
 mode if specified by sysfs
Date: Thu, 7 Sep 2017 17:47:32 -0700
Message-ID: <CAF2d9jh-724+D3smkYD-HvEZZfnAezBt5D18ZPPOGEjtdvrq3g@mail.gmail.com>
References: <17EC94B0A072C34B8DCF0D30AD16044A02985CB5@BPXM09GP.gisp.nec.co.jp>
 <c9b6ae59-741b-3ecd-47ff-1d5b41710607@cumulusnetworks.com> <CAF2d9jhxrpmTEqHtf6NES4LmoT8A5O1v==8NJZcDGhS-PS5AFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Kosuke Tatsukawa <tatsu@ab.jp.nec.com>,
        Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Reinis Rozitis <r@roze.lv>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAF2d9jhxrpmTEqHtf6NES4LmoT8A5O1v==8NJZcDGhS-PS5AFQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 7, 2017 at 5:39 PM, Mahesh Bandewar (=E0=A4=AE=E0=A4=B9=E0=A5=
=87=E0=A4=B6 =E0=A4=AC=E0=A4=82=E0=A4=A1=E0=A5=87=E0=A4=B5=E0=A4=BE=E0=A4=
=B0)
<maheshb@google.com> wrote:
> On Thu, Sep 7, 2017 at 4:09 PM, Nikolay Aleksandrov
> <nikolay@cumulusnetworks.com> wrote:
>> On  7.09.2017 01:47, Kosuke Tatsukawa wrote:
>>> Commit cbf5ecb30560 ("net: bonding: Fix transmit load balancing in
>>> balance-alb mode") tried to fix transmit dynamic load balancing in
>>> balance-alb mode, which wasn't working after commit 8b426dc54cf4
>>> ("bonding: remove hardcoded value").
>>>
>>> It turned out that my previous patch only fixed the case when
>>> balance-alb was specified as bonding module parameter, and not when
>>> balance-alb mode was set using /sys/class/net/*/bonding/mode (the most
>>> common usage).  In the latter case, tlb_dynamic_lb was set up according
>>> to the default mode of the bonding interface, which happens to be
>>> balance-rr.
>>>
>>> This additional patch addresses this issue by setting up tlb_dynamic_lb
>>> to 1 if "mode" is set to balance-alb through the sysfs interface.
>>>
>>> I didn't add code to change tlb_balance_lb back to the default value fo=
r
>>> other modes, because "mode" is usually set up only once during
>>> initialization, and it's not worthwhile to change the static variable
>>> bonding_defaults in bond_main.c to a global variable just for this
>>> purpose.
>>>
>>> Commit 8b426dc54cf4 also changes the value of tlb_dynamic_lb for
>>> balance-tlb mode if it is set up using the sysfs interface.  I didn't
>>> change that behavior, because the value of tlb_balance_lb can be change=
d
>>> using the sysfs interface for balance-tlb, and I didn't like changing
>>> the default value back and forth for balance-tlb.
>>>
>>> As for balance-alb, /sys/class/net/*/bonding/tlb_balance_lb cannot be
>>> written to.  However, I think balance-alb with tlb_dynamic_lb set to 0
>>> is not an intended usage, so there is little use making it writable at
>>> this moment.
>>>
>>> Fixes: 8b426dc54cf4 ("bonding: remove hardcoded value")
>
> This is wrong! I think you are confusing various things here. ALB is
> different mode from TLB and TLB-dynamic-lb is *only* a special case of
> TLB. Your earlier patch is also wrong for the same reasons. However,
> since the default value of tlb_dynamic_lb is set to 0  it's not
> causing issues for ALB mode otherwise it would break ALB mode.
I take this back. The default value is 1 so ALB is broken because of
the referenced change.

> tlb_dynamic_lb has absolutely nothing to do with ALB mode. Please
> revert the earlier change (cbf5ecb30560).
>
> It's not clear to me what you saw as broken, so can't really suggest
> what really need to be done.
