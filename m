From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: 2.6.25-rc8-mm2: FIX kmalloc-2048 (was Re: 2.6.25-rc8-mm2: IP:
	[<ffffffff802868f9>] __kmalloc+0x69/0x110)
Date: Mon, 14 Apr 2008 23:56:13 +0400
Message-ID: <20080414195613.GA4772@martell.zuzino.mipt.ru>
References: <20080410203354.f0a6f464.akpm@linux-foundation.org> <20080413204422.GA5136@martell.zuzino.mipt.ru> <84144f020804140901p1c076fd2q73e3effe7cd96da3@mail.gmail.com> <Pine.LNX.4.64.0804141050550.6296@schroedinger.engr.sgi.com> <20080414183221.GA5234@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:61974 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757813AbYDNUAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 16:00:47 -0400
Received: by fg-out-1718.google.com with SMTP id l27so1684714fgb.17
        for <netdev@vger.kernel.org>; Mon, 14 Apr 2008 13:00:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080414183221.GA5234@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I can reproduce semi-reliably (by kernel standards) corruption in
kmalloc-2048. No idea if this can explain all "struct file" related
oopses I saw, or SLUB free pointer corruption Pekka and Christoph are
looking into.

8139too and atl1 drivers are in use. 8139too connects to outer world,
atl1 -- to laptop collecting netconsole logs. However, I never managed to
collect late oopses with netconsole even if init scripts which are
shutting down interfaces are disabled. :-(



Transcribed from photo:

8000 flags=0x8000000000002082
INFO: Object 0xffff81017ff9d2d0 @offset=21200 fp=0xffff81017ff9ca88

Bytes b4 0xffff81017ff9d2c0:  62 ea ff ff 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a
  Object 0xffff81017ff9d2d0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b
  Object 0xffff81017ff9d2e0:  6b 6b 00 18 f3 a2 9f 90 00 1b 38 af 22 49 08 00
  Object 0xffff81017ff9d2f0:  45 10 00 4c ff 59 40 00 40 11 86 ac c0 a8 00 2a
  Object 0xffff81017ff9d300:  50 fa a2 be 91 43 00 7b 00 38 54 d4 23 00 00 00
  Object 0xffff81017ff9d310:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  Object 0xffff81017ff9d320:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  Object 0xffff81017ff9d330:  00 00 00 00 4c ff 10 44 74 7f 6f 9d e4 c8 a2 4f
  Object 0xffff81017ff9d340:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 Redzone 0xffff81017ff9dad0:  bb bb bb bb bb bb bb bb
 Padding 0xffff81017ff9db10:  5a 5a 5a 5a 5a 5a 5a 5a

 Pid: 6168, comm: reboot Not tainted 2.6.25-rc8-mm2 #28

 Call Trace:
	print_trailer
	check_bytes_and_report
	check_object
	__free_slab
	discard_slab
	__slab_free
	? skb_release_data
	kfree
	? skb_release_data
	skb_release_all
	__kfre_skb
	kfree_skb
	atl1_clean_rx_ring
	atl1_down
	atl1_close
	dev_close
	dev_change_flags
	devinet_ioctl
	? trace_hardirqs_on
	inet_ioctl
	sock_ioctl
	vfs_ioctl
	do_vfs_ioctl
	sys_ioctl
	system_call_after_swapgs

FIX kmalloc-2048: Restoring 0xffff81017ff9d2e2-0xffff81017ff9d8d9=0x6b

