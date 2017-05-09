From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: mlx5 endpoint driver problem
Date: Tue, 9 May 2017 20:44:48 +0300
Message-ID: <CALzJLG9OSk4MQEAhHLh76G2n=L=nkahKc_Ro+Fu9HyLYxmuJ=A@mail.gmail.com>
References: <f0b8881d-9aa3-8816-7ea6-daccc0e91262@synopsys.com>
 <CALzJLG8uieD52haz2WYbh2zWLKLgF-kUFw-2DU-sqC1+byPAKw@mail.gmail.com> <1ea4f8fa-16dc-01d8-2995-514053635fd3@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        netdev <netdev@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:36061 "EHLO
        mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752740AbdEIRpJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 13:45:09 -0400
Received: by mail-qk0-f180.google.com with SMTP id u75so7462005qka.3
        for <netdev@vger.kernel.org>; Tue, 09 May 2017 10:45:09 -0700 (PDT)
In-Reply-To: <1ea4f8fa-16dc-01d8-2995-514053635fd3@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 9, 2017 at 8:38 PM, Joao Pinto <Joao.Pinto@synopsys.com> wrote:
> Hi Saeed,
>
> =C3=80s 6:35 PM de 5/9/2017, Saeed Mahameed escreveu:
>> On Tue, May 9, 2017 at 7:25 PM, Joao Pinto <Joao.Pinto@synopsys.com> wro=
te:
>>> Hello,
>>>
>>> I am making tests with a Mellanox MLX5 Endpoint, and I am getting kerne=
l hangs
>>> when trying to enable the hca:
>>>
>>> mlx5_core 0000:01:00.0: enabling device (0000 -> 0002)
>>> mlx5_core 0000:01:00.0: Warning: couldn't set 64-bit PCI DMA mask
>>> mlx5_core 0000:01:00.0: Warning: couldn't set 64-bit consistent PCI DMA=
 mask
>>> mlx5_core 0000:01:00.0: firmware version: 16.19.21102
>>> INFO: task swapper:1 blocked for more than 10 seconds.
>>>       Not tainted 4.11.0-BETAMSIX1 #51
>>> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this messag=
e.
>>> swapper         D    0     1      0 0x00000000
>>>
>>> Stack Trace:
>>>   __switch_to+0x0/0x94
>>>   __schedule+0x1da/0x8b0
>>>   schedule+0x26/0x6c
>>>   schedule_timeout+0x2da/0x380
>>>   wait_for_completion+0x92/0x104
>>>   mlx5_cmd_exec+0x70e/0xd60
>>>   mlx5_load_one+0x1b4/0xad8
>>>   init_one+0x404/0x600
>>>   pci_device_probe+0x122/0x1f0
>>>   really_probe+0x1ac/0x348
>>>   __driver_attach+0xa8/0xd0
>>>   bus_for_each_dev+0x3c/0x74
>>>   bus_add_driver+0xc2/0x184
>>>   driver_register+0x50/0xec
>>>   init+0x40/0x60
>>>
>>> (...)
>>>
>>> Stack Trace:
>>>   __switch_to+0x0/0x94
>>>   __schedule+0x1da/0x8b0
>>>   schedule+0x26/0x6c
>>>   schedule_timeout+0x2da/0x380
>>>   wait_for_completion+0x92/0x104
>>>   mlx5_cmd_exec+0x70e/0xd60
>>>   mlx5_load_one+0x1b4/0xad8
>>>   init_one+0x404/0x600
>>>   pci_device_probe+0x122/0x1f0
>>>   really_probe+0x1ac/0x348
>>>   __driver_attach+0xa8/0xd0
>>>   bus_for_each_dev+0x3c/0x74
>>>   bus_add_driver+0xc2/0x184
>>>   driver_register+0x50/0xec
>>>   init+0x40/0x60
>>> mlx5_core 0000:01:00.0: wait_func:882:(pid 1): ENABLE_HCA(0x104) timeou=
t. Will
>>> cause a leak of a command resource
>>> mlx5_core 0000:01:00.0: enable hca failed
>>> mlx5_core 0000:01:00.0: mlx5_load_one failed with error code -110
>>> mlx5_core: probe of 0000:01:00.0 failed with error -110
>>>
>>> Could you give me a clue of what might be happennig?
>>>
>>
>> Hi Joao,
>>
>> Looks like FW is not responding, most likely due to the DMA mask
>> setting warnings, which architecture is this ?
>>
>>> Thanks,
>>> Joao
>
> I am working with a 32-bit ARC processor based board, connected to a prot=
otyped
> Gen4 PCI RC.
>

Ok, i will consult with our PCI and FW experts and get back to you.

please note that the current mlx5 driver was never tested on 32-bit
architecture and might not work properly for you.

> Thanks,
> Joao
>
>
>
