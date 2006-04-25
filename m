From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 6438] New: CISCO AIRONET 340 SERIES oops under
 PPC
Date: Tue, 25 Apr 2006 09:22:06 -0700
Message-ID: <20060425092206.4e463804.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:3468 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751577AbWDYQXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2006 12:23:43 -0400
To: Dominik Brodowski <linux@dominikbrodowski.net>,
	"John W. Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Tue, 25 Apr 2006 01:57:50 -0700
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 6438] New: CISCO AIRONET 340 SERIES oops under PPC


http://bugzilla.kernel.org/show_bug.cgi?id=6438

           Summary: CISCO AIRONET 340 SERIES oops under PPC
    Kernel Version: all under PPC
            Status: NEW
          Severity: blocking
             Owner: drivers_network-wireless@kernel-bugs.osdl.org
         Submitter: paszczus@gmail.com


Most recent kernel where this bug did not occur:
Distribution: PLD Linux
Hardware Environment: Apple PowerBook G3 with CISCO AIRONET 340 SERIES
Software Environment: gcc 3.3.x and 3.4.x
Problem Description:
Kernel oops while trying to load module yenta_socket while Airo card is inside
POMCIA slot. The problem is propably only on ppc, cause some other guy use that
card under x86 notebook and it works for him.
Steps to reproduce:
run pcmcia-cs service or modprobe yenta_socket. Oops is like that: 

cs: memory probe 0xfd000000-0xfdffffff:Machine check in kernel mode.
Caused by (from SRR1=49030): Transfer error ack signal
Oops: machine check, sig: 7 [#1]
NIP: CD02ACD0 LR: CD02ACA4 SP: CB3ADC70 REGS: cb3adbc0 TRAP: 0200    Not tainted
MSR: 00049030 EE: 1 PR: 0 FP: 0 ME: 1 IR/DR: 11
TASK = cb272c70[1636] 'pccardd' THREAD: cb3ac000
Last syscall: -1 
GPR00: 000000FF CB3ADC70 CB272C70 CD8AA000 00000014 00000070 00000002 CB3ADCEA 
GPR08: C4822B60 CD8AB000 00000040 00001000 22002248 1001F6AC 00000000 00000000 
GPR16: 00000000 00000000 00000000 10017B58 1000249C CBFB9E80 01000000 00000000 
GPR24: CB3ADCEA 00000021 00000002 CBD9582C 00000000 00000000 00000002 CB3ADCEA 
NIP [cd02acd0] pcmcia_read_cis_mem+0x184/0xffff64b4 [pcmcia_core]
LR [cd02aca4] pcmcia_read_cis_mem+0x158/0xffff64b4 [pcmcia_core]
Call trace:
 [cd02afe0] read_cis_cache+0x144/0xffff6164 [pcmcia_core]
 [cd02b648] pccard_get_next_tuple+0x7c/0xffff5a34 [pcmcia_core]
 [cd02b358] pccard_get_first_tuple+0x94/0xffff5d3c [pcmcia_core]
 [cd02cf98] pccard_validate_cis+0x94/0xffff40fc [pcmcia_core]
 [cd8af688] readable+0x88/0xff7cba00 [rsrc_nonstatic]
 [cd8af860] cis_readable+0xc8/0xff7cb868 [rsrc_nonstatic]
 [cd8afb30] do_mem_probe+0x1e0/0xff7cb6b0 [rsrc_nonstatic]
 [cd8afb78] inv_probe+0x30/0xff7cb4b8 [rsrc_nonstatic]
 [cd8afd20] validate_mem+0x128/0xff7cb408 [rsrc_nonstatic]
 [cd8afdf4] pcmcia_nonstatic_validate_mem+0xbc/0xff7cb2c8 [rsrc_nonstatic]
 [cd02d378] pcmcia_validate_mem+0x34/0xffff3cbc [pcmcia_core]
 [cda2ea44] pcmcia_card_add+0x28/0xfffb95e4 [pcmcia]
 [cda2f5a4] ds_event+0x80/0xfffb8adc [pcmcia]
 [cd0299d8] send_event+0x70/0xffff7698 [pcmcia_core]
 [cd029e6c] socket_insert+0xa8/0xffff723c [pcmcia_core]

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
