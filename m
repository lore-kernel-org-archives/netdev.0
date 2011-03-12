From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 30892] New: atl1c driver timeouts!
Date: Fri, 11 Mar 2011 16:15:43 -0800
Message-ID: <20110311161543.a6f0f557.akpm@linux-foundation.org>
References: <bug-30892-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	piroisl33t@gmail.com
To: Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33967 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752269Ab1CLAQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2011 19:16:10 -0500
In-Reply-To: <bug-30892-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

atl1c issue in 2.6.37.2.  It might be a regression - that's unclear?

On Thu, 10 Mar 2011 18:27:48 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=30892
> 
>            Summary: atl1c driver timeouts!
>            Product: Networking
>            Version: 2.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: piroisl33t@gmail.com
>         Regression: No
> 
> 
> I've got a fresh sabayon linux install, no policy routing or firewall (on my
> machine) and half of the networks I try to use, I cannot! I'm using kernel
> 2.6.37.2 on a toshiba L645D-4033, kernel is tainted due to use of FGLRX nothing
> else.
> 
> [  350.220773] atl1c 0000:08:00.0: atl1c: eth0 NIC Link is Up<100 Mbps Full
> Duplex>
> [  355.712251] ------------[ cut here ]------------
> [  355.712271] WARNING: at net/sched/sch_generic.c:258
> dev_watchdog+0x142/0x1dc()
> [  355.712278] Hardware name: Satellite L645D
> [  355.712284] NETDEV WATCHDOG: eth0 (atl1c): transmit queue 0 timed out
> [  355.712289] Modules linked in: rtl8192ce rtl8192c_common rtlwifi mac80211
> compat cfg80211 snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq
> snd_seq_device snd_pcm_oss snd_mixer_oss ipv6 snd_hda_codec_conexant
> snd_hda_intel snd_hda_codec snd_hwdep snd_pcm snd_timer fglrx(P) uvcvideo
> videodev v4l1_compat v4l2_compat_ioctl32 snd i2c_piix4 snd_page_alloc i2c_core
> tpm_tis edac_core tpm atl1c k10temp tpm_bios shpchp pci_hotplug joydev pcspkr
> sparse_keymap serio_raw video output xts gf128mul iscsi_tcp tg3 e1000
> scsi_wait_scan sl811_hcd ohci_hcd uhci_hcd ehci_hcd sx8 imm parport pata_pcmcia
> pcmcia
> [  355.712377] Pid: 0, comm: kworker/0:0 Tainted: P            2.6.37-sabayon
> #1
> [  355.712384] Call Trace:
> [  355.712389]  <IRQ>  [<ffffffff8103da7e>] warn_slowpath_common+0x80/0x98
> [  355.712410]  [<ffffffff8103db2a>] warn_slowpath_fmt+0x41/0x43
> [  355.712420]  [<ffffffff817aa8c6>] dev_watchdog+0x142/0x1dc
> [  355.712431]  [<ffffffff81047d00>] run_timer_softirq+0x16b/0x1f8
> [  355.712440]  [<ffffffff817aa784>] ? dev_watchdog+0x0/0x1dc
> [  355.712449]  [<ffffffff81042d3c>] __do_softirq+0x8f/0x120
> [  355.712458]  [<ffffffff81002e6c>] call_softirq+0x1c/0x28
> [  355.712466]  [<ffffffff810049ff>] do_softirq+0x33/0x68
> [  355.712473]  [<ffffffff81042bd3>] irq_exit+0x36/0x78
> [  355.712481]  [<ffffffff810040e5>] do_IRQ+0xa3/0xba
> [  355.712489]  [<ffffffff81873253>] ret_from_intr+0x0/0xa
> [  355.712494]  <EOI>  [<ffffffff810095a8>] ? default_idle+0x24/0x39
> [  355.712507]  [<ffffffff81009708>] c1e_idle+0xcd/0xea
> [  355.712515]  [<ffffffff810012d8>] cpu_idle+0x5a/0x91
> [  355.712524]  [<ffffffff8186b0e4>] start_secondary+0x1a6/0x1aa
> [  355.712531] ---[ end trace 9c9405f36c466cda ]---
> [  355.733614] atl1c 0000:08:00.0: irq 43 for MSI/MSI-X
> [  355.733835] atl1c 0000:08:00.0: atl1c: eth0 NIC Link is Up<100 Mbps Full
> Duplex>
> 
> I can jack into a network, sometimes nothing happens. I need to ifconfig eth0
> down then ifconfig eth0 up and it picks up. After I get a connection I get a
> solid connection for approximately 60 seconds then It shows I'm connected with
> IP address but I cannot access anything!  This ethernet jack is next to useless
> at work or at college. It works fine on my small home network.
> 
> I believe that this may be related to another bug (BUG 14958), but I have no
> proof, just similar results and issues.
> 

