From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH] net: bonding: Fix transmit load balancing in balance-alb mode if specified by sysfs
Date: Mon, 11 Sep 2017 19:30:08 +0300
Message-ID: <819E319E-B2EE-44FF-8616-03257E753E6C@cumulusnetworks.com>
References: <17EC94B0A072C34B8DCF0D30AD16044A02985CB5@BPXM09GP.gisp.nec.co.jp> <adab6b74-574b-74cb-09ea-3b5090113ca6@cumulusnetworks.com> <CAF2d9jhEQCGuP3jX=cca-1VSmXbZtfCBN7xHnBfiw+_Ch=ihzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Kosuke Tatsukawa <tatsu@ab.jp.nec.com>,
        Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Reinis Rozitis <r@roze.lv>
To: =?UTF-8?B?TWFoZXNoIEJhbmRld2Fy?=
         =?UTF-8?B?ICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAF2d9jhEQCGuP3jX=cca-1VSmXbZtfCBN7xHnBfiw+_Ch=ihzw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11 September 2017 19:07:33 EEST, "Mahesh Bandewar (=E0=A4=AE=E0=A4=B9=E0=
=A5=87=E0=A4=B6 =E0=A4=AC=E0=A4=82=E0=A4=A1=E0=A5=87=E0=A4=B5=E0=A4=BE=E0=
=A4=B0)" <maheshb@google=2Ecom> wrote:
>On Sat, Sep 9, 2017 at 4:28 AM, Nikolay Aleksandrov
><nikolay@cumulusnetworks=2Ecom> wrote:
>> On 07/09/17 01:47, Kosuke Tatsukawa wrote:
>>> Commit cbf5ecb30560 ("net: bonding: Fix transmit load balancing in
>>> balance-alb mode") tried to fix transmit dynamic load balancing in
>>> balance-alb mode, which wasn't working after commit 8b426dc54cf4
>>> ("bonding: remove hardcoded value")=2E
>>>
>>> It turned out that my previous patch only fixed the case when
>>> balance-alb was specified as bonding module parameter, and not when
>>> balance-alb mode was set using /sys/class/net/*/bonding/mode (the
>most
>>> common usage)=2E  In the latter case, tlb_dynamic_lb was set up
>according
>>> to the default mode of the bonding interface, which happens to be
>>> balance-rr=2E
>>>
>>> This additional patch addresses this issue by setting up
>tlb_dynamic_lb
>>> to 1 if "mode" is set to balance-alb through the sysfs interface=2E
>>>
>>> I didn't add code to change tlb_balance_lb back to the default value
>for
>>> other modes, because "mode" is usually set up only once during
>>> initialization, and it's not worthwhile to change the static
>variable
>>> bonding_defaults in bond_main=2Ec to a global variable just for this
>>> purpose=2E
>>>
>>> Commit 8b426dc54cf4 also changes the value of tlb_dynamic_lb for
>>> balance-tlb mode if it is set up using the sysfs interface=2E  I
>didn't
>>> change that behavior, because the value of tlb_balance_lb can be
>changed
>>> using the sysfs interface for balance-tlb, and I didn't like
>changing
>>> the default value back and forth for balance-tlb=2E
>>>
>>> As for balance-alb, /sys/class/net/*/bonding/tlb_balance_lb cannot
>be
>>> written to=2E  However, I think balance-alb with tlb_dynamic_lb set to
>0
>>> is not an intended usage, so there is little use making it writable
>at
>>> this moment=2E
>>>
>>> Fixes: 8b426dc54cf4 ("bonding: remove hardcoded value")
>>> Reported-by: Reinis Rozitis <r@roze=2Elv>
>>> Signed-off-by: Kosuke Tatsukawa <tatsu@ab=2Ejp=2Enec=2Ecom>
>>> Cc: stable@vger=2Ekernel=2Eorg  # v4=2E12+
>>> ---
>>>  drivers/net/bonding/bond_options=2Ec |    3 +++
>>>  1 files changed, 3 insertions(+), 0 deletions(-)
>>>
>>
>> This fix is simpler and more suitable for -net, it fixes the case
>where
>> we switch to ALB mode with tlb_dynamic_lb =3D 0=2E After it is in I'll
>fix the
>> default tlb_dynamic_lb issue and restore the original behaviour=2E
>>
>Changing tlb_dyanamic_lb to initialize always is also safe for -net
>and can go in before or after this change (no dependency on this
>change as such)

I never said it was unsafe or dependent, it is simply my preference to wai=
t=2E :-)
If you need it sooner feel free to post it=2E

>
>> Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks=2Ecom>
>Acked-by: Mahesh Bandewar <maheshb@google=2Ecom>
>>
>>
