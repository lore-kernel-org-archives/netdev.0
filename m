From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 1/4] mlx5: Make building eswitch configurable
Date: Fri, 27 Jan 2017 10:42:20 -0800
Message-ID: <CALx6S35-ecvO0k6-yqdLpO6mXA4Y6mycMD3HqHPCaUtMZd8GYA@mail.gmail.com>
References: <20170126233241.2268449-1-tom@herbertland.com> <20170126233241.2268449-2-tom@herbertland.com>
 <CAJ3xEMhaQ4zsBxkWzs8qCv5KT-gAmdD9dNkSS+KDwB+VGw5SEw@mail.gmail.com>
 <CALzJLG_v2HxsdPdX5H=T51RGmaMMnXVxzihuPN66a9RxDadEcw@mail.gmail.com>
 <CALx6S34K-N7TWtEG0cCgq-zAXqqfNp9zp1JtR8bLvD=F90A2pg@mail.gmail.com>
 <CALzJLG9YXBzXAOrtth7SX8n3S5cN3ZSmKax4FOGiTr7SY8gobg@mail.gmail.com>
 <CALx6S375OVvSi5QLLCpsGc84iE3cJ3VH5Rm6sg8OJgDR=nqXfA@mail.gmail.com> <CALzJLG_WCiTei7CDoUCzM241gt0bSKqjGJ61ke2XbbQTOjZBkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:33259 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750737AbdA0Sm0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 13:42:26 -0500
Received: by mail-qt0-f196.google.com with SMTP id n13so47709916qtc.0
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 10:42:21 -0800 (PST)
In-Reply-To: <CALzJLG_WCiTei7CDoUCzM241gt0bSKqjGJ61ke2XbbQTOjZBkQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 27, 2017 at 10:28 AM, Saeed Mahameed
<saeedm@dev.mellanox.co.il> wrote:
> On Fri, Jan 27, 2017 at 8:16 PM, Tom Herbert <tom@herbertland.com> wrote:
>> On Fri, Jan 27, 2017 at 10:05 AM, Saeed Mahameed
>> <saeedm@dev.mellanox.co.il> wrote:
>>> On Fri, Jan 27, 2017 at 7:50 PM, Tom Herbert <tom@herbertland.com> wrote:
>>>> On Fri, Jan 27, 2017 at 9:38 AM, Saeed Mahameed
>>>> <saeedm@dev.mellanox.co.il> wrote:
>>>>> On Fri, Jan 27, 2017 at 7:34 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>>>>> On Fri, Jan 27, 2017 at 1:32 AM, Tom Herbert <tom@herbertland.com> wrote:
>>>>>>> Add a configuration option (CONFIG_MLX5_CORE_ESWITCH) for controlling
>>>>>>> whether the eswitch code is built. Change Kconfig and Makefile
>>>>>>> accordingly.
>>>>>>
>>>>>> Tom, FWIW, please note that the basic e-switch functionality is needed
>>>>>> also when SRIOV isn't of use, this is for a multi host configuration.
>>>>>>
>>>>>
>>>>> Right, set_l2_table_entry@eswitch.c need to be called by PF for any UC
>>>>> MAC address wanted by VF or PF.
>>>>> To keep one flow in the code, the implementation is done as part of eswitch.
>>>>>
>>>>> so in multi-host configuration (where there are 4 PFs) each PF should
>>>>> invoke set_l2_table_entry_cmd  for each one of its own UC MACs.
>>>>>
>>>>> populating the l2 table is done using the whole eswitch event driven
>>>>> mechanisms, it is not easy and IMH not right to separate eswitch
>>>>> tables from l2 table (same management logic, different tables).
>>>>>
>>>>> Anyways as Or stated this is just an FYI, eswitch needs to be enabled
>>>>> on Multi-host configuration.
>>>>>
>>>> What indicate a multi-host configuration?
>>>
>>> nothing in the driver, it is transparent.
>>>
>> So then we always need the eswitch code to be built even if someone
>> never uses any of it?
>>
>
> yes.
> but for your convenience all you need is to compile eswitch.c.
> esiwtch_offoalds.c and en_rep.c can be compiled out for basic ethernet.
>
Well eswitch.c is 2200 LOC. en_rep.c and eswitch_offloads.c are 1600
LOC. If we _must_ have eswitch.c then there's probably not much point
then. But I am still finding it hard to fathom that eswitch has now
become a mandatory component of Ethernet drivers/devices.

Tom

>>>>
>>>>>> Or.
>>>>>>
>>>>>> My WW (and same for the rest of the IL team..) has ended so I will be
>>>>>> able to further look on this series and comment on Sunday.
