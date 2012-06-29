From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [BUG, regression, bisected] Marvell 88E8055 NIC (sky2) fails to
 detect link after resume from S3
Date: Fri, 29 Jun 2012 16:46:10 -0700
Message-ID: <20120629164610.1f343434@nehalam.linuxnetplumber.net>
References: <op.wgon84tw16tawo@esprimo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Michal Zatloukal" <myxal.mxl@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57780 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751971Ab2F3Aqu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2012 20:46:50 -0400
In-Reply-To: <op.wgon84tw16tawo@esprimo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Jun 2012 23:20:54 +0200
"Michal Zatloukal" <myxal.mxl@gmail.com> wrote:

> Hello.
> 
> I'm the reporter of Ubuntu bug 1007841
> <https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1007841> and would
> like to bring attention to it here, since it's in upstream kernel as well.
> 
> The gist of the problem is, since around 3.2 (I haven't kept up-to-date
> and mostly used 2.6.35 on the machine), whenever I wake up the laptop from
> S3 by opening the lid, the NIC loses link detection and it's reported as
> always down. Relevant dmesg output (suspend-resume twice, then attempted
> modprobe -r and modprobe, also twice):
> 
> [    3.351407] sky2: driver version 1.30
> [    3.351460] sky2 0000:04:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ  
> 17
> [    3.351477] sky2 0000:04:00.0: setting latency timer to 64
> [    3.351510] sky2 0000:04:00.0: Yukon-2 EC Ultra chip revision 3
> [    3.351610] sky2 0000:04:00.0: irq 44 for MSI/MSI-X
> [    3.360722] sky2 0000:04:00.0: eth0: addr 00:a0:d1:cd:97:e5
> [   19.233940] sky2 0000:04:00.0: eth0: enabling interface
> [   21.595880] sky2 0000:04:00.0: eth0: Link is up at 1000 Mbps, full  
> duplex, flow control both
> [ 2547.761596] sky2 0000:04:00.0: eth0: disabling interface
> [ 2551.220040] PM: late suspend of drv:sky2 dev:0000:04:00.0 complete  
> after 155.989 msecs
> [ 2551.532056] sky2 0000:04:00.0: Refused to change power state, currently  
> in D3
> [ 2551.532070] sky2 0000:04:00.0: restoring config space at offset 0xf  
> (was 0xffffffff, writing 0x10a)
> [ 2551.532074] sky2 0000:04:00.0: restoring config space at offset 0xe  
> (was 0xffffffff, writing 0x0)
> [ 2551.532078] sky2 0000:04:00.0: restoring config space at offset 0xd  
> (was 0xffffffff, writing 0x48)
> [ 2551.532082] sky2 0000:04:00.0: restoring config space at offset 0xc  
> (was 0xffffffff, writing 0x0)
> [ 2551.532086] sky2 0000:04:00.0: restoring config space at offset 0xb  
> (was 0xffffffff, writing 0x110f1734)
> [ 2551.532090] sky2 0000:04:00.0: restoring config space at offset 0xa  
> (was 0xffffffff, writing 0x0)
> [ 2551.532094] sky2 0000:04:00.0: restoring config space at offset 0x9  
> (was 0xffffffff, writing 0x0)
> [ 2551.532099] sky2 0000:04:00.0: restoring config space at offset 0x8  
> (was 0xffffffff, writing 0x0)
> [ 2551.532103] sky2 0000:04:00.0: restoring config space at offset 0x7  
> (was 0xffffffff, writing 0x0)
> [ 2551.532107] sky2 0000:04:00.0: restoring config space at offset 0x6  
> (was 0xffffffff, writing 0x3001)
> [ 2551.532111] sky2 0000:04:00.0: restoring config space at offset 0x5  
> (was 0xffffffff, writing 0x0)
> [ 2551.532115] sky2 0000:04:00.0: restoring config space at offset 0x4  
> (was 0xffffffff, writing 0xf8000004)
> [ 2551.532119] sky2 0000:04:00.0: restoring config space at offset 0x3  
> (was 0xffffffff, writing 0x10)
> [ 2551.532123] sky2 0000:04:00.0: restoring config space at offset 0x2  
> (was 0xffffffff, writing 0x2000014)
> [ 2551.532127] sky2 0000:04:00.0: restoring config space at offset 0x1  
> (was 0xffffffff, writing 0x100507)
> [ 2551.532132] sky2 0000:04:00.0: restoring config space at offset 0x0  
> (was 0xffffffff, writing 0x436311ab)
> [ 2551.537226] sky2 0000:04:00.0: ignoring stuck error report bit
> [ 2553.916819] sky2 0000:04:00.0: eth0: phy I/O error
> [ 2553.916826] sky2 0000:04:00.0: eth0: phy I/O error
> [ 2553.916830] sky2 0000:04:00.0: eth0: phy I/O error
> [ 2553.916833] sky2 0000:04:00.0: eth0: phy I/O error
> [ 2553.916836] sky2 0000:04:00.0: eth0: phy I/O error
> [ 2553.916839] sky2 0000:04:00.0: eth0: phy I/O error
> [ 2553.916843] sky2 0000:04:00.0: eth0: phy I/O error
> [ 2553.916846] sky2 0000:04:00.0: eth0: phy I/O error
> [ 2553.916849] sky2 0000:04:00.0: eth0: phy I/O error
> [ 2553.916852] sky2 0000:04:00.0: eth0: phy I/O error
> [ 2553.916855] sky2 0000:04:00.0: eth0: phy I/O error
> [ 2553.916859] sky2 0000:04:00.0: eth0: phy I/O error
> [ 2553.916862] sky2 0000:04:00.0: eth0: phy I/O error
> [ 2553.916865] sky2 0000:04:00.0: eth0: phy I/O error
> [ 2553.916868] sky2 0000:04:00.0: eth0: phy I/O error
> [ 2553.916871] sky2 0000:04:00.0: eth0: phy I/O error
> [ 2553.916875] sky2 0000:04:00.0: eth0: phy I/O error
> [ 2553.917001] sky2 0000:04:00.0: eth0: enabling interface
> [ 2601.941407] sky2 0000:04:00.0: eth0: disabling interface
> [ 2601.941443] sky2 0000:04:00.0: eth0: phy I/O error
> [ 2601.941452] sky2 0000:04:00.0: eth0: phy I/O error
> [ 2601.941459] sky2 0000:04:00.0: eth0: phy I/O error
> [ 2601.941466] sky2 0000:04:00.0: eth0: phy I/O error
> [ 2601.941473] sky2 0000:04:00.0: eth0: phy I/O error
> [ 2601.941480] sky2 0000:04:00.0: eth0: phy I/O error
> [ 2601.941487] sky2 0000:04:00.0: eth0: phy I/O error
> [ 2601.941494] sky2 0000:04:00.0: eth0: phy I/O error
> [ 2601.941501] sky2 0000:04:00.0: eth0: phy I/O error
> [ 2601.968125] sky2 0000:04:00.0: PCI INT A disabled
> [ 2608.679627] sky2: driver version 1.30
> [ 2608.679726] sky2 0000:04:00.0: enabling device (0000 -> 0003)
> [ 2608.679746] sky2 0000:04:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ  
> 17
> [ 2608.679776] sky2 0000:04:00.0: setting latency timer to 64
> [ 2608.679827] sky2 0000:04:00.0: unsupported chip type 0xff
> [ 2608.679851] sky2 0000:04:00.0: PCI INT A disabled
> [ 2608.679866] sky2: probe of 0000:04:00.0 failed with error -95
> [26940.138170] sky2: driver version 1.30
> [26940.138220] sky2 0000:04:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ  
> 17
> [26940.138236] sky2 0000:04:00.0: setting latency timer to 64
> [26940.138258] sky2 0000:04:00.0: unsupported chip type 0xff
> [26940.138268] sky2 0000:04:00.0: PCI INT A disabled
> [26940.138273] sky2: probe of 0000:04:00.0 failed with error -95
> 
> I have done bisection and have found the offending commit to be:
> 
> commit 7afe1845dd1e7c90828c942daed7e57ffa7c38d6
> Author: Sameer Nanda <snanda@chromium.org>
> Date: Mon Jul 25 17:13:29 2011 -0700
> init: skip calibration delay if previously done
> For each CPU, do the calibration delay only once.  For subsequent calls,
> use the cached per-CPU value of loops_per_jiffy.
> 
> This saves about 200ms of resume time on dual core Intel Atom N5xx based
> systems.  This helps bring down the kernel resume time on such systems
>    from about 500ms to about 300ms.
> --- end commit info ---
> 
> My uneducated guess is that by making the resume from S3 shorter, the
> driver catches the hardware with its pants down and freaks out.
> You can find all details/files (dmesg, lspci, dmidecode, config...)
> collected by apport in the ubuntu bug linked above. Let me know if I
> should supply any more info.
> Note: Please CC me into replies, I'm not subscribed. Thank you.
> 
> Best Regards,
> Michal Zatloukal

Is ubuntu still doing the stupid rmmod on suspend?

Looks like PCI power management has turned the chip off (that is why it
keeps reading ff to all requests).
