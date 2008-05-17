From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10737] New: pktgen procfs problem
Date: Sat, 17 May 2008 14:10:36 -0700
Message-ID: <20080517141036.d8f3c768.akpm@linux-foundation.org>
References: <bug-10737-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, devzero@web.de,
	Robert Olsson <robert.olsson@its.uu.se>,
	"Denis V. Lunev" <den@openvz.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33734 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759246AbYEQVLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 May 2008 17:11:19 -0400
In-Reply-To: <bug-10737-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 17 May 2008 13:59:25 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10737
> 
>            Summary: pktgen procfs problem
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.26-rc2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: devzero@web.de
> 
> 
> Latest working kernel version: n/a
> Earliest failing kernel version: 2.6.26-rc2
> Distribution: suse 10.1
> Hardware Environment: p4 + gigabyte i915g MoBo
> Software Environment:
> Problem Description:
> pktgen module ocaasional seems to leak procfs entry
> 
> May 18 00:00:34 test kernel: [ 2663.373955] pktgen v2.69: Packet Generator for
> packet performance testing.
> May 18 00:00:34 test kernel: [ 2663.384819] remove_proc_entry: removing
> non-empty directory 'net/pktgen', leaking at least 'kpktgend_1'

^^

Possibly we were always leaking this procfs entry, and newly-added
procfs diagnostics are now detecting it.


> May 18 00:00:34 test kernel: [ 2663.384819] ------------[ cut here
> ]------------
> May 18 00:00:34 test kernel: [ 2663.384819] WARNING: at fs/proc/generic.c:799
> remove_proc_entry+0x110/0x12d()
> May 18 00:00:34 test kernel: [ 2663.384819] Modules linked in: pktgen(-) ip_gre
> lzo lzo_decompress lzo_compress tgr192 cts seed camellia fcrypt anubis cast6
> cast5 ccm gcm ctr lrw gf128mul aes_i586 aes_generic blowfish md4 cbc ecb
> sha1_generic aead 8250_accent 8250_exar_st16c554 8250_fourport 8250_boca
> 8250_hub6 ovcamchip i2c_core guillemot adi a3d cobra gameport parkbd
> deadline_iosched capifs ar7part mtd eql ide_generic siimage aec62xx trm290
> alim15x3 hpt34x hpt366 cmd64x cmd640 piix rz1000 slc90e66 jmicron cs5535 cs5530
> cs5520 sc1200 triflex ide_pci_generic atiixp pdc202xx_old pdc202xx_new tc86c001
> opti621 ns87415 cy82c693 amd74xx sis5513 via82cxxx serverworks it821x it8213
> ide_core eni suni zatm uPD98402 atm non_fatal p4_clockmod speedstep_lib
> freq_table decnet crypto_blkcipher sctp libcrc32c sunrpc psmouse ipv6 vboxdrv
> mousedev e100 mii intel_agp agpgart usbcore parport_pc parport megaraid_mbox
> megaraid_mm sd_mod scsi_mod [last unloaded: ax25]
> May 18 00:00:34 test kernel: [ 2663.384819] Pid: 31183, comm: modprobe Tainted:
> G        W 2.6.26-rc2-git5 #2
> May 18 00:00:34 test kernel: [ 2663.384819]  [<c0122aae>]
> warn_on_slowpath+0x41/0x6c
> May 18 00:00:34 test kernel: [ 2663.384819]  [<c0135c32>] ? up+0x2b/0x2f
> May 18 00:00:34 test kernel: [ 2663.384819]  [<c0122f99>] ?
> release_console_sem+0x184/0x18c
> May 18 00:00:34 test kernel: [ 2663.384819]  [<c02f5f3e>] ?
> schedule_timeout+0x16/0x8b
> May 18 00:00:34 test kernel: [ 2663.384819]  [<c0123417>] ? printk+0x15/0x17
> May 18 00:00:34 test kernel: [ 2663.384819]  [<c01a9a5a>]
> remove_proc_entry+0x110/0x12d
> May 18 00:00:34 test kernel: [ 2663.384819]  [<c01ac70b>]
> proc_net_remove+0xf/0x11
> May 18 00:00:34 test kernel: [ 2663.384819]  [<f8a47be7>] pg_cleanup+0x5f/0x90
> [pktgen]
> May 18 00:00:34 test kernel: [ 2663.384819]  [<c0140899>]
> sys_delete_module+0x18e/0x1d9
> May 18 00:00:34 test kernel: [ 2663.384819]  [<c016813d>] ?
> remove_vma+0x41/0x47
> May 18 00:00:34 test kernel: [ 2663.384819]  [<c0168aa7>] ?
> do_munmap+0x17d/0x197
> May 18 00:00:34 test kernel: [ 2663.384819]  [<c0103811>]
> sysenter_past_esp+0x6a/0x91
> May 18 00:00:34 test kernel: [ 2663.384819]  [<c02f0000>] ?
> pcibios_setup+0xa8/0x2a0
> May 18 00:00:34 test kernel: [ 2663.384819]  =======================
> May 18 00:00:34 test kernel: [ 2663.384819] ---[ end trace 4351c3133409518a
> ]---
> 
> 
> Steps to reproduce: not sure yet, but i saw this while doing some module
> load/unload  regression test.
> 

