From: Felipe Wilhelms Damasio - Taghos <felipewd@taghos.com.br>
Subject: Task blocked on a ext4 partition
Date: Mon, 15 Aug 2011 17:51:13 -0300
Message-ID: <4E4986C1.6090404@taghos.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway07.websitewelcome.com ([69.56.176.23]:58809 "HELO
	gateway07.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751351Ab1HOVAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 17:00:53 -0400
Received: from gator1481.hostgator.com (gator1481.hostgator.com [184.173.199.228])
	by ham01.websitewelcome.com (Postfix) with ESMTP id 18E6C8DC83881
	for <netdev@vger.kernel.org>; Mon, 15 Aug 2011 15:51:16 -0500 (CDT)
Received: from [201.21.231.127] (port=6505 helo=Felipe-Damasio.local)
	by gator1481.hostgator.com with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.69)
	(envelope-from <felipewd@taghos.com.br>)
	id 1Qt47u-00045c-S4
	for netdev@vger.kernel.org; Mon, 15 Aug 2011 15:51:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    Hi All,

    I'm using a mmap-based file sharing system on an ext4 partition with
epoll on an ISP.

    Last night the system got a significant slow down, and dmesg showed a
lot of these:

INFO: task fshare:23798 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
fshare         D 0000000000000007     0 23798  17719 0x00000000
 ffff88018af29648 0000000000000082 0000000000012500 ffff88018af29fd8
 ffff88018af29fd8 ffff88042d371a40 0000000000012500 0000000000012500
 0000000000012500 ffff88042d371a40 ffff88042e0d5550 ffff88042d371ce8
Call Trace:
 [<ffffffff8102e155>] ? enqueue_entity+0x11f/0x127
 [<ffffffff8151c9c7>] schedule_timeout+0x22/0xda
 [<ffffffff81035288>] ? get_parent_ip+0x11/0x41
 [<ffffffff8103541e>] ? sub_preempt_count+0x92/0xa5
 [<ffffffff8151c0fc>] wait_for_common+0xca/0x140
 [<ffffffff81037bd1>] ? default_wake_function+0x0/0xf
 [<ffffffff8151c20c>] wait_for_completion+0x18/0x1a
 [<ffffffff810df950>] writeback_inodes_sb+0xb4/0xbf
 [<ffffffff810dfe60>] writeback_inodes_sb_if_idle+0x37/0x4b
 [<ffffffff81124b34>] ext4_da_write_begin+0xa5/0x1e6
 [<ffffffff8108fdab>] ? find_lock_page+0x1e/0x5d
 [<ffffffff8111e263>] ext4_page_mkwrite+0x117/0x168
 [<ffffffff810a316b>] __do_fault+0x125/0x388
 [<ffffffff81035288>] ? get_parent_ip+0x11/0x41
 [<ffffffff810a52d6>] handle_mm_fault+0x429/0x838
 [<ffffffff8102211e>] do_page_fault+0x222/0x239
 [<ffffffff8151e44f>] page_fault+0x1f/0x30
 [<ffffffff8122e1ed>] ? copy_user_generic_string+0x2d/0x40
 [<ffffffff81457020>] ? memcpy_toiovec+0x37/0x66
 [<ffffffff814578ee>] skb_copy_datagram_iovec+0x4b/0x1cf
 [<ffffffff81035288>] ? get_parent_ip+0x11/0x41
 [<ffffffff81494fb9>] tcp_recvmsg+0x746/0xa62
 [<ffffffff814b09ed>] inet_recvmsg+0x5a/0x78
 [<ffffffff8144d89a>] __sock_recvmsg+0x7b/0x87
 [<ffffffff8144db5b>] sock_recvmsg+0xa6/0xbf
 [<ffffffff814922e2>] ? tcp_poll+0x2b/0x180
 [<ffffffff810c584c>] ? fget_light+0x93/0xa9
 [<ffffffff8144dcd9>] ? sockfd_lookup_light+0x1b/0x53
 [<ffffffff8144f291>] sys_recvfrom+0xb0/0xfe
 [<ffffffff810f11c5>] ? sys_epoll_wait+0x28f/0x2a7
 [<ffffffff81002a2b>] system_call_fastpath+0x16/0x1b

    Do you have any idea what could cause this?

    The kernel I'm using is 2.6.35.13. Is there any other info I can provide
to help track this down?

    Cheers,

-- 
Felipe Wilhelms Damasio

TAGHOS - Tecnologia
Rua Prof. Alvaro Alvim, 211
Porto Alegre - RS - (51) 3239-3180
www.taghos.com.br
