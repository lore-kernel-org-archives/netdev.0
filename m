From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 1/4] mlx5: Make building eswitch configurable
Date: Fri, 27 Jan 2017 20:05:07 +0200
Message-ID: <CALzJLG9YXBzXAOrtth7SX8n3S5cN3ZSmKax4FOGiTr7SY8gobg@mail.gmail.com>
References: <20170126233241.2268449-1-tom@herbertland.com> <20170126233241.2268449-2-tom@herbertland.com>
 <CAJ3xEMhaQ4zsBxkWzs8qCv5KT-gAmdD9dNkSS+KDwB+VGw5SEw@mail.gmail.com>
 <CALzJLG_v2HxsdPdX5H=T51RGmaMMnXVxzihuPN66a9RxDadEcw@mail.gmail.com> <CALx6S34K-N7TWtEG0cCgq-zAXqqfNp9zp1JtR8bLvD=F90A2pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:35178 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750917AbdA0Sbs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 13:31:48 -0500
Received: by mail-qt0-f195.google.com with SMTP id s58so6835926qtc.2
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 10:31:22 -0800 (PST)
In-Reply-To: <CALx6S34K-N7TWtEG0cCgq-zAXqqfNp9zp1JtR8bLvD=F90A2pg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 27, 2017 at 7:50 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Fri, Jan 27, 2017 at 9:38 AM, Saeed Mahameed
> <saeedm@dev.mellanox.co.il> wrote:
>> On Fri, Jan 27, 2017 at 7:34 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>> On Fri, Jan 27, 2017 at 1:32 AM, Tom Herbert <tom@herbertland.com> wrote:
>>>> Add a configuration option (CONFIG_MLX5_CORE_ESWITCH) for controlling
>>>> whether the eswitch code is built. Change Kconfig and Makefile
>>>> accordingly.
>>>
>>> Tom, FWIW, please note that the basic e-switch functionality is needed
>>> also when SRIOV isn't of use, this is for a multi host configuration.
>>>
>>
>> Right, set_l2_table_entry@eswitch.c need to be called by PF for any UC
>> MAC address wanted by VF or PF.
>> To keep one flow in the code, the implementation is done as part of eswitch.
>>
>> so in multi-host configuration (where there are 4 PFs) each PF should
>> invoke set_l2_table_entry_cmd  for each one of its own UC MACs.
>>
>> populating the l2 table is done using the whole eswitch event driven
>> mechanisms, it is not easy and IMH not right to separate eswitch
>> tables from l2 table (same management logic, different tables).
>>
>> Anyways as Or stated this is just an FYI, eswitch needs to be enabled
>> on Multi-host configuration.
>>
> What indicate a multi-host configuration?

nothing in the driver, it is transparent.

>
>>> Or.
>>>
>>> My WW (and same for the rest of the IL team..) has ended so I will be
>>> able to further look on this series and comment on Sunday.
