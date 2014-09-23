From: "Sharma, Karun" <karun.sharma@intel.com>
Subject: 3.17 kernel crash while loading IPoIB
Date: Tue, 23 Sep 2014 05:15:21 +0000
Message-ID: <637AD4DF2E595346BAB0DF8C46F3A2B003291F06@BGSMSX101.gar.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello:

I am facing an issue wherein kernel 3.17 crashes while loading IPoIB module. I guess the issue discussed in this thread (https://www.mail-archive.com/linux-rdma@vger.kernel.org/msg20963.html) is similar.

We were able to reproduce the issue with RC6 also. Here are the steps I followed:

I compiled and installed 3.17 kernel on top of RHEL 6.5. 
Then I changed rdma.conf to not load IPoIB (If I don't do this, the kernel crashes while booting and starting RDMA service.)
After the server comes up, I just did "modprobe ib_ipoib" and kernel crashes.
Please see below the kernel back trace.

Seeing the announcement, it looks like RC6 will be the last RC for 3.17 kernel. Will the release happen with this issue? Is there any workaround available for this issue?
I am not sure what mechanism/process is used to report issue to kernel community.

Regards
Karun


Kernel Stack back-trace:
--------------------------------------------------------------------------------
crash> bt
PID: 145    TASK: ffff88081a580d90  CPU: 3   COMMAND: "kworker/3:1"
#0 [ffff88081a587750] machine_kexec at ffffffff8103c5d9
#1 [ffff88081a5877a0] crash_kexec at ffffffff810d0ff8
#2 [ffff88081a587870] oops_end at ffffffff81007570
#3 [ffff88081a5878a0] no_context at ffffffff81046e5e
#4 [ffff88081a5878f0] __bad_area_nosemaphore at ffffffff8104704d
#5 [ffff88081a587940] bad_area_nosemaphore at ffffffff81047163
#6 [ffff88081a587950] __do_page_fault at ffffffff81047722
#7 [ffff88081a587a70] do_page_fault at ffffffff8104798c
#8 [ffff88081a587a80] page_fault at ffffffff815aad62
    [exception RIP: __dev_queue_xmit+894]
    RIP: ffffffff814e17be  RSP: ffff88081a587b38  RFLAGS: 00010282
    RAX: ffff88087c1679fe  RBX: ffff880812cc2500  RCX: 0000000000000044
    RDX: 0000000000000008  RSI: 0000000000000000  RDI: ffff88081a363a9c
    RBP: ffff88081a587b78   R8: 0000000000000000   R9: 0000000000000040
    R10: 0000000000000000  R11: 000000007c1679ff  R12: ffff88081a363a00
    R13: ffff880814f3e000  R14: ffff880809535600  R15: 0000000000000000
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
#9 [ffff88081a587b30] __dev_queue_xmit at ffffffff814e158b
#10 [ffff88081a587b80] dev_queue_xmit at ffffffff814e1930
#11 [ffff88081a587b90] neigh_connected_output at ffffffff814e81e8
#12 [ffff88081a587be0] ip6_finish_output2 at ffffffffa05ff8dd [ipv6]
#13 [ffff88081a587c40] ip6_finish_output at ffffffffa05ffe5f [ipv6]
#14 [ffff88081a587c60] ip6_output at ffffffffa05fff18 [ipv6]
#15 [ffff88081a587c90] ndisc_send_skb at ffffffffa06169a9 [ipv6]
#16 [ffff88081a587d40] ndisc_send_ns at ffffffffa0616bf6 [ipv6]
#17 [ffff88081a587db0] addrconf_dad_work at ffffffffa06076cb [ipv6]
#18 [ffff88081a587df0] process_one_work at ffffffff8106b23e
#19 [ffff88081a587e40] worker_thread at ffffffff8106b63f
#20 [ffff88081a587ec0] kthread at ffffffff8107041e
#21 [ffff88081a587f50] ret_from_fork at ffffffff815a92ac
---------------------------------------------------------------------------------

Regards,
Karun Sharma
