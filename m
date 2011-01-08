From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: Re: Seeing transmit timeouts on 8139cp
Date: Sat, 08 Jan 2011 13:09:06 -0800
Message-ID: <4D28D272.2070900@redfish-solutions.com>
References: <4C92F853.8050701@redfish-solutions.com> <20100917200024.GA7288@electric-eye.fr.zoreil.com> <4C99A289.2030109@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:42507 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751086Ab1AHVJS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Jan 2011 16:09:18 -0500
In-Reply-To: <4C99A289.2030109@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/21/10 11:30 PM, Philip Prindeville wrote:
>  On 9/17/10 1:00 PM, Francois Romieu wrote:
>> Philip Prindeville<philipp_subx@redfish-solutions.com>  :
>> [...]
>>> Does this look familiar to anyone?
>> 349124a00754129a5f1e43efa84733e364bf3749 ?
>>
>> It would be a bit too easy.
>>
> Thanks.  I'll give it a try now.

No, that's not the problem.  Still seeing traces, even after applying that patch.

This is in 2.6.27.57:

Jan  8 00:11:25 pdx user.warn kernel: ------------[ cut here ]------------
Jan  8 00:11:25 pdx user.warn kernel: WARNING: at net/sched/sch_generic.c:219 dev_watchdog+0xf1/0x176()
Jan  8 00:11:25 pdx user.info kernel: NETDEV WATCHDOG: eth1 (8139cp): transmit timed out
Jan  8 00:11:25 pdx user.warn kernel: Modules linked in: pppoatm pppox ppp_generic slhc bridge stp llc solos_pci atm dummy ath5k mac80211 ath cfg80211 rfkill_backport compat dahdi sha512_generic sha256_generic deflate zlib_deflate arc4 ecb sha1_generic blowfish des
Jan  8 00:11:25 pdx user.warn kernel: Pid: 0, comm: swapper Tainted: P          2.6.27.57-astlinux #1
Jan  8 00:11:25 pdx user.warn kernel:  [<c0115462>] warn_slowpath+0x61/0x84
Jan  8 00:11:25 pdx user.warn kernel:  [<c026649b>] nf_hook_slow+0x44/0xb1
Jan  8 00:11:25 pdx user.warn kernel:  [<e018d968>] br_nf_pre_routing_finish+0x0/0x257 [bridge]
Jan  8 00:11:25 pdx user.warn kernel:  [<e018e5a3>] br_nf_pre_routing+0x532/0x54b [bridge]
Jan  8 00:11:25 pdx user.warn kernel:  [<c01065e8>] read_tsc+0x6/0x22
Jan  8 00:11:25 pdx user.warn kernel:  [<c01289a6>] getnstimeofday+0x4a/0xc7
Jan  8 00:11:25 pdx user.warn kernel:  [<c01267ca>] ktime_get_ts+0x1d/0x3f
Jan  8 00:11:25 pdx user.warn kernel:  [<c0126056>] hrtimer_forward+0xe2/0xfe
Jan  8 00:11:25 pdx user.warn kernel:  [<c025e0b3>] dev_watchdog+0x0/0x176
Jan  8 00:11:25 pdx user.warn kernel:  [<c01cfb57>] strlcpy+0x15/0x62
Jan  8 00:11:25 pdx user.warn kernel:  [<c025e1a4>] dev_watchdog+0xf1/0x176
Jan  8 00:11:25 pdx user.warn kernel:  [<e00e7f3c>] coretimer_func+0xb1/0x133 [dahdi]
Jan  8 00:11:25 pdx user.warn kernel:  [<c011c05a>] run_timer_softirq+0x116/0x17a
Jan  8 00:11:25 pdx user.warn kernel:  [<c0118ce4>] __do_softirq+0x35/0x75
Jan  8 00:11:25 pdx user.warn kernel:  [<c0118d46>] do_softirq+0x22/0x26
Jan  8 00:11:25 pdx user.warn kernel:  [<c0118f20>] irq_exit+0x25/0x30
Jan  8 00:11:25 pdx user.warn kernel:  [<c010477c>] do_IRQ+0x4d/0x5d
Jan  8 00:11:25 pdx user.warn kernel:  [<c010394b>] common_interrupt+0x23/0x28
Jan  8 00:11:25 pdx user.warn kernel:  [<c0106f3d>] default_idle+0x25/0x38
Jan  8 00:11:25 pdx user.warn kernel:  [<c010254b>] cpu_idle+0x37/0x5f
Jan  8 00:11:25 pdx user.warn kernel:  =======================
Jan  8 00:11:25 pdx user.warn kernel: ---[ end trace 4eb2e0ef5bc6569d ]---
Jan  8 00:11:25 pdx user.warn kernel: eth1: Transmit timeout, status  c   2b    0 80ff



Any other ideas?

Thanks.


