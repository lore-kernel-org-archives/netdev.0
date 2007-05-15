From: Badari Pulavarty <pbadari@us.ibm.com>
Subject: select(0, ..) is valid ?
Date: Tue, 15 May 2007 10:29:18 -0700
Message-ID: <1179250159.2836.117.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <clameter@sgi.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:43544 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755657AbXEOR2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 13:28:37 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Is select(0, ..) is a valid operation ?

I see that there is no check to prevent this or return
success early, without doing any work. Do we need one ?

slub code is complaining that we are doing kmalloc(0).

Thanks,
Badari

------------[ cut here ]------------
Badness at include/linux/slub_def.h:88
Call Trace:
[c0000001e4eb7640] [c00000000000e650] .show_stack+0x68/0x1b0
(unreliable)
[c0000001e4eb76e0] [c00000000029b854] .report_bug+0x94/0xe8
[c0000001e4eb7770] [c0000000000219f0] .program_check_exception
+0x12c/0x568
[c0000001e4eb77f0] [c000000000004a84] program_check_common+0x104/0x180
--- Exception: 700 at .get_slab+0x4c/0x234
    LR = .__kmalloc+0x24/0xc4
[c0000001e4eb7ae0] [c0000001e4eb7b80] 0xc0000001e4eb7b80 (unreliable)
[c0000001e4eb7b80] [c0000000000a7ff0] .__kmalloc+0x24/0xc4
[c0000001e4eb7c10] [c0000000000ea720] .compat_core_sys_select+0x90/0x240
[c0000001e4eb7d00] [c0000000000ec3a4] .compat_sys_select+0xb0/0x190
[c0000001e4eb7dc0] [c000000000014944] .ppc32_select+0x14/0x28
[c0000001e4eb7e30] [c00000000000872c] syscall_exit+0x0/0x40


