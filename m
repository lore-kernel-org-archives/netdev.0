From: Roland Stigge <stigge@antcom.de>
Subject: Re: r8169 delay / segfault
Date: Sat, 13 Oct 2012 00:14:33 +0200
Message-ID: <50789649.3080202@antcom.de>
References: <50787109.7080605@antcom.de> <20121012210503.GA2054@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org,
	hayeswang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from antcom.de ([188.40.178.216]:56107 "EHLO chuck.antcom.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752666Ab2JLWOw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2012 18:14:52 -0400
In-Reply-To: <20121012210503.GA2054@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On 12/10/12 23:05, Francois Romieu wrote:
> Roland Stigge <stigge@antcom.de> :
> [...]
>> on a Samsung laptop (x86_64, kernel 3.6.0), I get the following messages in the kernel
>> log after a suspend/resume cycle (doesn't happen after every suspend/resume but sometimes):
>>
>> Oct 12 21:02:27 darwin kernel: [ 4289.829755] r8169 0000:02:00.0: wake-up capability disabled by ACPI
>> Oct 12 21:02:27 darwin kernel: [ 4289.830351] r8169 0000:02:00.0: eth0: rtl_phyar_cond == 1 (loop: 20, delay: 25).
> [...]
>> Oct 12 21:02:27 darwin kernel: [ 4289.858920] r8169 0000:02:00.0: eth0: rtl_phyar_cond == 1 (loop: 20, delay: 25).
> [...]
>> Oct 12 21:04:56 darwin kernel: [ 4441.330385] r8169 0000:02:00.0: eth0: rtl_chipcmd_cond == 1 (loop: 100, delay: 100).
>> Oct 12 21:04:56 darwin kernel: [ 4441.331592] r8169 0000:02:00.0: eth0: rtl_csiar_cond == 1 (loop: 100, delay: 10).
>> Oct 12 21:04:56 darwin kernel: [ 4441.332727] r8169 0000:02:00.0: eth0: rtl_ephyar_cond == 1 (loop: 100, delay: 10).
> [...]
>> Oct 12 21:04:56 darwin kernel: [ 4441.343912] r8169 0000:02:00.0: eth0: rtl_eriar_cond == 1 (loop: 100, delay: 100).
> 
> The device seems completely unresponsive :o/
> 
>> Oct 12 21:04:56 darwin kernel: [ 4441.454689] r8169 0000:02:00.0: eth0: link up
>>
>> I copied a bigger part of the kernel log at http://antcom.de/kernel/dmesg.
>>
>> Please tell me how I can help debugging or what else information you need.
> 
> The device does not recover despite the "link up" message, right ?

Right.

> Can you send the XID line from the r8169 driver ? It should be in the
> upper part of the dmesg log.

Oct 12 23:46:45 darwin kernel: [    1.562479] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
Oct 12 23:46:45 darwin kernel: [    1.562728] r8169 0000:02:00.0: irq 40 for MSI/MSI-X
Oct 12 23:46:45 darwin kernel: [    1.562968] r8169 0000:02:00.0: eth0: RTL8168evl/8111evl at 0xffffc9000066c000, e8:03:9a:dc:e7:57, XID 0c900800 IRQ 40
Oct 12 23:46:45 darwin kernel: [    1.562972] r8169 0000:02:00.0: eth0: jumbo features [frames: 9200 bytes, tx checksumming: ko]

> Which kernel version did you previously use ?

I used the Debian standard kernel 3.2 but had several spontaneous crashes. Memtests
and everything work fine. After upgrading, everything works but network sometimes
breaks after suspend/resume (although "link up" is reported). Seems quite reproducible.

Roland
