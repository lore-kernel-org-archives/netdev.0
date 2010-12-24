From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: [PATCH 1/4] net: phy: balance disable/enable irq on change
Date: Fri, 24 Dec 2010 09:46:51 +0100
Message-ID: <AANLkTinVEVcVCH01Hg4QXAV0V-J9UE+9guM1ttorQGLR@mail.gmail.com>
References: <1292756331-3735-1-git-send-email-jhautbois@gmail.com>
	<20101223.112450.246547841.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: richard.cochran@omicron.at, shemminger@vyatta.com, tj@kernel.org,
	randy.dunlap@oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101223.112450.246547841.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2010/12/23 David Miller <davem@davemloft.net>:
> From: Jean-Michel Hautbois <jhautbois@gmail.com>
> Date: Sun, 19 Dec 2010 11:58:48 +0100
>
>> When phy interface changes its status, it calls phy_change() functio=
n.
>> This function calls the interrupt disabling functions for the driver
>> registered, but if this driver doesn't implement it, there is no IRQ
>> disabling. After doing the work, we call enable_irq and not the
>> respective driver function. This fixes it, as it could lead to an
>> unbalanced IRQ. Error code changed to EOPNOTSUPP.
>>
>> Signed-off-by: Jean-Michel Hautbois <jhautbois@gmail.com>
>
> This is completely bogus.
>
> First of all, there are 5 call sites for phy_change_interrupt() but
> you've only implemented the new semantics for two of those.
>
> Therefore, if we even wanted this, we should implement the behavior i=
n
> phy_change_interrupt() itself instead of duplicating the logic at
> each and every call site.
>
> But we don't want this.

OK, I understand that point.

> It's not appropriate at all. =C2=A0If a device lacks a way to turn
> interrupt off and on, using disable_irq() and enable_irq() is not
> necessarily correct.
>
> If the interrupt line is shared, for example, this will break
> everything.
>

OK, well, maybe is there at least one thing we could do : in
phy_change, instead of calling phy_disable_interrupts(), balanced by
enable_irq, we probably should use phy_enable_interrupts().
