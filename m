From: Urban Loesch <bind@enas.net>
Subject: Re: [bnx2x] Re: Kernel 3.18.11 hangs when inserting netconsle module
 on a DELL M620 VRTX Blade
Date: Thu, 09 Apr 2015 14:34:22 +0200
Message-ID: <552671CE.3050506@enas.net>
References: <5524E669.5050903@enas.net> <55250808.6000606@hurleysoftware.com> <B5657A6538887040AD3A81F1008BEC63C26537@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	netdev <netdev@vger.kernel.org>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Peter Hurley <peter@hurleysoftware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63C26537@avmb3.qlogic.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

thanks for your help.

Am 08.04.2015 um 16:42 schrieb Yuval Mintz:
>>> I'have installed a new DELL VRTX M620 Blade with kernel 3.18.11.
>>> After system startup I tried to activate the kernel netconsole with remote
>> logging enabled.
>>>
>>> I executed the following command and the shell I issued it becomes
>> unresponsive and hangs.
>>>
>>> #  modprobe netconsole
>> netconsole="@/eth0,514@10.1.10.197/00:10:db:fc:60:0c"
>>>
>>> The system load increases slowly and the CPU #11 uses 100% of soft
>>> irq. Only a soft reset witohut loading the netconsole module after startup
>> solves the issue.
> 
> I suspect this is a regression introduced by 9a2620c87745
> "bnx2x: prevent WARN during driver unload".
> 
> bnx2x locks & unlocks spin_lock_bh() during the napi poll, which shouldn't
> be done while interrupts are disabled. This break interoperability with netpoll,
> as it disables irqs prior to sending the skb on the bnx2x's interface.
> 
> Can you please try compiling your kernel without CONFIG_NET_RX_BUSY_POLL?
> I suspect that might solve your issue.

I compiled my kernel without CONFIG_NET_RX_BUSY_POLL.
...
# CONFIG_NET_RX_BUSY_POLL is not set
...

I tried multiple times to insert an remove the netconsole module.
There was no error anymore.

Compiling the kernel without CONFIG_NET_RX_BUSY_POLL solves the issue.
At least for me.

Thanks
Urban
