From: Mason <slash.tmp@free.fr>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Thu, 12 Nov 2015 14:33:48 +0100
Message-ID: <5644953C.8000800@free.fr>
References: <1447172063-27234-1-git-send-email-mans@mansr.com>
 <564241BF.4020700@free.fr> <yw1xbnb1r70r.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mans Rullgard <mans@mansr.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <yw1xbnb1r70r.fsf@unicorn.mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/11/2015 20:25, M=E5ns Rullg=E5rd wrote:

> Mason writes:
>=20
>> On 10/11/2015 17:14, Mans Rullgard wrote:
>>
>>> This adds a driver for the Aurora VLSI NB8800 Ethernet controller.
>>> It is an almost complete rewrite of a driver originally found in
>>> a Sigma Designs 2.6.22 tree.
>>>
>>> Signed-off-by: Mans Rullgard <mans@mansr.com>
>>> ---
>>> Changes:
>>> - Refactored mdio access functions
>>> - Refactored register access helpers
>>> - Improved error handling in rx buffer allocation
>>> - Optimised some fifo parameters
>>> - Overhauled tx dma. Multiple packets are now chained in a single d=
ma
>>>   operation if xmit_more is set, improving performance.
>>> - Improved rx irq handling. It's not possible to disable interrupts
>>>   entirely for napi poll, but they can be slowed down a little.
>>> - Use readx_poll_timeout in various places
>>> - Improved error detection
>>> - Improved statistics
>>> - Report hardware statistics counters through ethtool
>>> - Improved tangox-specific setup
>>> - Support for flow control using pause frames
>>> - Explanatory comments added
>>> - Various minor stylistic changes
>>> ---
>>>  drivers/net/ethernet/Kconfig         |    1 +
>>>  drivers/net/ethernet/Makefile        |    1 +
>>>  drivers/net/ethernet/aurora/Kconfig  |   20 +
>>>  drivers/net/ethernet/aurora/Makefile |    1 +
>>>  drivers/net/ethernet/aurora/nb8800.c | 1530 ++++++++++++++++++++++=
++++++++++++
>>>  drivers/net/ethernet/aurora/nb8800.h |  314 +++++++
>>>  6 files changed, 1867 insertions(+)
>>
>> The code has grown much since the previous patch, despite some
>> refactoring. Is this mostly due to ethtool_ops support?
>>
>>  drivers/net/ethernet/aurora/nb8800.c | 1146 +++++++++++++++++++++++=
+++++++++++
>>  drivers/net/ethernet/aurora/nb8800.h |  230 +++++++
>=20
> Some of the increase is from new features, some from improvements, an=
d
> then there are a bunch of new comments.

Sweet.

With this version, my kernel boots faster than before
(I had been using a 5 month-old version.)

Before:

[    0.613623] tangox-enet 26000.ethernet: SMP86xx internal Ethernet at=
 0x26000
[    0.623638] libphy: tangox-mii: probed
[    0.686527] tangox-enet 26000.ethernet: PHY: found Atheros 8035 ethe=
rnet at 0x4
[    0.697169] tangox-enet 26000.ethernet eth0: MAC address 00:16:e8:02=
:08:42
=2E..
[    1.306360] Sending DHCP requests ..
[    4.699969] tangox-enet 26000.ethernet eth0: Link is Up - 1Gbps/Full=
 - flow control rx/tx
[    8.899671] ., OK
[    8.926343] IP-Config: Got DHCP answer from 172.27.200.1, my address=
 is 172.27.64.49
=2E..
[    8.987327] Freeing unused kernel memory: 168K (c039e000 - c03c8000)

After:

[    0.623526] libphy: nb8800-mii: probed
[    0.628092] nb8800 26000.ethernet eth0: MAC address 00:16:e8:02:08:4=
2
=2E..
[    4.732948] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - fl=
ow control rx/tx
[    4.752655] Sending DHCP requests ., OK
[    4.782644] IP-Config: Got DHCP answer from 172.27.200.1, my address=
 is 172.27.64.49
=2E..
[    4.849298] Freeing unused kernel memory: 164K (c039f000 - c03c8000)


The DHCP request is sent later, but the kernel doesn't twiddle its thum=
bs
for 4 seconds after the link comes up. Does this come from not probing =
the
PHY anymore?

BTW, you're not using the PHY IRQ, right? I think I remember you saying
it didn't work reliably?

Regards.
