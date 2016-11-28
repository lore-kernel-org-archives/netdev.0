From: Lino Sanfilippo <lsanfil@marvell.com>
Subject: Re: stmmac ethernet in kernel 4.4: coalescing related pauses?
Date: Mon, 28 Nov 2016 16:57:35 +0100
Message-ID: <920b1148-a77d-0b69-01b0-b14bcbdf8648@marvell.com>
References: <20161123105125.GA26394@amd>
 <f14255ee-7fa8-afef-23ec-fc4f9a74eec8@marvell.com>
 <20161128.095431.856183735501262965.davem@davemloft.net>
 <1480347103.18162.58.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <pavel@ucw.cz>, <peppe.cavallaro@st.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480347103.18162.58.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 28.11.2016 16:31, Eric Dumazet wrote:
> On Mon, 2016-11-28 at 09:54 -0500, David Miller wrote:
>> From: Lino Sanfilippo <lsanfil@marvell.com>
>> Date: Mon, 28 Nov 2016 14:07:51 +0100
>>
>>> Calling skb_orphan() in the xmit handler made this issue disappear.
>>
>> This is not the way to handle this problem.
>>
>> The solution is to free the SKBs in a timely manner after the
>> chip has transmitted the frame.
>
> Note that the 'pauses' described by Pavel are also caused by a too small
> SO_SNDBUF value on the UDP socket.
>
> An immediate fix, with no kernel change is to increase it.
>
> echo 1000000 >/proc/sys/net/core/wmem_default
>
> or
>
> val = 1000000;
> setsockopt(fd, SOL_SOCKET, SO_SNDBUF, &val, sizeof(val));
>

I wonder if the best fix would be indeed to deactivate irq coalescing completely.
Does it make any sense at all to use it if a driver uses NAPI already?

Regards,
Lino
