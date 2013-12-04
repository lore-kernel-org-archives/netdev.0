From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net] net: neighbour: add neighbour dead check for neigh_timer_handler()
Date: Wed, 4 Dec 2013 09:36:37 +0800
Message-ID: <529E8725.7000306@huawei.com>
References: <529DE13D.2070509@huawei.com> <20131203150307.GB8920@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"Joe Perches" <joe@perches.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:39783 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754164Ab3LDBja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 20:39:30 -0500
In-Reply-To: <20131203150307.GB8920@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/3 23:03, Hannes Frederic Sowa wrote:
> Hi Ding!
> 
> On Tue, Dec 03, 2013 at 09:48:45PM +0800, Ding Tianhong wrote:
>> I have met the oops in Suse11 SP2, the kernel is 2.6.32.59-0.7-default:
>>
>> [64306.089036] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
>> [64306.089343] IP: [<ffffffff812f8e36>] neigh_timer_handler+0x116/0x3b0
>> [64306.089535] PGD 0
>> [64306.089706] Oops: 0000 [#1] SMP
>> [64306.089935] last sysfs file: /sys/devices/pci0000:00/0000:00:03.0/0000:02:00.0/host0/target0:1:0/0:1:0:0/scsi_generic/sg0/dev
>> [64306.090142] Die func triggered, code:1
>> [64306.090147] CPU 1
>> [64306.090258] Supported: Yes, External
>> [64306.090262] Pid: 58359, comm: socknal_cd04 Tainted: P          N  2.6.32.59-0.7-default #1 T3500 G3
>> [64306.090266] RIP: 0010:[<ffffffff812f8e36>]  [<ffffffff812f8e36>] neigh_timer_handler+0x116/0x3b0
>> [64306.090272] RSP: 0018:ffff880c273499d8  EFLAGS: 00010206
>> [64306.090275] RAX: 0000000000000000 RBX: ffff8801cddf1500 RCX: ffff8801cddf14f2
>> [64306.090278] RDX: 0000000000000000 RSI: ffff8805e40d3a28 RDI: ffff8801cddf1500
>> [64306.090281] RBP: ffff8805e40d3a28 R08: ffff8801cddf1530 R09: ffff880c27349b17
>> [64306.090284] R10: 000000000000000e R11: ffffffff812f8e22 R12: ffff880185c0e840
>> [64306.090287] R13: 0000000000000000 R14: ffff8805e40d3a60 R15: 0000000003484560
>> [64306.090291] FS:  00007f081210e700(0000) GS:ffff880036420000(0000) knlGS:0000000000000000
>> [64306.090295] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> [64306.090297] CR2: 0000000000000008 CR3: 0000000001804000 CR4: 00000000000406e0
>> [64306.090301] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> [64306.090304] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> [64306.090308] Process socknal_cd04 (pid: 58359, threadinfo ffff880c27348000, task ffff880c25d02300)
>> [64306.090310] Stack:
>> [64306.090426]  ffffffff8131f8e0 0000000000000003 ffff8801c189eb40 000000000000000a
>> [64306.090437] <0> ffffffff00000000 0000000000000002 ffff880c27349a30 ffffffffa304790c
>> [64306.090444] <0> 0000000000000246 000051010a010000 ffffffff81318357 31312d3300007fff
>> [64306.090450] <0> ffff880c27349bb8 0248456003484560 ffff8801c189eb40 ffffffff81869300
>> [64306.090456] <0> ffff880185c0e840 ffff8801cddf1514 ffff8805e40d3a28 00000000000000d0
>> [64306.090464] Call Trace:
> 
> Do you still have the full output of the panic including the Code section
> and could post it here?
> 
> Greetings,
> 
>   Hannes
> 

ok, the bt -t is:

PID: 58359  TASK: ffff880c25d02300  CPU: 1   COMMAND: "socknal_cd04"
 #0 [ffff880c273496e0] machine_kexec at ffffffff810203a2
 #1 [ffff880c27349730] crash_kexec at ffffffff81085c80
 #2 [ffff880c27349800] oops_end at ffffffff81395c80
 #3 [ffff880c27349820] no_context at ffffffff8102d0a7
 #4 [ffff880c27349860] __bad_area_nosemaphore at ffffffff8102d365
 #5 [ffff880c27349888] vsnprintf at fffffff
 #6 [ffff880c27349958] neigh_timer_handler at ffffffff812f8e22
 #7 [ffff880c273499a8] neigh_timer_handler at ffffffff812f8e36
 #8 [ffff880c273499d8] ip_queue_xmit at ffffffff8131f8e0
 #9 [ffff880c27349a88] tcp_transmit_skb at ffffffff8133398b
#10 [ffff880c27349af8] tcp_connect at ffffffff813355c6
caitao 00137488(c00137488) 2013-11-19 10:27:31
#11 [ffff880c27349b28] tcp_v4_connect at ffffffff8133a85a
#12 [ffff880c27349bf8] inet_stream_connect at ffffffff813490a8
#13 [ffff880c27349c08] libcfs_debug_vmsg2 at ffffffffa0acd29c
#14 [ffff880c27349c78] libcfs_sock_connect at ffffffffa0ac3d04
#15 [ffff880c27349cc8] dequeue_task_fair at ffffffff81040445


and the memory for struct neighbour is:

crash>  neighbour ffff8801cddf1500
struct neighbour {
  next = 0x4037ad30000045, 
  tbl = 0x2484560013d0640, 
  parms = 0xdc03ff7f03484560, 
  dev = 0x23351d86, 
  used = 170277469553264, 
  confirmed = 649366077121561602, 
  updated = 0, 
  flags = 0 '\000', 
  nud_state = 0 '\000', 
  type = 0 '\000', 
  dead = 0 '\000', 
  probes = {
    counter = 0
  }, 
  lock = {
    raw_lock = {
      lock = 16777216
    }
  }, 
  ha = "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\0
00", 
  hh = 0x0, 
  refcnt = {
    counter = 0
  }, 
  output = 0, 
  arp_queue = {
    next = 0x10002, 
    prev = 0x0, 
    qlen = 1, 
    lock = {
      raw_lock = {
        slock = 0
      }
    }
  }, 
  timer = {
    entry = {
      next = 0x0, 
      prev = 0x0
    }, 
    expires = 0, 
    function = 0, 
    data = 0, 
    base = 0x0, 
    start_site = 0x0, 
    start_comm = "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000", 
    start_pid = 0
  }, 
  ops = 0x0, 
  primary_key = 0xffff8801cddf15f0 ""
}

Regards
Ding

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> .
> 
