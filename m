From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [net/bpf] 3051bf36c2 BUG: unable to handle kernel paging request at
 0000a7cf
Date: Wed, 1 Mar 2017 20:54:26 +0800
Message-ID: <20170301125426.l4nf65rx4wahohyl@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="jl252dk3czobalyd"
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:28928 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751248AbdCAM45 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Mar 2017 07:56:57 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--jl252dk3czobalyd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi all,

Is it BPF triggering BUGs all over the places?

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master

commit 3051bf36c25d5153051704291782f8d44e744d36
Merge: 1e74a2e 005c349
Author:     Linus Torvalds <torvalds@linux-foundation.org>
AuthorDate: Wed Feb 22 10:15:09 2017 -0800
Commit:     Linus Torvalds <torvalds@linux-foundation.org>
CommitDate: Wed Feb 22 10:15:09 2017 -0800

     Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next
     
     Pull networking updates from David Miller:
      "Highlights:
     
        1) Support TX_RING in AF_PACKET TPACKET_V3 mode, from Sowmini
           Varadhan.
     
        2) Simplify classifier state on sk_buff in order to shrink it a bit.
           From Willem de Bruijn.
     
        3) Introduce SIPHASH and it's usage for secure sequence numbers and
           syncookies. From Jason A. Donenfeld.
     
        4) Reduce CPU usage for ICMP replies we are going to limit or
           suppress, from Jesper Dangaard Brouer.
     
        5) Introduce Shared Memory Communications socket layer, from Ursula
           Braun.
     
        6) Add RACK loss detection and allow it to actually trigger fast
           recovery instead of just assisting after other algorithms have
           triggered it. From Yuchung Cheng.
     
        7) Add xmit_more and BQL support to mvneta driver, from Simon Guinot.
     
        8) skb_cow_data avoidance in esp4 and esp6, from Steffen Klassert.
     
        9) Export MPLS packet stats via netlink, from Robert Shearman.
     
       10) Significantly improve inet port bind conflict handling, especially
           when an application is restarted and changes it's setting of
           reuseport. From Josef Bacik.
     
       11) Implement TX batching in vhost_net, from Jason Wang.
     
       12) Extend the dummy device so that VF (virtual function) features,
           such as configuration, can be more easily tested. From Phil
           Sutter.
     
       13) Avoid two atomic ops per page on x86 in bnx2x driver, from Eric
           Dumazet.
     
       14) Add new bpf MAP, implementing a longest prefix match trie. From
           Daniel Mack.
     
       15) Packet sample offloading support in mlxsw driver, from Yotam Gigi.
     
       16) Add new aquantia driver, from David VomLehn.
     
       17) Add bpf tracepoints, from Daniel Borkmann.
     
       18) Add support for port mirroring to b53 and bcm_sf2 drivers, from
           Florian Fainelli.
     
       19) Remove custom busy polling in many drivers, it is done in the core
           networking since 4.5 times. From Eric Dumazet.
     
       20) Support XDP adjust_head in virtio_net, from John Fastabend.
     
       21) Fix several major holes in neighbour entry confirmation, from
           Julian Anastasov.
     
       22) Add XDP support to bnxt_en driver, from Michael Chan.
     
       23) VXLAN offloads for enic driver, from Govindarajulu Varadarajan.
     
       24) Add IPVTAP driver (IP-VLAN based tap driver) from Sainath Grandhi.
     
       25) Support GRO in IPSEC protocols, from Steffen Klassert"
     
     * git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next: (1764 commits)
       Revert "ath10k: Search SMBIOS for OEM board file extension"
       net: socket: fix recvmmsg not returning error from sock_error
       bnxt_en: use eth_hw_addr_random()
       bpf: fix unlocking of jited image when module ronx not set
       arch: add ARCH_HAS_SET_MEMORY config
       net: napi_watchdog() can use napi_schedule_irqoff()
       tcp: Revert "tcp: tcp_probe: use spin_lock_bh()"
       net/hsr: use eth_hw_addr_random()
       net: mvpp2: enable building on 64-bit platforms
       net: mvpp2: switch to build_skb() in the RX path
       net: mvpp2: simplify MVPP2_PRS_RI_* definitions
       net: mvpp2: fix indentation of MVPP2_EXT_GLOBAL_CTRL_DEFAULT
       net: mvpp2: remove unused register definitions
       net: mvpp2: simplify mvpp2_bm_bufs_add()
       net: mvpp2: drop useless fields in mvpp2_bm_pool and related code
       net: mvpp2: remove unused 'tx_skb' field of 'struct mvpp2_tx_queue'
       net: mvpp2: release reference to txq_cpu[] entry after unmapping
       net: mvpp2: handle too large value in mvpp2_rx_time_coal_set()
       net: mvpp2: handle too large value handling in mvpp2_rx_pkts_coal_set()
       net: mvpp2: remove useless arguments in mvpp2_rx_{pkts, time}_coal_set
       ...

1e74a2eb1f  Merge tag 'gcc-plugins-v4.11-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/kees/linux
005c3490e9  Revert "ath10k: Search SMBIOS for OEM board file extension"
3051bf36c2  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next
+-------------------------------------------------------+------------+------------+------------+
|                                                       | 1e74a2eb1f | 005c3490e9 | 3051bf36c2 |
+-------------------------------------------------------+------------+------------+------------+
| boot_successes                                        | 1223       | 1098       | 242        |
| boot_failures                                         | 1          | 126        | 72         |
| BUG:unable_to_handle_kernel                           | 1          | 117        | 69         |
| Oops                                                  | 1          | 126        | 72         |
| EIP:perf_callchain_user                               | 1          |            |            |
| Kernel_panic-not_syncing:Fatal_exception              | 1          | 121        | 67         |
| EIP:netlink_release                                   | 0          | 20         | 3          |
| EIP:bpf_prog_free                                     | 0          | 22         | 3          |
| EIP:filp_close                                        | 0          | 64         | 23         |
| EIP:netlink_update_listeners                          | 0          | 10         | 9          |
| EIP:security_inode_getattr                            | 0          | 2          |            |
| EIP:__lock_acquire                                    | 0          | 1          | 11         |
| Kernel_panic-not_syncing:Fatal_exception_in_interrupt | 0          | 5          | 4          |
| EIP:__rcu_process_callbacks                           | 0          | 2          |            |
| EIP:__fget_light                                      | 0          | 1          |            |
| EIP:__unix_remove_socket                              | 0          | 0          | 13         |
| INFO:trying_to_register_non-static_key                | 0          | 0          | 2          |
| EIP:mnt_want_write_file                               | 0          | 0          | 1          |
| EIP:skb_dequeue                                       | 0          | 0          | 1          |
| EIP:strlen                                            | 0          | 0          | 1          |
| EIP:__netlink_lookup                                  | 0          | 0          | 2          |
| EIP:vfs_fsync_range                                   | 0          | 0          | 1          |
| EIP:__unix_find_socket_byname                         | 0          | 0          | 1          |
| EIP:release_sock                                      | 0          | 0          | 1          |
+-------------------------------------------------------+------------+------------+------------+

DANGER: RUNNING AS ROOT.
Unless you are running in a virtual machine, this could cause serious problems such as overwriting CMOS
or similar which could potentially make this machine unbootable without a firmware reset.

ctrl-c now unless you really know what you are doing.
[   32.906310] BUG: unable to handle kernel paging request at 0000a7cf
[   32.907583] IP: __unix_remove_socket+0x10/0x50
[   32.908465] *pde = 00000000 
[   32.908466] 
[   32.909350] Oops: 0002 [#1] DEBUG_PAGEALLOC
[   32.910011] CPU: 0 PID: 436 Comm: trinity-main Not tainted 4.10.0-04456-g3051bf3 #1
[   32.910011] task: 4f024000 task.stack: 4fb5c000
[   32.910011] EIP: __unix_remove_socket+0x10/0x50
[   32.910011] EFLAGS: 00010206 CPU: 0
[   32.910011] EAX: 4f255400 EBX: 4f255400 ECX: 0bf2a7cc EDX: 0000a7cf
[   32.910011] ESI: 4f25577c EDI: 4f255638 EBP: 4fb5de68 ESP: 4fb5de64
[   32.910011]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
[   32.910011] CR0: 80050033 CR2: 0000a7cf CR3: 0f02a000 CR4: 00000610
[   32.910011] Call Trace:
[   32.910011]  unix_release_sock+0x2b/0x330
[   32.910011]  ? umount_tree+0x2d0/0x2d0
[   32.910011]  unix_release+0x16/0x30
[   32.910011]  sock_release+0x13/0x70
[   32.910011]  sock_close+0xb/0x10
[   32.910011]  __fput+0xa3/0x1e0
[   32.910011]  ____fput+0x8/0x10
[   32.910011]  task_work_run+0x6f/0xa0
[   32.910011]  do_exit+0x219/0xac0
[   32.910011]  do_group_exit+0x29/0x90
[   32.910011]  SyS_exit_group+0x11/0x20
[   32.910011]  do_fast_syscall_32+0x99/0x220
[   32.910011]  entry_SYSENTER_32+0x4c/0x7b
[   32.910011] EIP: 0x377c6cc5
[   32.910011] EFLAGS: 00000216 CPU: 0
[   32.910011] EAX: ffffffda EBX: 00000000 ECX: 0000002d EDX: 377bd8ac
[   32.910011] ESI: 00000000 EDI: 00000001 EBP: 3fedfb88 ESP: 3fedfa9c
[   32.910011]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 007b
[   32.910011] Code: 5c 24 04 c7 04 24 e8 e1 00 4c e8 e6 49 41 ff e9 7e ff ff ff 8d b4 26 00 00 00 00 8b 50 38 85 d2 74 26 55 89 e5 53 8b 48 34 85 c9 <89> 0a 74 03 89 51 04 89 c3 c7 40 38 00 00 00 00 8b 40 44 83 f8
[   32.910011] EIP: __unix_remove_socket+0x10/0x50 SS:ESP: 0068:4fb5de64
[   32.910011] CR2: 000000000000a7cf
[   32.910011] ---[ end trace 940cd213af55418c ]---
[   32.910011] Kernel panic - not syncing: Fatal exception

git bisect start d689555ceaa8b31008bda1c5e7a718e7db730148 c470abd4fde40ea6a0846a2beab642a578c0b8cd --
git bisect  bad e45cee90c1347f9effa3ba4daa4508716a6bae88  # 02:35      4-      5  Merge 'hp-parisc/for-next' into devel-spot-201702262250
git bisect  bad 9540e6d53b057fa1c95ded9fb80c331e4d0faa0a  # 02:55      2-      4  Merge 'sound/topic/dollar-cove-ti' into devel-spot-201702262250
git bisect  bad 349ed729f948dc7791353cc369b2de59b8e7ed11  # 03:13     27-      9  Merge 'jss-tpmdd/tabrm-v3' into devel-spot-201702262250
git bisect  bad 00262ffd474b61eb4a9980751fd8179ffd7447db  # 03:47     62-      6  Merge 'linux-review/Julian-Anastasov/ipv4-add-missing-initialization-for-flowi4_uid/20170226-222651' into devel-spot-201702262250
git bisect good b71a4e6d93e06fdcd652d82997c463fac31a58d3  # 04:56    305+      0  0day base guard for 'devel-spot-201702262250'
git bisect  bad 9c4713701c01e4cef6e2315c2818abc919ffb0de  # 05:14      5-      4  bpf: Fix bpf_xdp_event_output
git bisect good ff58d005cd10fcd372787cceac547e11cf706ff6  # 06:58    301+      0  Merge tag 'media/v4.11-1' of git://git.kernel.org/pub/scm/linux/kernel/git/mchehab/linux-media
git bisect good fcdc103dac5bdabddd626a4dfe7e5aa5673a61c4  # 07:57    302+      0  Merge tag 'linux-can-next-for-4.11-20170206' of git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can-next
git bisect good 3105dfb2a99f52c67cd40ec092373081f022ec28  # 09:19    304+      0  Merge tag 'wireless-drivers-next-for-davem-2017-02-16' of git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next
git bisect  bad ff47d8c05019d6e7753cef270d6399cb5a33be57  # 09:31      2-      3  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/s390/linux
git bisect good 32cc1bb3cdac937d8199013512c79ead259e4b63  # 11:14    303+      0  Merge branch 'mvpp2-next'
git bisect good 7bb033829ef3ecfc491c0ed0197966e8f197fbdc  # 12:28    300+      0  Merge tag 'rodata-v4.11-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/kees/linux
git bisect good 72a01d0b6afb5862998d84c19ddc9e1c39a9588c  # 13:28    303+      0  s390/qdio: fix up tiqdio_thinint_handler() kerneldoc
git bisect good 549f2bf594782faa440055255831c9a51940a651  # 13:59    310+      0  s390/mm: add cond_resched call to kernel page table dumper
git bisect good 005c3490e9db23738d91e02788606c0fe4734723  # 14:50    303+     32  Revert "ath10k: Search SMBIOS for OEM board file extension"
git bisect good 1e74a2eb1f5cc7f2f2b5aa9c9eeecbcf352220a3  # 15:37    310+      0  Merge tag 'gcc-plugins-v4.11-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/kees/linux
git bisect good 50a0d46c98b72cde3c6945f066c0adf31e4e8590  # 16:34    301+      1  s390/zcrypt: make ap_bus explicitly non-modular
git bisect good d24b98e3a9c66b16ed029e1b2bcdf3c90e9d82d9  # 17:24    304+      0  s390/syscall: fix single stepped system calls
git bisect  bad 3051bf36c25d5153051704291782f8d44e744d36  # 17:36     22-      8  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next
# first bad commit: [3051bf36c25d5153051704291782f8d44e744d36] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next
git bisect good 1e74a2eb1f5cc7f2f2b5aa9c9eeecbcf352220a3  # 18:33    906+      1  Merge tag 'gcc-plugins-v4.11-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/kees/linux
git bisect good 005c3490e9db23738d91e02788606c0fe4734723  # 19:14    905+    126  Revert "ath10k: Search SMBIOS for OEM board file extension"
# extra tests with CONFIG_DEBUG_INFO_REDUCED
git bisect  bad 3051bf36c25d5153051704291782f8d44e744d36  # 19:22     11-      8  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next
# extra tests on HEAD of linux-devel/devel-spot-201702262250
git bisect  bad d689555ceaa8b31008bda1c5e7a718e7db730148  # 19:22      0-      6  0day head guard for 'devel-spot-201702262250'
# extra tests on tree/branch linus/master
git bisect  bad 2d6be4abf514fc26c83d239c7f31da1f95e4a31d  # 19:36     20-      5  Merge tag 'for-linus-4.11' of git://git.code.sf.net/p/openipmi/linux-ipmi
# extra tests on tree/branch linux-next/master
git bisect  bad 8d01c069486aca75b8f6018a759215b0ed0c91f0  # 19:47     13-      3  Add linux-next specific files for 20170228

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--jl252dk3czobalyd
Content-Type: application/gzip
Content-Disposition: attachment; filename="dmesg-quantal-ivb41-127:20170301175555:i386-randconfig-b0-02262304:4.10.0-04456-g3051bf3:1.gz"
Content-Transfer-Encoding: base64

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
bhntsnKNGpgd3HQg66RVHdk0Jc+HP28xIEVUrWZxq0K/hgGdNeSCtf5tCUmvWq07Tb8TN/Zw
axGvOP4blb0a8LiISSFtI8fjS28dD/0eELvCzOfJrDXlYl4dOAEHY2zGyrdF2Dhr4OPFghTA
lpQlGvio2MXUH0wmwxEXCz0+s7qHV6dnZx+sq8OL7nvr7LLLHhv2ILc1LHIxqrDdeEFGz8y6
Qnkq6y1thQnfeCnvjS5eNK4i8VzEqd+cHlrvFvH8IRlmfDl7nx+t7kMyh1vpDg6n/HZIkk6b
VCohaWSBi8V/nE7uBp0tQ0IHSlw6Qx3jvHwvl12YzydJscoYF3HBhIf7GKjevzskxr4YNfjH
MDiyXaj/+eByGfhz235mCSLpwhpI0vmKOMgl/GXW29VySS8fZ9Z+7q7fP7v4pfdr7/q8Y9v4
9+V/rt5e4N8Mp/7aGqcrgjKXYw3lRwI8udUDPU6SHvCPlalXnvDc9APeBe/eowIL/blG2hvI
lKeN/EOPDH2EAByfXvzQ4b95glnD1ooiDw7j4ytCd/T2XUf9K8+lwAOKBhAliE/2IxzjCyfy
cZ1D5jdtHPWx2IDfXeX5RrCkie18p4EdZrs9sqPiSccKpWfvC59so7K4gmtxGocqaJk9xAvl
Oa9clQCPI0MEm+Y3QVzdB/4RFFRAHm5ovUad3QPL3ePspP4gXo1glnKBuzd4sdji5x5qlCQj
xGbJoG0dMEwjNdNIzTRSM43UTCM100gt/800UjON1EwjNdNIzTRSM43UTCM100jNNFJTW9M2
jdRMI7Wtw00jtfpUTCM100jthZMzjdRMIzWN0TRSM43UTCM100jNNo3UTCM100jNNFIzjdRM
I7VCAppGaqaRmm0aqVUQmEZqtmmkZhqpmUZqppGaaaRmGqmZRmqmkZpppGYaqZlGaqaRmmmk
ZhqpFfaFaaRmGqmZRmqNYKaRmmmkZhqpmUZqppGaaaRmGqmZRmq2aaRmGqmZRmqmkZpppGYa
qW2njWmktp02ppHadtqYRmrbaWMaqW2njWmktp02ppHaGm1MIzXTSM00UjON1EwjtRyHaaRm
GqmZRmqmkVr5ENNIzTRSM43U1qZkGqmZRmqmkZpppGYaqZlGaqaRmmmkZhqpmUZqppGaaaRW
oDeN1EwjNdNIzTRSM43UTCM100jNNFIzjdT+WxupYZzvO9B3v9qjPQTzR7DFnqpWhGGOE+EK
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
vz8wPq8hBtqcuvkBZP8fuM6gcEZ6AQA=

--jl252dk3czobalyd
Content-Type: application/gzip
Content-Disposition: attachment; filename="dmesg-quantal-ivb41-78:20170301182742:i386-randconfig-b0-02262304:4.10.0-02518-g1e74a2e:1.gz"
Content-Transfer-Encoding: base64

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
SCGJS4DFAjXlWEmIN4yOfERLoKpmB54TZLG0zJFNU5JeCHL0SLFVp6P20iRtFPTlA9/6t8Mh
60uVrOnvsRtAl0wXHE+OWmHreARiXBJ1soEndj3PxCMQ5yEjBCPcT7NJa8zlwTowKvaGONzG
t1UYOmv0w9mMFMpWmaPFaIizCZisur3RqD/g8qNHp87B/uXJ6ekH53L//OC9c3pxwBYgtki3
a9gApR1M2IN0RpeoiXOJglfOWzoKI/agKWuQLoc0NJF4EYTuzcm+826WTh+yfsHO3vvyVT14
yKYwU93BgFV6m0i+aXemQTRSEdnh8Dge3fU6G4aEAtfOfILKyGVBYC7kMJ2OsnKXeVwkXOLn
D/cpUL1/t0/sdTZosLepwQmOUTm43gb+3Haf2YIgjlilz6cL4kgXsL85bxfzOS0+LZzd0vy/
e3r+29V/r67POq6L3y/+c/n2HL8znPrp1jjpBYNhofSfmyh/J8DjWz1QSYQe/9GYuvGEZ6Yf
qvvuu/eo6UI/rpFHBzKVaSj/MEYmMKwfnZz/1OGfZcJaw9EKVfzQ0SWhO3z7rqN+K3Mz8ICq
pYQBEkmoVzM/ieAeous8HRz1sTqAP1yW+Uu4mRPb+UEDSwld6IruZemo48SkG+2KKAzdulxD
4HBaiCqRWTykM2WJN1wvwBNLH/a50rPE9YJgb0GJBmT2xs5rVO7dc4Idznbq9tLFANdcLpn3
BgtLHX7uvkZJSl+yXoRoU08N25nNdmazndlsZzbbmW19nO3Mtvo325nNdmYz6GU7s9nObAa8
7cxmO7PpB9jObGqY7cxmO7OZOqDtzPYFVLWd2WxnNtuZzXZm23ZytjOb7cxmO7O9HKPtzGY7
s9nObLYzm+3MZjuz2c5stjMbj7Wd2WxnNtuZzXZms53ZbGc225nNdmazndlsZzbbmc12ZrOd
2UrMtjOb7cxmO7PZzmy2M5vtzGY7s9nObM+6X2xnNtuZzXZms53ZFLDtzGY7s9nObLYzm+3M
Zjuz2c5stjPbChrbma0J3HZma0JjO7PZzmy2M5vtzGY7s9nObLYzm+3MZjuz2c5stjOb7cym
cdjObLYzm+3MZjuz1Q+xndlsZzbbmW1pSrYzm+3MZjuz2c5stjOb7cxmO7PZzmy2M5vtzGY7
s9nObBV625nNdmb7ouXazmy2M5vtzGY7s9nObLYzm+3MZjuzrXVmo3F01/HhRPpmjxak/4cB
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
/JGHPMgbn375GrIn/wN4c66BFrQBAA==

--jl252dk3czobalyd
Content-Type: application/gzip
Content-Disposition: attachment; filename="dmesg-quantal-ivb41-100:20170301190328:i386-randconfig-b0-02262304:4.10.0-rc8-02021-g005c349:1.gz"
Content-Transfer-Encoding: base64

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
XZxIJNIYG7slNysD1QfL+Zxz4bW4KQNtOaBZuM7iEVZp+bykHdDmQjCkBujRiNR5KaS32wvg
huteAMIX+x7CnrtKezaeCIe5CjHWY8OII/YgVrkOwb2SqiRXNghVAEQBVCUGWC5Rho2FcLxl
NObygQtRdnDNgJSPljly05QSD3revE9aoKJ+daWBIkS+5PwTJLwJ4mCRWfwZv9M5cWl+6ZKD
r1FcayMeZO9FFR5EgjbwRKjaRgv7MMumrQnX0+rAA9cfYfMY31Yx26z+juZz0r5aUmo0xNBx
4ua9/ng8GHLFzrNL5+T49uLy8p1ze3x98ta5vDlhdwm7b9saNklgiWjYk3ROFsfUuUWFKOc1
bYUxXzcp14muHTQykNBrwsx7f3HsvJmns8dsUPDN6EN5FE4esxl8Ovfw9pRXMyT69d2fQTTa
pzFKG3ycjO/7nS1D/AiHLZ+imHBZQ5erHsxm46xcZR4XxDDBHh9SoHr75pjY13y4wTnFg2m5
knpwvQz8ue0+sQR+HEGxyPLZkk78DZxVzuvlYkEvnxbOYekrP7y8/q377+7dVcd18e+bf92+
vsa/GU79dWucgRvEdbLHCsrfCfD8gx4oYmQ69vlHY+rGE56YPnEvRM29eYsCKPTnDklnIFOZ
s/EPPTLg6Nuzi+ufOvy3zO7asLUCOiRIKroldKev33TUv8pEBjyg6sJggMRsF89JEuEuhWxf
2jjqY7UBf7gtk306HDrj/KCBkwjiq0tGTDruOHTe3EMREqOtaxv4DudQqKqSxWM6V25r454C
eBL4KT9U1zBcXAfOCdQzQBps7LxEsdsjxz/g1KBeP10OYRNyfYNXeLHU4ecea5S0ueL1ij3b
2lDYpma2qZlrm5rtRmebmtmmZrapmfGbbWpmm5oZ9LJNzWxTMwPeNjWzTc30A2xTMzXMNjWz
Tc1MHdA2NfsPqGqbmtmmZrapmW1qtu/kbFMz29TMNjV7Pkbb1Mw2NbNNzWxTM9vUzDY1s03N
bFMzY6xtamabmtmmZrapmW1qZpua2aZmNbBtamabmtmmZrapmW1qZpua2aZmGrNtamabmtmm
ZrapmR5rm5rZpma2qZltamabmtmmZrapmW1qZpua2aZmtqmZbWpmm5rZpma2qZltamabmtmm
Zk3a2KZmCtw2NbNNzVZx2KZmtqnZdtrYpmYrtLFNzWxTM9vUzDY1s03NHNvUzDY1s03NbFMz
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
brIuDmQc2XyG/4qapw5vRMzkpmNybnLHfPa46VmmZ5ueY3qu6QnT80zPN72m6Z2a3pnptUyv
bXrnpmSmPDNl25Tnpn9q+mem3zL9tumfm03bbDpm0zWbwmyemc2WeeqZp9I89c2Wb7YtEwru
mCP8sGXGgxetqq+welJc3os3KPccTDhYtOhVy4jZrIJlJXuCsSJwViHD0mSujmGx2f+jFbNZ
BTudfayp+7Gq8yJ+7Iyd632s6sH3QR+reu590MeqHhsc9LEKdufgj/EKw7zQG4Xex6qO7oM+
VnWcHbIqtnkdJkS7aFUX/Id8zKlaMlhan90+6H2rapsd8q06xrTLuN7H6hjTHmN6H6vDNGqX
rA6j72iWzK3DWp3qfqyOUXbO9SZqp46J2tZcFbgV7HC+sm3TnhVXtgxZAPKVLSxrfZmsOTVX
m24FI/PXaCQqtH4M7TFe9AP00ByMwvhJZ48JG0yXy2qOEYDic8FrcqpCNMfRu+7HvK7wt/Kd
7LnuR3EVDlv7ut9Hjge6+6xWYw4TTNbkXoVoUmx3elitMYf5svzuWKvGHM7dHQwxpTXGYZG+
tY3WtOOO5ZU6U2hq5/rlhCfbtbNc36s8AkBrejhQU3va6MKs7VLiU7DKPcRSOi4lCCQZ1/As
2OZSggg+Xhd9p0sJyOPrOo2b6w2XkkR0DzVciUtJIqh1yV7qUqIADuBjK3UpSVA09C91KUnE
NXi5SlxKEuHvcSlRor5Oi293KUlAdLx6driUJCg6rFvbXUoIxNXxS9npUpLAaLTmNpeSBEGj
Wx7kUqJgdXxDVlxKEjENB5dylxKfHrKz3T1szaiJvc5pmkYNgMo5v7SNGiLos/5tGjWU1+jd
ZUYNRTW69KZRQ+IAHfeqrUYNAQ4zR2VGDVH0rdKGUUNxfWe9NaMGws4Bzm7rojqF32nUEKQi
32KCUtmowd/dGowawlQzaoigUSeHGjWE1egn60YNxIRGtewwataeiX/DqFl7PGa1jZqlM2Hv
NGqW1ry93ahZOlN2uVHDS8TvMmq2lufpDqNmlzNOHmjUbB0S3O1GzdaZ2LcZNXvPPLrDqNk6
DuP7jBoec1c3ajavRiKbgGhUxX6jZuuwIe80aralUSeHGzXb0qmkDaNm6ywZdhg1v3y1s+H8
m2QuLbqW868CsHfQqpZu2gXnjh5fepJ5e3F0NASAHcStWzTEu3xtDbdYNX0Nt9ijHRp6losb
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
7YgBZlu3PwDs/gUydAbZn3kBAA==

--jl252dk3czobalyd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="reproduce-quantal-ivb41-127:20170301175555:i386-randconfig-b0-02262304:4.10.0-04456-g3051bf3:1"

#!/bin/bash

kernel=$1
initrd=quantal-core-i386.cgz

wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/master/initrd/$initrd

kvm=(
	qemu-system-x86_64
	-enable-kvm
	-cpu kvm64
	-kernel $kernel
	-initrd $initrd
	-m 369
	-smp 2
	-device e1000,netdev=net0
	-netdev user,id=net0
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-watchdog-action debug
	-rtc base=localtime
	-serial stdio
	-display none
	-monitor null
)

append=(
	root=/dev/ram0
	hung_task_panic=1
	debug
	apic=debug
	sysrq_always_enabled
	rcupdate.rcu_cpu_stall_timeout=100
	net.ifnames=0
	printk.devkmsg=on
	panic=-1
	softlockup_panic=1
	nmi_watchdog=panic
	oops=panic
	load_ramdisk=2
	prompt_ramdisk=0
	drbd.minor_count=8
	systemd.log_level=err
	ignore_loglevel
	earlyprintk=ttyS0,115200
	console=ttyS0,115200
	console=tty0
	vga=normal
	rw
	drbd.minor_count=8
)

"${kvm[@]}" -append "${append[*]}"

--jl252dk3czobalyd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-4.10.0-04456-g3051bf3"

#
# Automatically generated file; DO NOT EDIT.
# Linux/i386 4.10.0 Kernel Configuration
#
# CONFIG_64BIT is not set
CONFIG_X86_32=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf32-i386"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/i386_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_MMU=y
CONFIG_ARCH_MMAP_RND_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_BITS_MAX=16
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=16
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_HAVE_INTEL_TXT=y
CONFIG_X86_32_LAZY_GS=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_PGTABLE_LEVELS=2
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_CONSTRUCTORS=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y
CONFIG_THREAD_INFO_IN_TASK=y

#
# General setup
#
CONFIG_BROKEN_ON_SMP=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
CONFIG_KERNEL_LZMA=y
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
# CONFIG_POSIX_MQUEUE is not set
# CONFIG_CROSS_MEMORY_ATTACH is not set
CONFIG_FHANDLE=y
CONFIG_USELIB=y
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_GENERIC_MSI_IRQ=y
CONFIG_GENERIC_MSI_IRQ_DOMAIN=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
CONFIG_NO_HZ_IDLE=y
# CONFIG_NO_HZ is not set
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_TINY_RCU=y
CONFIG_RCU_EXPERT=y
CONFIG_SRCU=y
CONFIG_TASKS_RCU=y
# CONFIG_RCU_STALL_COMMON is not set
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_RCU_KTHREAD_PRIO=0
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_NMI_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_CGROUPS=y
CONFIG_PAGE_COUNTER=y
CONFIG_MEMCG=y
# CONFIG_MEMCG_SWAP is not set
# CONFIG_BLK_CGROUP is not set
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
# CONFIG_RT_GROUP_SCHED is not set
# CONFIG_CGROUP_PIDS is not set
# CONFIG_CGROUP_FREEZER is not set
# CONFIG_CGROUP_HUGETLB is not set
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
CONFIG_CGROUP_DEVICE=y
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_CGROUP_PERF=y
# CONFIG_CGROUP_DEBUG is not set
# CONFIG_SOCK_CGROUP_DATA is not set
CONFIG_CHECKPOINT_RESTORE=y
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
# CONFIG_USER_NS is not set
CONFIG_PID_NS=y
CONFIG_NET_NS=y
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
CONFIG_INITRAMFS_COMPRESSION=".gz"
CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
# CONFIG_UID16 is not set
CONFIG_MULTIUSER=y
# CONFIG_SGETMASK_SYSCALL is not set
# CONFIG_SYSFS_SYSCALL is not set
# CONFIG_POSIX_TIMERS is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
# CONFIG_KALLSYMS_ABSOLUTE_PERCPU is not set
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
# CONFIG_PCSPKR_PLATFORM is not set
# CONFIG_BASE_FULL is not set
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
# CONFIG_BPF_SYSCALL is not set
CONFIG_SHMEM=y
# CONFIG_AIO is not set
# CONFIG_ADVISE_SYSCALLS is not set
# CONFIG_USERFAULTFD is not set
CONFIG_PCI_QUIRKS=y
# CONFIG_MEMBARRIER is not set
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
# CONFIG_COMPAT_BRK is not set
CONFIG_SLAB=y
# CONFIG_SLUB is not set
# CONFIG_SLOB is not set
CONFIG_SLAB_FREELIST_RANDOM=y
# CONFIG_SYSTEM_DATA_VERIFICATION is not set
# CONFIG_PROFILING is not set
CONFIG_TRACEPOINTS=y
CONFIG_KEXEC_CORE=y
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_JUMP_LABEL=y
# CONFIG_STATIC_KEYS_SELFTEST is not set
CONFIG_UPROBES=y
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_NMI=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_ARCH_HAS_SET_MEMORY=y
CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_CLK=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_IPC_PARSE_VERSION=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_HAVE_GCC_PLUGINS=y
# CONFIG_GCC_PLUGINS is not set
CONFIG_HAVE_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR is not set
CONFIG_CC_STACKPROTECTOR_NONE=y
# CONFIG_CC_STACKPROTECTOR_REGULAR is not set
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_MODULES_USE_ELF_REL=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_HAVE_EXIT_THREAD=y
CONFIG_ARCH_MMAP_RND_BITS=8
CONFIG_HAVE_COPY_THREAD_TLS=y
# CONFIG_HAVE_ARCH_HASH is not set
CONFIG_ISA_BUS_API=y
CONFIG_CLONE_BACKWARDS=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_OLD_SIGACTION=y
# CONFIG_CPU_NO_EFFICIENT_FFS is not set
# CONFIG_HAVE_ARCH_VMAP_STACK is not set
# CONFIG_ARCH_OPTIONAL_KERNEL_RWX is not set
# CONFIG_ARCH_OPTIONAL_KERNEL_RWX_DEFAULT is not set
CONFIG_ARCH_HAS_STRICT_KERNEL_RWX=y
CONFIG_STRICT_KERNEL_RWX=y
CONFIG_ARCH_HAS_STRICT_MODULE_RWX=y

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
# CONFIG_GCOV_PROFILE_ALL is not set
# CONFIG_GCOV_FORMAT_AUTODETECT is not set
# CONFIG_GCOV_FORMAT_3_4 is not set
CONFIG_GCOV_FORMAT_4_7=y
CONFIG_HAVE_GENERIC_DMA_COHERENT=y
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=1
# CONFIG_MODULES is not set
CONFIG_MODULES_TREE_LOOKUP=y
CONFIG_BLOCK=y
# CONFIG_LBDAF is not set
CONFIG_BLK_SCSI_REQUEST=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
# CONFIG_BLK_DEV_ZONED is not set
CONFIG_BLK_CMDLINE_PARSER=y
# CONFIG_BLK_WBT is not set
CONFIG_BLK_DEBUG_FS=y
# CONFIG_BLK_SED_OPAL is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
CONFIG_ACORN_PARTITION=y
CONFIG_ACORN_PARTITION_CUMANA=y
# CONFIG_ACORN_PARTITION_EESOX is not set
# CONFIG_ACORN_PARTITION_ICS is not set
# CONFIG_ACORN_PARTITION_ADFS is not set
CONFIG_ACORN_PARTITION_POWERTEC=y
# CONFIG_ACORN_PARTITION_RISCIX is not set
# CONFIG_AIX_PARTITION is not set
# CONFIG_OSF_PARTITION is not set
CONFIG_AMIGA_PARTITION=y
CONFIG_ATARI_PARTITION=y
# CONFIG_MAC_PARTITION is not set
# CONFIG_MSDOS_PARTITION is not set
CONFIG_LDM_PARTITION=y
CONFIG_LDM_DEBUG=y
# CONFIG_SGI_PARTITION is not set
CONFIG_ULTRIX_PARTITION=y
CONFIG_SUN_PARTITION=y
# CONFIG_KARMA_PARTITION is not set
CONFIG_EFI_PARTITION=y
CONFIG_SYSV68_PARTITION=y
# CONFIG_CMDLINE_PARTITION is not set
CONFIG_BLK_MQ_PCI=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
# CONFIG_DEFAULT_DEADLINE is not set
# CONFIG_DEFAULT_CFQ is not set
CONFIG_DEFAULT_NOOP=y
CONFIG_DEFAULT_IOSCHED="noop"
CONFIG_MQ_IOSCHED_DEADLINE=y
CONFIG_MQ_IOSCHED_NONE=y
# CONFIG_DEFAULT_SQ_DEADLINE is not set
CONFIG_DEFAULT_SQ_NONE=y
CONFIG_DEFAULT_SQ_IOSCHED="none"
# CONFIG_DEFAULT_MQ_DEADLINE is not set
CONFIG_DEFAULT_MQ_NONE=y
CONFIG_DEFAULT_MQ_IOSCHED="none"
CONFIG_ASN1=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
# CONFIG_FREEZER is not set

#
# Processor type and features
#
# CONFIG_ZONE_DMA is not set
# CONFIG_SMP is not set
CONFIG_X86_FEATURE_NAMES=y
CONFIG_X86_FAST_FEATURE_TESTS=y
CONFIG_X86_MPPARSE=y
CONFIG_GOLDFISH=y
CONFIG_INTEL_RDT_A=y
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_GOLDFISH is not set
# CONFIG_X86_INTEL_MID is not set
CONFIG_X86_INTEL_QUARK=y
CONFIG_X86_INTEL_LPSS=y
CONFIG_X86_AMD_PLATFORM_DEVICE=y
CONFIG_IOSF_MBI=y
# CONFIG_IOSF_MBI_DEBUG is not set
# CONFIG_X86_RDC321X is not set
CONFIG_X86_32_IRIS=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_LGUEST_GUEST is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
# CONFIG_M686 is not set
# CONFIG_MPENTIUMII is not set
CONFIG_MPENTIUMIII=y
# CONFIG_MPENTIUMM is not set
# CONFIG_MPENTIUM4 is not set
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
# CONFIG_MK8 is not set
# CONFIG_MCRUSOE is not set
# CONFIG_MEFFICEON is not set
# CONFIG_MWINCHIPC6 is not set
# CONFIG_MWINCHIP3D is not set
# CONFIG_MELAN is not set
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_MVIAC7 is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_X86_GENERIC=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=5
CONFIG_X86_DEBUGCTLMSR=y
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_CYRIX_32=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_CPU_SUP_TRANSMETA_32=y
CONFIG_CPU_SUP_UMC_32=y
CONFIG_HPET_TIMER=y
# CONFIG_DMI is not set
CONFIG_NR_CPUS=1
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_UP_LATE_INIT=y
CONFIG_X86_UP_APIC=y
# CONFIG_X86_UP_IOAPIC is not set
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
# CONFIG_X86_MCE is not set

#
# Performance monitoring
#
# CONFIG_PERF_EVENTS_INTEL_UNCORE is not set
CONFIG_PERF_EVENTS_INTEL_RAPL=y
CONFIG_PERF_EVENTS_INTEL_CSTATE=y
CONFIG_PERF_EVENTS_AMD_POWER=y
# CONFIG_X86_LEGACY_VM86 is not set
# CONFIG_VM86 is not set
# CONFIG_X86_16BIT is not set
CONFIG_TOSHIBA=y
CONFIG_I8K=y
# CONFIG_X86_REBOOTFIXUPS is not set
# CONFIG_MICROCODE is not set
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
# CONFIG_NOHIGHMEM is not set
CONFIG_HIGHMEM4G=y
# CONFIG_HIGHMEM64G is not set
# CONFIG_VMSPLIT_3G is not set
# CONFIG_VMSPLIT_3G_OPT is not set
# CONFIG_VMSPLIT_2G is not set
# CONFIG_VMSPLIT_2G_OPT is not set
CONFIG_VMSPLIT_1G=y
CONFIG_PAGE_OFFSET=0x40000000
CONFIG_HIGHMEM=y
CONFIG_NEED_NODE_MEMMAP_SIZE=y
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0
CONFIG_SELECT_MEMORY_MODEL=y
# CONFIG_FLATMEM_MANUAL is not set
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_STATIC=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
# CONFIG_MEMORY_HOTPLUG is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_MEMORY_BALLOON=y
# CONFIG_COMPACTION is not set
CONFIG_MIGRATION=y
# CONFIG_PHYS_ADDR_T_64BIT is not set
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_NEED_PER_CPU_KM=y
CONFIG_CLEANCACHE=y
# CONFIG_FRONTSWAP is not set
CONFIG_CMA=y
# CONFIG_CMA_DEBUG is not set
CONFIG_CMA_DEBUGFS=y
CONFIG_CMA_AREAS=7
CONFIG_ZPOOL=y
CONFIG_ZBUD=y
CONFIG_Z3FOLD=y
# CONFIG_ZSMALLOC is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT=y
CONFIG_IDLE_PAGE_TRACKING=y
CONFIG_FRAME_VECTOR=y
CONFIG_HIGHPTE=y
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
# CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MATH_EMULATION=y
CONFIG_MTRR=y
# CONFIG_MTRR_SANITIZER is not set
# CONFIG_X86_PAT is not set
# CONFIG_ARCH_RANDOM is not set
# CONFIG_X86_SMAP is not set
CONFIG_X86_INTEL_MPX=y
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
CONFIG_HZ_100=y
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=100
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_RANDOMIZE_BASE=y
CONFIG_X86_NEED_RELOCS=y
CONFIG_PHYSICAL_ALIGN=0x200000
# CONFIG_COMPAT_VDSO is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y

#
# Power management and ACPI options
#
# CONFIG_SUSPEND is not set
# CONFIG_HIBERNATION is not set
# CONFIG_PM is not set
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
CONFIG_ACPI_DEBUGGER=y
# CONFIG_ACPI_DEBUGGER_USER is not set
CONFIG_ACPI_PROCFS_POWER=y
# CONFIG_ACPI_REV_OVERRIDE_POSSIBLE is not set
CONFIG_ACPI_EC_DEBUGFS=y
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=y
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=y
CONFIG_ACPI_THERMAL=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_DEBUG=y
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
# CONFIG_ACPI_CONTAINER is not set
CONFIG_ACPI_HOTPLUG_IOAPIC=y
CONFIG_ACPI_SBS=y
CONFIG_ACPI_HED=y
CONFIG_ACPI_CUSTOM_METHOD=y
CONFIG_ACPI_REDUCED_HARDWARE_ONLY=y
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
CONFIG_ACPI_APEI=y
CONFIG_ACPI_APEI_GHES=y
CONFIG_ACPI_APEI_PCIEAER=y
CONFIG_ACPI_APEI_EINJ=y
CONFIG_ACPI_APEI_ERST_DEBUG=y
# CONFIG_DPTF_POWER is not set
# CONFIG_PMIC_OPREGION is not set
CONFIG_ACPI_CONFIGFS=y
# CONFIG_SFI is not set

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_ATTR_SET=y
CONFIG_CPU_FREQ_GOV_COMMON=y
CONFIG_CPU_FREQ_STAT=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE=y
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y

#
# CPU frequency scaling drivers
#
# CONFIG_X86_INTEL_PSTATE is not set
CONFIG_X86_PCC_CPUFREQ=y
CONFIG_X86_ACPI_CPUFREQ=y
# CONFIG_X86_ACPI_CPUFREQ_CPB is not set
# CONFIG_X86_POWERNOW_K6 is not set
CONFIG_X86_POWERNOW_K7=y
CONFIG_X86_POWERNOW_K7_ACPI=y
# CONFIG_X86_POWERNOW_K8 is not set
CONFIG_X86_AMD_FREQ_SENSITIVITY=y
# CONFIG_X86_GX_SUSPMOD is not set
CONFIG_X86_SPEEDSTEP_CENTRINO=y
CONFIG_X86_SPEEDSTEP_CENTRINO_TABLE=y
CONFIG_X86_SPEEDSTEP_ICH=y
CONFIG_X86_SPEEDSTEP_SMI=y
CONFIG_X86_P4_CLOCKMOD=y
CONFIG_X86_CPUFREQ_NFORCE2=y
# CONFIG_X86_LONGRUN is not set
CONFIG_X86_LONGHAUL=y
# CONFIG_X86_E_POWERSAVER is not set

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=y
CONFIG_X86_SPEEDSTEP_RELAXED_CAP_CHECK=y

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
CONFIG_INTEL_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
# CONFIG_PCI_GOBIOS is not set
# CONFIG_PCI_GOMMCONFIG is not set
# CONFIG_PCI_GODIRECT is not set
CONFIG_PCI_GOANY=y
CONFIG_PCI_BIOS=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
CONFIG_PCI_CNB20LE_QUIRK=y
CONFIG_PCIEPORTBUS=y
CONFIG_PCIEAER=y
CONFIG_PCIE_ECRC=y
CONFIG_PCIEAER_INJECT=y
CONFIG_PCIEASPM=y
# CONFIG_PCIEASPM_DEBUG is not set
CONFIG_PCIEASPM_DEFAULT=y
# CONFIG_PCIEASPM_POWERSAVE is not set
# CONFIG_PCIEASPM_PERFORMANCE is not set
CONFIG_PCIE_DPC=y
CONFIG_PCIE_PTM=y
CONFIG_PCI_MSI=y
CONFIG_PCI_MSI_IRQ_DOMAIN=y
# CONFIG_PCI_DEBUG is not set
CONFIG_PCI_REALLOC_ENABLE_AUTO=y
CONFIG_PCI_STUB=y
CONFIG_HT_IRQ=y
CONFIG_PCI_ATS=y
CONFIG_PCI_IOV=y
CONFIG_PCI_PRI=y
CONFIG_PCI_PASID=y
CONFIG_PCI_LABEL=y
# CONFIG_HOTPLUG_PCI is not set

#
# PCI host controller drivers
#
# CONFIG_PCIE_DW_PLAT is not set
# CONFIG_ISA_BUS is not set
CONFIG_ISA_DMA_API=y
CONFIG_ISA=y
CONFIG_EISA=y
# CONFIG_EISA_VLB_PRIMING is not set
CONFIG_EISA_PCI_EISA=y
# CONFIG_EISA_VIRTUAL_ROOT is not set
# CONFIG_EISA_NAMES is not set
CONFIG_SCx200=y
CONFIG_SCx200HR_TIMER=y
# CONFIG_OLPC is not set
# CONFIG_ALIX is not set
# CONFIG_NET5501 is not set
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
# CONFIG_PCMCIA_LOAD_CIS is not set
# CONFIG_CARDBUS is not set

#
# PC-card bridges
#
CONFIG_YENTA=y
# CONFIG_YENTA_O2 is not set
CONFIG_YENTA_RICOH=y
CONFIG_YENTA_TI=y
# CONFIG_YENTA_TOSHIBA is not set
CONFIG_PD6729=y
# CONFIG_I82092 is not set
CONFIG_I82365=y
# CONFIG_TCIC is not set
CONFIG_PCMCIA_PROBE=y
CONFIG_PCCARD_NONSTATIC=y
# CONFIG_RAPIDIO is not set
CONFIG_X86_SYSFB=y

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ELFCORE=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_HAVE_AOUT=y
CONFIG_BINFMT_AOUT=y
# CONFIG_BINFMT_MISC is not set
# CONFIG_COREDUMP is not set
CONFIG_COMPAT_32=y
CONFIG_HAVE_ATOMIC_IOMAP=y
CONFIG_PMC_ATOM=y
CONFIG_NET=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
# CONFIG_NET_KEY is not set
# CONFIG_INET is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NET_PTP_CLASSIFY is not set
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
# CONFIG_ATM is not set
# CONFIG_BRIDGE is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
# CONFIG_DNS_RESOLVER is not set
# CONFIG_BATMAN_ADV is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_MPLS is not set
# CONFIG_HSR is not set
# CONFIG_CGROUP_NET_PRIO is not set
# CONFIG_CGROUP_NET_CLASSID is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y

#
# Network testing
#
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
# CONFIG_STREAM_PARSER is not set
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set
# CONFIG_LIB80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
# CONFIG_NFC is not set
# CONFIG_PSAMPLE is not set
# CONFIG_NET_IFE is not set
# CONFIG_LWTUNNEL is not set
# CONFIG_DST_CACHE is not set
# CONFIG_GRO_CELLS is not set
# CONFIG_NET_DEVLINK is not set
CONFIG_MAY_USE_DEVLINK=y

#
# Device Drivers
#

#
# Generic Driver Options
#
# CONFIG_UEVENT_HELPER is not set
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
CONFIG_FW_LOADER_USER_HELPER_FALLBACK=y
# CONFIG_ALLOW_DEV_COREDUMP is not set
# CONFIG_DEBUG_DRIVER is not set
CONFIG_DEBUG_DEVRES=y
CONFIG_DEBUG_TEST_DRIVER_REMOVE=y
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
# CONFIG_DMA_FENCE_TRACE is not set
# CONFIG_DMA_CMA is not set

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
# CONFIG_MTD is not set
# CONFIG_OF is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=y
CONFIG_PARPORT_PC=y
CONFIG_PARPORT_SERIAL=y
CONFIG_PARPORT_PC_FIFO=y
# CONFIG_PARPORT_PC_SUPERIO is not set
CONFIG_PARPORT_PC_PCMCIA=y
# CONFIG_PARPORT_GSC is not set
CONFIG_PARPORT_AX88796=y
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
# CONFIG_ISAPNP is not set
CONFIG_PNPBIOS=y
# CONFIG_PNPBIOS_PROC_FS is not set
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_NULL_BLK is not set
# CONFIG_BLK_DEV_FD is not set
# CONFIG_PARIDE is not set
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
# CONFIG_BLK_DEV_LOOP is not set

#
# DRBD disabled because PROC_FS or INET not selected
#
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_VIRTIO_BLK is not set
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RSXX is not set
CONFIG_NVME_CORE=y
CONFIG_BLK_DEV_NVME=y
CONFIG_BLK_DEV_NVME_SCSI=y
CONFIG_NVME_FABRICS=y
CONFIG_NVME_FC=y
CONFIG_NVME_TARGET=y
CONFIG_NVME_TARGET_LOOP=y
# CONFIG_NVME_TARGET_FC is not set

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
CONFIG_AD525X_DPOT=y
CONFIG_AD525X_DPOT_I2C=y
# CONFIG_AD525X_DPOT_SPI is not set
CONFIG_DUMMY_IRQ=y
CONFIG_IBM_ASM=y
# CONFIG_PHANTOM is not set
CONFIG_SGI_IOC4=y
CONFIG_TIFM_CORE=y
CONFIG_TIFM_7XX1=y
CONFIG_ICS932S401=y
CONFIG_ENCLOSURE_SERVICES=y
CONFIG_HP_ILO=y
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=y
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=y
CONFIG_SENSORS_BH1770=y
CONFIG_SENSORS_APDS990X=y
CONFIG_HMC6352=y
CONFIG_DS1682=y
CONFIG_TI_DAC7512=y
# CONFIG_VMWARE_BALLOON is not set
# CONFIG_PCH_PHUB is not set
CONFIG_USB_SWITCH_FSA9480=y
CONFIG_LATTICE_ECP3_CONFIG=y
CONFIG_SRAM=y
# CONFIG_PANEL is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
CONFIG_EEPROM_AT25=y
CONFIG_EEPROM_LEGACY=y
CONFIG_EEPROM_MAX6875=y
CONFIG_EEPROM_93CX6=y
CONFIG_EEPROM_93XX46=y
CONFIG_CB710_CORE=y
CONFIG_CB710_DEBUG=y
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=y
CONFIG_INTEL_MEI=y
CONFIG_INTEL_MEI_ME=y
CONFIG_INTEL_MEI_TXE=y
CONFIG_VMWARE_VMCI=y

#
# Intel MIC Bus Driver
#

#
# SCIF Bus Driver
#

#
# VOP Bus Driver
#

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#

#
# SCIF Driver
#

#
# Intel MIC Coprocessor State Management (COSM) Drivers
#

#
# VOP Driver
#
# CONFIG_ECHO is not set
# CONFIG_CXL_BASE is not set
# CONFIG_CXL_AFU_DRIVER_OPS is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_NETLINK is not set
CONFIG_SCSI_MQ_DEFAULT=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
CONFIG_CHR_DEV_ST=y
CONFIG_CHR_DEV_OSST=y
# CONFIG_BLK_DEV_SR is not set
CONFIG_CHR_DEV_SG=y
CONFIG_CHR_DEV_SCH=y
CONFIG_SCSI_ENCLOSURE=y
CONFIG_SCSI_CONSTANTS=y
# CONFIG_SCSI_LOGGING is not set
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
# CONFIG_SCSI_FC_ATTRS is not set
# CONFIG_SCSI_ISCSI_ATTRS is not set
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
# CONFIG_SCSI_SAS_ATA is not set
CONFIG_SCSI_SAS_HOST_SMP=y
# CONFIG_SCSI_SRP_ATTRS is not set
# CONFIG_SCSI_LOWLEVEL is not set
# CONFIG_SCSI_LOWLEVEL_PCMCIA is not set
# CONFIG_SCSI_DH is not set
CONFIG_SCSI_OSD_INITIATOR=y
# CONFIG_SCSI_OSD_ULD is not set
CONFIG_SCSI_OSD_DPRINT_SENSE=1
# CONFIG_SCSI_OSD_DEBUG is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_VERBOSE_ERROR=y
# CONFIG_ATA_ACPI is not set
# CONFIG_SATA_PMP is not set

#
# Controllers with non-SFF native interface
#
# CONFIG_SATA_AHCI is not set
# CONFIG_SATA_AHCI_PLATFORM is not set
# CONFIG_SATA_INIC162X is not set
# CONFIG_SATA_ACARD_AHCI is not set
# CONFIG_SATA_SIL24 is not set
CONFIG_ATA_SFF=y

#
# SFF controllers with custom DMA interface
#
# CONFIG_PDC_ADMA is not set
# CONFIG_SATA_QSTOR is not set
CONFIG_SATA_SX4=y
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
# CONFIG_ATA_PIIX is not set
# CONFIG_SATA_DWC is not set
CONFIG_SATA_MV=y
CONFIG_SATA_NV=y
CONFIG_SATA_PROMISE=y
# CONFIG_SATA_SIL is not set
# CONFIG_SATA_SIS is not set
CONFIG_SATA_SVW=y
# CONFIG_SATA_ULI is not set
# CONFIG_SATA_VIA is not set
CONFIG_SATA_VITESSE=y

#
# PATA SFF controllers with BMDMA
#
# CONFIG_PATA_ALI is not set
CONFIG_PATA_AMD=y
CONFIG_PATA_ARTOP=y
# CONFIG_PATA_ATIIXP is not set
CONFIG_PATA_ATP867X=y
CONFIG_PATA_CMD64X=y
CONFIG_PATA_CS5520=y
# CONFIG_PATA_CS5530 is not set
CONFIG_PATA_CS5535=y
CONFIG_PATA_CS5536=y
CONFIG_PATA_CYPRESS=y
# CONFIG_PATA_EFAR is not set
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
CONFIG_PATA_HPT3X2N=y
CONFIG_PATA_HPT3X3=y
# CONFIG_PATA_HPT3X3_DMA is not set
CONFIG_PATA_IT8213=y
# CONFIG_PATA_IT821X is not set
CONFIG_PATA_JMICRON=y
CONFIG_PATA_MARVELL=y
# CONFIG_PATA_NETCELL is not set
CONFIG_PATA_NINJA32=y
CONFIG_PATA_NS87415=y
CONFIG_PATA_OLDPIIX=y
# CONFIG_PATA_OPTIDMA is not set
# CONFIG_PATA_PDC2027X is not set
# CONFIG_PATA_PDC_OLD is not set
CONFIG_PATA_RADISYS=y
# CONFIG_PATA_RDC is not set
CONFIG_PATA_SC1200=y
CONFIG_PATA_SCH=y
CONFIG_PATA_SERVERWORKS=y
CONFIG_PATA_SIL680=y
CONFIG_PATA_SIS=y
CONFIG_PATA_TOSHIBA=y
# CONFIG_PATA_TRIFLEX is not set
# CONFIG_PATA_VIA is not set
# CONFIG_PATA_WINBOND is not set

#
# PIO-only SFF controllers
#
CONFIG_PATA_CMD640_PCI=y
CONFIG_PATA_MPIIX=y
CONFIG_PATA_NS87410=y
# CONFIG_PATA_OPTI is not set
CONFIG_PATA_PCMCIA=y
CONFIG_PATA_PLATFORM=y
CONFIG_PATA_QDI=y
# CONFIG_PATA_RZ1000 is not set
# CONFIG_PATA_WINBOND_VLB is not set

#
# Generic fallback / legacy drivers
#
CONFIG_ATA_GENERIC=y
CONFIG_PATA_LEGACY=y
# CONFIG_MD is not set
CONFIG_TARGET_CORE=y
CONFIG_TCM_IBLOCK=y
# CONFIG_TCM_FILEIO is not set
CONFIG_TCM_PSCSI=y
# CONFIG_TCM_USER2 is not set
# CONFIG_LOOPBACK_TARGET is not set
# CONFIG_ISCSI_TARGET is not set
CONFIG_SBP_TARGET=y
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=y
CONFIG_FIREWIRE_OHCI=y
CONFIG_FIREWIRE_SBP2=y
CONFIG_FIREWIRE_NOSY=y
# CONFIG_MACINTOSH_DRIVERS is not set
# CONFIG_NETDEVICES is not set
# CONFIG_NVM is not set

#
# Input device support
#
CONFIG_INPUT=y
# CONFIG_INPUT_LEDS is not set
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=y
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ADP5520=y
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
CONFIG_KEYBOARD_QT1070=y
# CONFIG_KEYBOARD_QT2160 is not set
CONFIG_KEYBOARD_LKKBD=y
# CONFIG_KEYBOARD_GPIO is not set
CONFIG_KEYBOARD_GPIO_POLLED=y
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
CONFIG_KEYBOARD_MATRIX=y
CONFIG_KEYBOARD_LM8323=y
CONFIG_KEYBOARD_LM8333=y
CONFIG_KEYBOARD_MAX7359=y
CONFIG_KEYBOARD_MCS=y
# CONFIG_KEYBOARD_MPR121 is not set
CONFIG_KEYBOARD_NEWTON=y
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_SAMSUNG is not set
CONFIG_KEYBOARD_GOLDFISH_EVENTS=y
CONFIG_KEYBOARD_STOWAWAY=y
CONFIG_KEYBOARD_SUNKBD=y
CONFIG_KEYBOARD_TWL4030=y
# CONFIG_KEYBOARD_XTKBD is not set
CONFIG_INPUT_MOUSE=y
# CONFIG_MOUSE_PS2 is not set
CONFIG_MOUSE_SERIAL=y
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
CONFIG_MOUSE_CYAPA=y
CONFIG_MOUSE_ELAN_I2C=y
# CONFIG_MOUSE_ELAN_I2C_I2C is not set
CONFIG_MOUSE_ELAN_I2C_SMBUS=y
CONFIG_MOUSE_INPORT=y
CONFIG_MOUSE_ATIXL=y
# CONFIG_MOUSE_LOGIBM is not set
# CONFIG_MOUSE_PC110PAD is not set
CONFIG_MOUSE_VSXXXAA=y
CONFIG_MOUSE_GPIO=y
CONFIG_MOUSE_SYNAPTICS_I2C=y
# CONFIG_MOUSE_SYNAPTICS_USB is not set
CONFIG_INPUT_JOYSTICK=y
CONFIG_JOYSTICK_ANALOG=y
CONFIG_JOYSTICK_A3D=y
CONFIG_JOYSTICK_ADI=y
# CONFIG_JOYSTICK_COBRA is not set
CONFIG_JOYSTICK_GF2K=y
CONFIG_JOYSTICK_GRIP=y
# CONFIG_JOYSTICK_GRIP_MP is not set
CONFIG_JOYSTICK_GUILLEMOT=y
# CONFIG_JOYSTICK_INTERACT is not set
CONFIG_JOYSTICK_SIDEWINDER=y
CONFIG_JOYSTICK_TMDC=y
# CONFIG_JOYSTICK_IFORCE is not set
CONFIG_JOYSTICK_WARRIOR=y
CONFIG_JOYSTICK_MAGELLAN=y
CONFIG_JOYSTICK_SPACEORB=y
CONFIG_JOYSTICK_SPACEBALL=y
# CONFIG_JOYSTICK_STINGER is not set
# CONFIG_JOYSTICK_TWIDJOY is not set
CONFIG_JOYSTICK_ZHENHUA=y
CONFIG_JOYSTICK_DB9=y
CONFIG_JOYSTICK_GAMECON=y
CONFIG_JOYSTICK_TURBOGRAFX=y
CONFIG_JOYSTICK_AS5011=y
CONFIG_JOYSTICK_JOYDUMP=y
# CONFIG_JOYSTICK_XPAD is not set
CONFIG_JOYSTICK_WALKERA0701=y
CONFIG_INPUT_TABLET=y
# CONFIG_TABLET_USB_ACECAD is not set
# CONFIG_TABLET_USB_AIPTEK is not set
# CONFIG_TABLET_USB_HANWANG is not set
# CONFIG_TABLET_USB_KBTAB is not set
# CONFIG_TABLET_USB_PEGASUS is not set
CONFIG_TABLET_SERIAL_WACOM4=y
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=y
CONFIG_INPUT_88PM80X_ONKEY=y
# CONFIG_INPUT_AD714X is not set
# CONFIG_INPUT_BMA150 is not set
# CONFIG_INPUT_E3X0_BUTTON is not set
CONFIG_INPUT_MAX8925_ONKEY=y
CONFIG_INPUT_MC13783_PWRBUTTON=y
# CONFIG_INPUT_MMA8450 is not set
CONFIG_INPUT_MPU3050=y
CONFIG_INPUT_APANEL=y
# CONFIG_INPUT_GP2A is not set
CONFIG_INPUT_GPIO_BEEPER=y
# CONFIG_INPUT_GPIO_TILT_POLLED is not set
# CONFIG_INPUT_GPIO_DECODER is not set
CONFIG_INPUT_WISTRON_BTNS=y
CONFIG_INPUT_ATLAS_BTNS=y
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
CONFIG_INPUT_KXTJ9=y
CONFIG_INPUT_KXTJ9_POLLED_MODE=y
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
CONFIG_INPUT_REGULATOR_HAPTIC=y
# CONFIG_INPUT_RETU_PWRBUTTON is not set
CONFIG_INPUT_TPS65218_PWRBUTTON=y
CONFIG_INPUT_AXP20X_PEK=y
# CONFIG_INPUT_TWL4030_PWRBUTTON is not set
# CONFIG_INPUT_TWL4030_VIBRA is not set
CONFIG_INPUT_UINPUT=y
CONFIG_INPUT_PALMAS_PWRBUTTON=y
CONFIG_INPUT_PCF8574=y
CONFIG_INPUT_GPIO_ROTARY_ENCODER=y
CONFIG_INPUT_DA9052_ONKEY=y
CONFIG_INPUT_DA9055_ONKEY=y
CONFIG_INPUT_DA9063_ONKEY=y
CONFIG_INPUT_WM831X_ON=y
# CONFIG_INPUT_ADXL34X is not set
CONFIG_INPUT_CMA3000=y
CONFIG_INPUT_CMA3000_I2C=y
# CONFIG_INPUT_IDEAPAD_SLIDEBAR is not set
CONFIG_INPUT_DRV260X_HAPTICS=y
# CONFIG_INPUT_DRV2665_HAPTICS is not set
# CONFIG_INPUT_DRV2667_HAPTICS is not set
CONFIG_RMI4_CORE=y
# CONFIG_RMI4_I2C is not set
CONFIG_RMI4_SPI=y
# CONFIG_RMI4_SMB is not set
CONFIG_RMI4_F03=y
CONFIG_RMI4_F03_SERIO=y
CONFIG_RMI4_2D_SENSOR=y
CONFIG_RMI4_F11=y
CONFIG_RMI4_F12=y
CONFIG_RMI4_F30=y
CONFIG_RMI4_F34=y
CONFIG_RMI4_F54=y
CONFIG_RMI4_F55=y

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
CONFIG_SERIO_PARKBD=y
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
CONFIG_SERIO_ALTERA_PS2=y
# CONFIG_SERIO_PS2MULT is not set
# CONFIG_SERIO_ARC_PS2 is not set
# CONFIG_USERIO is not set
CONFIG_GAMEPORT=y
# CONFIG_GAMEPORT_NS558 is not set
CONFIG_GAMEPORT_L4=y
# CONFIG_GAMEPORT_EMU10K1 is not set
CONFIG_GAMEPORT_FM801=y

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_LEGACY_PTYS is not set
# CONFIG_SERIAL_NONSTANDARD is not set
CONFIG_NOZOMI=y
# CONFIG_N_GSM is not set
# CONFIG_TRACE_SINK is not set
CONFIG_GOLDFISH_TTY=y
CONFIG_DEVMEM=y
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
# CONFIG_SERIAL_8250_DEPRECATED_OPTIONS is not set
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_FINTEK=y
CONFIG_SERIAL_8250_CONSOLE=y
# CONFIG_SERIAL_8250_DMA is not set
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_CS=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_FSL is not set
# CONFIG_SERIAL_8250_DW is not set
CONFIG_SERIAL_8250_RT288X=y
# CONFIG_SERIAL_8250_LPSS is not set
CONFIG_SERIAL_8250_MID=y
CONFIG_SERIAL_8250_MOXA=y

#
# Non-8250 serial port support
#
CONFIG_SERIAL_MAX3100=y
CONFIG_SERIAL_MAX310X=y
CONFIG_SERIAL_UARTLITE=y
CONFIG_SERIAL_UARTLITE_CONSOLE=y
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=y
CONFIG_SERIAL_SCCNXP=y
CONFIG_SERIAL_SCCNXP_CONSOLE=y
CONFIG_SERIAL_SC16IS7XX_CORE=y
CONFIG_SERIAL_SC16IS7XX=y
CONFIG_SERIAL_SC16IS7XX_I2C=y
# CONFIG_SERIAL_SC16IS7XX_SPI is not set
CONFIG_SERIAL_TIMBERDALE=y
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
CONFIG_SERIAL_ALTERA_UART=y
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
# CONFIG_SERIAL_ALTERA_UART_CONSOLE is not set
# CONFIG_SERIAL_IFX6X60 is not set
CONFIG_SERIAL_PCH_UART=y
CONFIG_SERIAL_PCH_UART_CONSOLE=y
CONFIG_SERIAL_ARC=y
# CONFIG_SERIAL_ARC_CONSOLE is not set
CONFIG_SERIAL_ARC_NR_PORTS=1
CONFIG_SERIAL_RP2=y
CONFIG_SERIAL_RP2_NR_UARTS=32
CONFIG_SERIAL_FSL_LPUART=y
CONFIG_SERIAL_FSL_LPUART_CONSOLE=y
# CONFIG_SERIAL_MEN_Z135 is not set
CONFIG_TTY_PRINTK=y
CONFIG_PRINTER=y
# CONFIG_LP_CONSOLE is not set
CONFIG_PPDEV=y
CONFIG_HVC_DRIVER=y
CONFIG_VIRTIO_CONSOLE=y
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
# CONFIG_HW_RANDOM_TIMERIOMEM is not set
CONFIG_HW_RANDOM_INTEL=y
# CONFIG_HW_RANDOM_AMD is not set
CONFIG_HW_RANDOM_GEODE=y
CONFIG_HW_RANDOM_VIA=y
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_HW_RANDOM_TPM=y
CONFIG_NVRAM=y
CONFIG_DTLK=y
CONFIG_R3964=y
CONFIG_APPLICOM=y
# CONFIG_SONYPI is not set

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
CONFIG_CARDMAN_4000=y
CONFIG_CARDMAN_4040=y
CONFIG_SCR24X=y
# CONFIG_MWAVE is not set
CONFIG_SCx200_GPIO=y
# CONFIG_PC8736x_GPIO is not set
CONFIG_NSC_GPIO=y
# CONFIG_RAW_DRIVER is not set
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS_CORE=y
CONFIG_TCG_TIS=y
CONFIG_TCG_TIS_SPI=y
CONFIG_TCG_TIS_I2C_ATMEL=y
CONFIG_TCG_TIS_I2C_INFINEON=y
CONFIG_TCG_TIS_I2C_NUVOTON=y
CONFIG_TCG_NSC=y
CONFIG_TCG_ATMEL=y
CONFIG_TCG_INFINEON=y
CONFIG_TCG_CRB=y
CONFIG_TCG_VTPM_PROXY=y
CONFIG_TCG_TIS_ST33ZP24=y
CONFIG_TCG_TIS_ST33ZP24_I2C=y
CONFIG_TCG_TIS_ST33ZP24_SPI=y
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
# CONFIG_XILLYBUS is not set

#
# I2C support
#
CONFIG_I2C=y
# CONFIG_ACPI_I2C_OPREGION is not set
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
# CONFIG_I2C_CHARDEV is not set
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_MUX_GPIO=y
CONFIG_I2C_MUX_PCA9541=y
CONFIG_I2C_MUX_PCA954x=y
CONFIG_I2C_MUX_PINCTRL=y
CONFIG_I2C_MUX_REG=y
# CONFIG_I2C_MUX_MLXCPLD is not set
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=y
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCF=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
CONFIG_I2C_ALI1535=y
CONFIG_I2C_ALI1563=y
CONFIG_I2C_ALI15X3=y
# CONFIG_I2C_AMD756 is not set
CONFIG_I2C_AMD8111=y
CONFIG_I2C_I801=y
CONFIG_I2C_ISCH=y
CONFIG_I2C_ISMT=y
CONFIG_I2C_PIIX4=y
CONFIG_I2C_NFORCE2=y
CONFIG_I2C_NFORCE2_S4985=y
CONFIG_I2C_SIS5595=y
# CONFIG_I2C_SIS630 is not set
CONFIG_I2C_SIS96X=y
# CONFIG_I2C_VIA is not set
CONFIG_I2C_VIAPRO=y

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=y
CONFIG_I2C_DESIGNWARE_CORE=y
CONFIG_I2C_DESIGNWARE_PLATFORM=y
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_DESIGNWARE_BAYTRAIL is not set
CONFIG_I2C_EG20T=y
CONFIG_I2C_EMEV2=y
CONFIG_I2C_GPIO=y
CONFIG_I2C_OCORES=y
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_PARPORT=y
CONFIG_I2C_PARPORT_LIGHT=y
CONFIG_I2C_TAOS_EVM=y

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_ELEKTOR=y
# CONFIG_I2C_PCA_ISA is not set
# CONFIG_SCx200_ACB is not set
CONFIG_I2C_SLAVE=y
CONFIG_I2C_SLAVE_EEPROM=y
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
# CONFIG_SPI_DEBUG is not set
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
CONFIG_SPI_ALTERA=y
CONFIG_SPI_AXI_SPI_ENGINE=y
CONFIG_SPI_BITBANG=y
CONFIG_SPI_BUTTERFLY=y
CONFIG_SPI_CADENCE=y
CONFIG_SPI_DESIGNWARE=y
# CONFIG_SPI_DW_PCI is not set
CONFIG_SPI_DW_MMIO=y
CONFIG_SPI_GPIO=y
CONFIG_SPI_LM70_LLP=y
CONFIG_SPI_OC_TINY=y
# CONFIG_SPI_PXA2XX is not set
# CONFIG_SPI_PXA2XX_PCI is not set
# CONFIG_SPI_ROCKCHIP is not set
CONFIG_SPI_SC18IS602=y
CONFIG_SPI_TOPCLIFF_PCH=y
CONFIG_SPI_XCOMM=y
CONFIG_SPI_XILINX=y
CONFIG_SPI_ZYNQMP_GQSPI=y

#
# SPI Protocol Masters
#
CONFIG_SPI_SPIDEV=y
CONFIG_SPI_TLE62X0=y
CONFIG_SPMI=y
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI controllers
#

#
# HSI clients
#
# CONFIG_HSI_CHAR is not set

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=y
CONFIG_PPS_CLIENT_LDISC=y
# CONFIG_PPS_CLIENT_PARPORT is not set
# CONFIG_PPS_CLIENT_GPIO is not set

#
# PPS generators support
#

#
# PTP clock support
#

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
# CONFIG_PTP_1588_CLOCK_PCH is not set
CONFIG_PINCTRL=y

#
# Pin controllers
#
CONFIG_PINMUX=y
CONFIG_PINCONF=y
CONFIG_GENERIC_PINCONF=y
CONFIG_DEBUG_PINCTRL=y
CONFIG_PINCTRL_AMD=y
CONFIG_PINCTRL_SX150X=y
CONFIG_PINCTRL_BAYTRAIL=y
CONFIG_PINCTRL_CHERRYVIEW=y
CONFIG_PINCTRL_INTEL=y
CONFIG_PINCTRL_BROXTON=y
# CONFIG_PINCTRL_GEMINILAKE is not set
# CONFIG_PINCTRL_SUNRISEPOINT is not set
CONFIG_GPIOLIB=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
CONFIG_DEBUG_GPIO=y
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers
#
CONFIG_GPIO_AMDPT=y
CONFIG_GPIO_AXP209=y
CONFIG_GPIO_DWAPB=y
# CONFIG_GPIO_GENERIC_PLATFORM is not set
CONFIG_GPIO_ICH=y
CONFIG_GPIO_LYNXPOINT=y
CONFIG_GPIO_MENZ127=y
CONFIG_GPIO_MOCKUP=y
# CONFIG_GPIO_VX855 is not set

#
# Port-mapped I/O GPIO drivers
#
# CONFIG_GPIO_104_DIO_48E is not set
# CONFIG_GPIO_104_IDIO_16 is not set
CONFIG_GPIO_104_IDI_48=y
# CONFIG_GPIO_F7188X is not set
# CONFIG_GPIO_GPIO_MM is not set
# CONFIG_GPIO_IT87 is not set
CONFIG_GPIO_SCH=y
CONFIG_GPIO_SCH311X=y
# CONFIG_GPIO_WS16C48 is not set

#
# I2C GPIO expanders
#
CONFIG_GPIO_ADP5588=y
# CONFIG_GPIO_ADP5588_IRQ is not set
CONFIG_GPIO_MAX7300=y
# CONFIG_GPIO_MAX732X is not set
# CONFIG_GPIO_PCA953X is not set
# CONFIG_GPIO_PCF857X is not set
# CONFIG_GPIO_SX150X is not set
CONFIG_GPIO_TPIC2810=y

#
# MFD GPIO expanders
#
CONFIG_GPIO_ADP5520=y
CONFIG_GPIO_ARIZONA=y
CONFIG_GPIO_DA9052=y
CONFIG_GPIO_DA9055=y
CONFIG_GPIO_JANZ_TTL=y
CONFIG_GPIO_LP3943=y
# CONFIG_GPIO_LP873X is not set
# CONFIG_GPIO_PALMAS is not set
CONFIG_GPIO_TIMBERDALE=y
# CONFIG_GPIO_TPS65218 is not set
CONFIG_GPIO_TPS65912=y
CONFIG_GPIO_TWL4030=y
# CONFIG_GPIO_WM831X is not set
CONFIG_GPIO_WM8994=y

#
# PCI GPIO expanders
#
# CONFIG_GPIO_AMD8111 is not set
CONFIG_GPIO_ML_IOH=y
# CONFIG_GPIO_PCH is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders
#
CONFIG_GPIO_MAX7301=y
CONFIG_GPIO_MC33880=y
CONFIG_GPIO_PISOSR=y

#
# SPI or I2C GPIO expanders
#
CONFIG_W1=y

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=y
# CONFIG_W1_MASTER_DS2482 is not set
CONFIG_W1_MASTER_DS1WM=y
CONFIG_W1_MASTER_GPIO=y

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
CONFIG_W1_SLAVE_SMEM=y
CONFIG_W1_SLAVE_DS2408=y
# CONFIG_W1_SLAVE_DS2408_READBACK is not set
CONFIG_W1_SLAVE_DS2413=y
CONFIG_W1_SLAVE_DS2406=y
# CONFIG_W1_SLAVE_DS2423 is not set
CONFIG_W1_SLAVE_DS2431=y
CONFIG_W1_SLAVE_DS2433=y
# CONFIG_W1_SLAVE_DS2433_CRC is not set
CONFIG_W1_SLAVE_DS2760=y
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
# CONFIG_W1_SLAVE_DS28E04 is not set
CONFIG_W1_SLAVE_BQ27000=y
CONFIG_POWER_AVS=y
# CONFIG_POWER_RESET is not set
CONFIG_POWER_SUPPLY=y
CONFIG_POWER_SUPPLY_DEBUG=y
# CONFIG_PDA_POWER is not set
CONFIG_MAX8925_POWER=y
CONFIG_WM831X_BACKUP=y
CONFIG_WM831X_POWER=y
CONFIG_TEST_POWER=y
# CONFIG_BATTERY_DS2760 is not set
CONFIG_BATTERY_DS2780=y
CONFIG_BATTERY_DS2781=y
CONFIG_BATTERY_DS2782=y
CONFIG_BATTERY_SBS=y
# CONFIG_CHARGER_SBS is not set
# CONFIG_BATTERY_BQ27XXX is not set
CONFIG_BATTERY_DA9030=y
CONFIG_BATTERY_DA9052=y
# CONFIG_BATTERY_DA9150 is not set
CONFIG_BATTERY_MAX17040=y
CONFIG_BATTERY_MAX17042=y
CONFIG_CHARGER_MAX8903=y
# CONFIG_CHARGER_LP8727 is not set
CONFIG_CHARGER_GPIO=y
# CONFIG_CHARGER_MANAGER is not set
CONFIG_CHARGER_MAX14577=y
# CONFIG_CHARGER_MAX77693 is not set
CONFIG_CHARGER_BQ2415X=y
CONFIG_CHARGER_BQ24190=y
# CONFIG_CHARGER_BQ24257 is not set
CONFIG_CHARGER_BQ24735=y
CONFIG_CHARGER_BQ25890=y
CONFIG_CHARGER_SMB347=y
CONFIG_BATTERY_GAUGE_LTC2941=y
# CONFIG_BATTERY_GOLDFISH is not set
CONFIG_CHARGER_RT9455=y
# CONFIG_AXP20X_POWER is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_AD7314=y
CONFIG_SENSORS_AD7414=y
# CONFIG_SENSORS_AD7418 is not set
CONFIG_SENSORS_ADM1021=y
CONFIG_SENSORS_ADM1025=y
CONFIG_SENSORS_ADM1026=y
CONFIG_SENSORS_ADM1029=y
CONFIG_SENSORS_ADM1031=y
CONFIG_SENSORS_ADM9240=y
CONFIG_SENSORS_ADT7X10=y
# CONFIG_SENSORS_ADT7310 is not set
CONFIG_SENSORS_ADT7410=y
# CONFIG_SENSORS_ADT7411 is not set
# CONFIG_SENSORS_ADT7462 is not set
# CONFIG_SENSORS_ADT7470 is not set
CONFIG_SENSORS_ADT7475=y
CONFIG_SENSORS_ASC7621=y
CONFIG_SENSORS_K8TEMP=y
CONFIG_SENSORS_K10TEMP=y
CONFIG_SENSORS_FAM15H_POWER=y
# CONFIG_SENSORS_APPLESMC is not set
# CONFIG_SENSORS_ASB100 is not set
# CONFIG_SENSORS_ATXP1 is not set
CONFIG_SENSORS_DS620=y
# CONFIG_SENSORS_DS1621 is not set
CONFIG_SENSORS_DELL_SMM=y
CONFIG_SENSORS_DA9052_ADC=y
CONFIG_SENSORS_DA9055=y
CONFIG_SENSORS_I5K_AMB=y
CONFIG_SENSORS_F71805F=y
CONFIG_SENSORS_F71882FG=y
CONFIG_SENSORS_F75375S=y
# CONFIG_SENSORS_MC13783_ADC is not set
# CONFIG_SENSORS_FSCHMD is not set
# CONFIG_SENSORS_GL518SM is not set
# CONFIG_SENSORS_GL520SM is not set
CONFIG_SENSORS_G760A=y
CONFIG_SENSORS_G762=y
# CONFIG_SENSORS_GPIO_FAN is not set
CONFIG_SENSORS_HIH6130=y
# CONFIG_SENSORS_I5500 is not set
CONFIG_SENSORS_CORETEMP=y
# CONFIG_SENSORS_IT87 is not set
CONFIG_SENSORS_JC42=y
# CONFIG_SENSORS_POWR1220 is not set
CONFIG_SENSORS_LINEAGE=y
CONFIG_SENSORS_LTC2945=y
CONFIG_SENSORS_LTC2990=y
CONFIG_SENSORS_LTC4151=y
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4222=y
# CONFIG_SENSORS_LTC4245 is not set
CONFIG_SENSORS_LTC4260=y
CONFIG_SENSORS_LTC4261=y
CONFIG_SENSORS_MAX1111=y
# CONFIG_SENSORS_MAX16065 is not set
CONFIG_SENSORS_MAX1619=y
CONFIG_SENSORS_MAX1668=y
CONFIG_SENSORS_MAX197=y
CONFIG_SENSORS_MAX31722=y
CONFIG_SENSORS_MAX6639=y
CONFIG_SENSORS_MAX6642=y
# CONFIG_SENSORS_MAX6650 is not set
CONFIG_SENSORS_MAX6697=y
CONFIG_SENSORS_MAX31790=y
CONFIG_SENSORS_MCP3021=y
CONFIG_SENSORS_TC654=y
CONFIG_SENSORS_ADCXX=y
CONFIG_SENSORS_LM63=y
CONFIG_SENSORS_LM70=y
# CONFIG_SENSORS_LM73 is not set
# CONFIG_SENSORS_LM75 is not set
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
CONFIG_SENSORS_LM80=y
CONFIG_SENSORS_LM83=y
CONFIG_SENSORS_LM85=y
# CONFIG_SENSORS_LM87 is not set
CONFIG_SENSORS_LM90=y
CONFIG_SENSORS_LM92=y
CONFIG_SENSORS_LM93=y
CONFIG_SENSORS_LM95234=y
# CONFIG_SENSORS_LM95241 is not set
CONFIG_SENSORS_LM95245=y
# CONFIG_SENSORS_PC87360 is not set
CONFIG_SENSORS_PC87427=y
CONFIG_SENSORS_NTC_THERMISTOR=y
# CONFIG_SENSORS_NCT6683 is not set
# CONFIG_SENSORS_NCT6775 is not set
# CONFIG_SENSORS_NCT7802 is not set
CONFIG_SENSORS_NCT7904=y
CONFIG_SENSORS_PCF8591=y
CONFIG_PMBUS=y
# CONFIG_SENSORS_PMBUS is not set
CONFIG_SENSORS_ADM1275=y
CONFIG_SENSORS_LM25066=y
# CONFIG_SENSORS_LTC2978 is not set
CONFIG_SENSORS_LTC3815=y
CONFIG_SENSORS_MAX16064=y
# CONFIG_SENSORS_MAX20751 is not set
# CONFIG_SENSORS_MAX34440 is not set
# CONFIG_SENSORS_MAX8688 is not set
CONFIG_SENSORS_TPS40422=y
CONFIG_SENSORS_UCD9000=y
CONFIG_SENSORS_UCD9200=y
CONFIG_SENSORS_ZL6100=y
# CONFIG_SENSORS_SHT15 is not set
# CONFIG_SENSORS_SHT21 is not set
CONFIG_SENSORS_SHT3x=y
# CONFIG_SENSORS_SHTC1 is not set
CONFIG_SENSORS_SIS5595=y
# CONFIG_SENSORS_DME1737 is not set
CONFIG_SENSORS_EMC1403=y
# CONFIG_SENSORS_EMC2103 is not set
# CONFIG_SENSORS_EMC6W201 is not set
CONFIG_SENSORS_SMSC47M1=y
# CONFIG_SENSORS_SMSC47M192 is not set
# CONFIG_SENSORS_SMSC47B397 is not set
# CONFIG_SENSORS_SCH56XX_COMMON is not set
# CONFIG_SENSORS_STTS751 is not set
CONFIG_SENSORS_SMM665=y
CONFIG_SENSORS_ADC128D818=y
CONFIG_SENSORS_ADS1015=y
# CONFIG_SENSORS_ADS7828 is not set
# CONFIG_SENSORS_ADS7871 is not set
CONFIG_SENSORS_AMC6821=y
CONFIG_SENSORS_INA209=y
CONFIG_SENSORS_INA2XX=y
# CONFIG_SENSORS_INA3221 is not set
CONFIG_SENSORS_TC74=y
# CONFIG_SENSORS_THMC50 is not set
# CONFIG_SENSORS_TMP102 is not set
CONFIG_SENSORS_TMP103=y
CONFIG_SENSORS_TMP108=y
CONFIG_SENSORS_TMP401=y
# CONFIG_SENSORS_TMP421 is not set
# CONFIG_SENSORS_VIA_CPUTEMP is not set
CONFIG_SENSORS_VIA686A=y
CONFIG_SENSORS_VT1211=y
CONFIG_SENSORS_VT8231=y
# CONFIG_SENSORS_W83781D is not set
CONFIG_SENSORS_W83791D=y
CONFIG_SENSORS_W83792D=y
# CONFIG_SENSORS_W83793 is not set
# CONFIG_SENSORS_W83795 is not set
# CONFIG_SENSORS_W83L785TS is not set
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=y
CONFIG_SENSORS_W83627EHF=y
CONFIG_SENSORS_WM831X=y

#
# ACPI drivers
#
CONFIG_SENSORS_ACPI_POWER=y
CONFIG_SENSORS_ATK0110=y
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_WRITABLE_TRIPS=y
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR=y
CONFIG_THERMAL_GOV_FAIR_SHARE=y
CONFIG_THERMAL_GOV_STEP_WISE=y
CONFIG_THERMAL_GOV_BANG_BANG=y
CONFIG_THERMAL_GOV_USER_SPACE=y
CONFIG_THERMAL_GOV_POWER_ALLOCATOR=y
# CONFIG_THERMAL_EMULATION is not set
CONFIG_INTEL_POWERCLAMP=y
CONFIG_INTEL_SOC_DTS_IOSF_CORE=y
CONFIG_INTEL_SOC_DTS_THERMAL=y
CONFIG_INTEL_QUARK_DTS_THERMAL=y

#
# ACPI INT340X thermal drivers
#
CONFIG_INT340X_THERMAL=y
CONFIG_ACPI_THERMAL_REL=y
# CONFIG_INT3406_THERMAL is not set
CONFIG_INTEL_PCH_THERMAL=y
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
# CONFIG_SSB_B43_PCI_BRIDGE is not set
CONFIG_SSB_PCMCIAHOST_POSSIBLE=y
# CONFIG_SSB_PCMCIAHOST is not set
CONFIG_SSB_SDIOHOST_POSSIBLE=y
CONFIG_SSB_SDIOHOST=y
# CONFIG_SSB_SILENT is not set
CONFIG_SSB_DEBUG=y
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
# CONFIG_SSB_DRIVER_PCICORE is not set
# CONFIG_SSB_DRIVER_GPIO is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
# CONFIG_BCMA_HOST_SOC is not set
CONFIG_BCMA_DRIVER_PCI=y
# CONFIG_BCMA_DRIVER_GMAC_CMN is not set
# CONFIG_BCMA_DRIVER_GPIO is not set
# CONFIG_BCMA_DEBUG is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_CS5535 is not set
# CONFIG_MFD_AS3711 is not set
CONFIG_PMIC_ADP5520=y
# CONFIG_MFD_AAT2870_CORE is not set
CONFIG_MFD_BCM590XX=y
CONFIG_MFD_AXP20X=y
CONFIG_MFD_AXP20X_I2C=y
# CONFIG_MFD_CROS_EC is not set
CONFIG_PMIC_DA903X=y
CONFIG_PMIC_DA9052=y
# CONFIG_MFD_DA9052_SPI is not set
CONFIG_MFD_DA9052_I2C=y
CONFIG_MFD_DA9055=y
CONFIG_MFD_DA9062=y
# CONFIG_MFD_DA9063 is not set
CONFIG_MFD_DA9150=y
CONFIG_MFD_MC13XXX=y
# CONFIG_MFD_MC13XXX_SPI is not set
CONFIG_MFD_MC13XXX_I2C=y
# CONFIG_HTC_PASIC3 is not set
# CONFIG_HTC_I2CPLD is not set
CONFIG_MFD_INTEL_QUARK_I2C_GPIO=y
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=y
# CONFIG_INTEL_SOC_PMIC is not set
# CONFIG_MFD_INTEL_LPSS_ACPI is not set
# CONFIG_MFD_INTEL_LPSS_PCI is not set
CONFIG_MFD_JANZ_CMODIO=y
# CONFIG_MFD_KEMPLD is not set
CONFIG_MFD_88PM800=y
CONFIG_MFD_88PM805=y
# CONFIG_MFD_88PM860X is not set
CONFIG_MFD_MAX14577=y
CONFIG_MFD_MAX77693=y
CONFIG_MFD_MAX77843=y
CONFIG_MFD_MAX8907=y
CONFIG_MFD_MAX8925=y
CONFIG_MFD_MAX8997=y
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_MT6397 is not set
# CONFIG_MFD_MENF21BMC is not set
# CONFIG_EZX_PCAP is not set
CONFIG_MFD_RETU=y
# CONFIG_MFD_PCF50633 is not set
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
# CONFIG_MFD_RT5033 is not set
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_SI476X_CORE is not set
CONFIG_MFD_SM501=y
CONFIG_MFD_SM501_GPIO=y
CONFIG_MFD_SKY81452=y
CONFIG_MFD_SMSC=y
# CONFIG_ABX500_CORE is not set
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=y
CONFIG_MFD_LP3943=y
CONFIG_MFD_LP8788=y
CONFIG_MFD_PALMAS=y
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=y
# CONFIG_MFD_TPS65086 is not set
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_TPS65217 is not set
CONFIG_MFD_TI_LP873X=y
CONFIG_MFD_TPS65218=y
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS65910 is not set
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
CONFIG_MFD_TPS65912_SPI=y
CONFIG_MFD_TPS80031=y
CONFIG_TWL4030_CORE=y
# CONFIG_MFD_TWL4030_AUDIO is not set
# CONFIG_TWL6040_CORE is not set
CONFIG_MFD_WL1273_CORE=y
# CONFIG_MFD_LM3533 is not set
CONFIG_MFD_TIMBERDALE=y
# CONFIG_MFD_TMIO is not set
CONFIG_MFD_VX855=y
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
CONFIG_MFD_ARIZONA_SPI=y
# CONFIG_MFD_CS47L24 is not set
# CONFIG_MFD_WM5102 is not set
CONFIG_MFD_WM5110=y
CONFIG_MFD_WM8997=y
CONFIG_MFD_WM8998=y
# CONFIG_MFD_WM8400 is not set
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
CONFIG_MFD_WM831X_SPI=y
# CONFIG_MFD_WM8350_I2C is not set
CONFIG_MFD_WM8994=y
CONFIG_REGULATOR=y
CONFIG_REGULATOR_DEBUG=y
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
# CONFIG_REGULATOR_88PM800 is not set
# CONFIG_REGULATOR_ACT8865 is not set
CONFIG_REGULATOR_AD5398=y
CONFIG_REGULATOR_ANATOP=y
CONFIG_REGULATOR_AXP20X=y
CONFIG_REGULATOR_BCM590XX=y
CONFIG_REGULATOR_DA903X=y
CONFIG_REGULATOR_DA9052=y
# CONFIG_REGULATOR_DA9055 is not set
CONFIG_REGULATOR_DA9062=y
CONFIG_REGULATOR_DA9210=y
CONFIG_REGULATOR_DA9211=y
CONFIG_REGULATOR_FAN53555=y
CONFIG_REGULATOR_GPIO=y
CONFIG_REGULATOR_ISL9305=y
CONFIG_REGULATOR_ISL6271A=y
CONFIG_REGULATOR_LP3971=y
# CONFIG_REGULATOR_LP3972 is not set
# CONFIG_REGULATOR_LP872X is not set
CONFIG_REGULATOR_LP8755=y
# CONFIG_REGULATOR_LP8788 is not set
CONFIG_REGULATOR_LTC3589=y
CONFIG_REGULATOR_LTC3676=y
# CONFIG_REGULATOR_MAX14577 is not set
# CONFIG_REGULATOR_MAX1586 is not set
# CONFIG_REGULATOR_MAX8649 is not set
CONFIG_REGULATOR_MAX8660=y
CONFIG_REGULATOR_MAX8907=y
# CONFIG_REGULATOR_MAX8925 is not set
CONFIG_REGULATOR_MAX8952=y
# CONFIG_REGULATOR_MAX8997 is not set
CONFIG_REGULATOR_MAX77693=y
CONFIG_REGULATOR_MC13XXX_CORE=y
CONFIG_REGULATOR_MC13783=y
# CONFIG_REGULATOR_MC13892 is not set
# CONFIG_REGULATOR_MT6311 is not set
CONFIG_REGULATOR_PALMAS=y
CONFIG_REGULATOR_PFUZE100=y
CONFIG_REGULATOR_PV88060=y
CONFIG_REGULATOR_PV88080=y
# CONFIG_REGULATOR_PV88090 is not set
CONFIG_REGULATOR_QCOM_SPMI=y
# CONFIG_REGULATOR_SKY81452 is not set
# CONFIG_REGULATOR_TPS51632 is not set
CONFIG_REGULATOR_TPS6105X=y
# CONFIG_REGULATOR_TPS62360 is not set
# CONFIG_REGULATOR_TPS65023 is not set
CONFIG_REGULATOR_TPS6507X=y
CONFIG_REGULATOR_TPS6524X=y
# CONFIG_REGULATOR_TPS65912 is not set
CONFIG_REGULATOR_TPS80031=y
CONFIG_REGULATOR_TWL4030=y
CONFIG_REGULATOR_WM831X=y
# CONFIG_REGULATOR_WM8994 is not set
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
# CONFIG_MEDIA_ANALOG_TV_SUPPORT is not set
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
CONFIG_MEDIA_RADIO_SUPPORT=y
# CONFIG_MEDIA_SDR_SUPPORT is not set
CONFIG_MEDIA_RC_SUPPORT=y
CONFIG_MEDIA_CEC_SUPPORT=y
# CONFIG_MEDIA_CEC_DEBUG is not set
CONFIG_MEDIA_CEC_EDID=y
CONFIG_MEDIA_CONTROLLER=y
# CONFIG_MEDIA_CONTROLLER_DVB is not set
CONFIG_VIDEO_DEV=y
# CONFIG_VIDEO_V4L2_SUBDEV_API is not set
CONFIG_VIDEO_V4L2=y
# CONFIG_VIDEO_ADV_DEBUG is not set
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_VIDEO_PCI_SKELETON=y
CONFIG_VIDEO_TUNER=y
CONFIG_VIDEOBUF_GEN=y
CONFIG_VIDEOBUF_DMA_SG=y
CONFIG_VIDEOBUF_VMALLOC=y
CONFIG_VIDEOBUF2_CORE=y
CONFIG_VIDEOBUF2_MEMOPS=y
CONFIG_VIDEOBUF2_DMA_CONTIG=y
CONFIG_VIDEOBUF2_VMALLOC=y
CONFIG_VIDEOBUF2_DMA_SG=y
CONFIG_VIDEOBUF2_DVB=y
CONFIG_DVB_CORE=y
CONFIG_TTPCI_EEPROM=y
CONFIG_DVB_MAX_ADAPTERS=16
CONFIG_DVB_DYNAMIC_MINORS=y
CONFIG_DVB_DEMUX_SECTION_LOSS_LOG=y

#
# Media drivers
#
CONFIG_RC_CORE=y
# CONFIG_RC_MAP is not set
CONFIG_RC_DECODERS=y
CONFIG_LIRC=y
CONFIG_IR_LIRC_CODEC=y
CONFIG_IR_NEC_DECODER=y
CONFIG_IR_RC5_DECODER=y
# CONFIG_IR_RC6_DECODER is not set
CONFIG_IR_JVC_DECODER=y
CONFIG_IR_SONY_DECODER=y
CONFIG_IR_SANYO_DECODER=y
CONFIG_IR_SHARP_DECODER=y
CONFIG_IR_MCE_KBD_DECODER=y
# CONFIG_IR_XMP_DECODER is not set
# CONFIG_RC_DEVICES is not set
CONFIG_MEDIA_PCI_SUPPORT=y

#
# Media capture support
#
CONFIG_VIDEO_TW5864=y
CONFIG_VIDEO_TW68=y
CONFIG_VIDEO_ZORAN=y
CONFIG_VIDEO_ZORAN_DC30=y
CONFIG_VIDEO_ZORAN_ZR36060=y
CONFIG_VIDEO_ZORAN_BUZ=y
CONFIG_VIDEO_ZORAN_DC10=y
CONFIG_VIDEO_ZORAN_LML33=y
CONFIG_VIDEO_ZORAN_LML33R10=y
CONFIG_VIDEO_ZORAN_AVS6EYES=y

#
# Media capture/analog/hybrid TV support
#
CONFIG_VIDEO_CX18=y
CONFIG_VIDEO_CX25821=y
# CONFIG_VIDEO_CX88 is not set
CONFIG_VIDEO_BT848=y
# CONFIG_DVB_BT8XX is not set
CONFIG_VIDEO_SAA7134=y
# CONFIG_VIDEO_SAA7134_RC is not set
CONFIG_VIDEO_SAA7134_DVB=y
CONFIG_VIDEO_SAA7164=y

#
# Media digital TV PCI Adapters
#
CONFIG_DVB_AV7110_IR=y
CONFIG_DVB_AV7110=y
CONFIG_DVB_AV7110_OSD=y
# CONFIG_DVB_BUDGET_CORE is not set
CONFIG_DVB_B2C2_FLEXCOP_PCI=y
CONFIG_DVB_B2C2_FLEXCOP_PCI_DEBUG=y
# CONFIG_DVB_PLUTO2 is not set
CONFIG_DVB_DM1105=y
CONFIG_DVB_PT1=y
CONFIG_DVB_PT3=y
CONFIG_MANTIS_CORE=y
CONFIG_DVB_MANTIS=y
# CONFIG_DVB_HOPPER is not set
CONFIG_DVB_NGENE=y
CONFIG_DVB_DDBRIDGE=y
CONFIG_DVB_SMIPCIE=y
CONFIG_DVB_NETUP_UNIDVB=y
# CONFIG_V4L_PLATFORM_DRIVERS is not set
# CONFIG_V4L_MEM2MEM_DRIVERS is not set
CONFIG_V4L_TEST_DRIVERS=y
CONFIG_VIDEO_VIVID=y
CONFIG_VIDEO_VIVID_CEC=y
CONFIG_VIDEO_VIVID_MAX_DEVS=64
# CONFIG_VIDEO_VIM2M is not set
CONFIG_DVB_PLATFORM_DRIVERS=y

#
# Supported MMC/SDIO adapters
#
CONFIG_SMS_SDIO_DRV=y
CONFIG_RADIO_ADAPTERS=y
CONFIG_RADIO_TEA575X=y
# CONFIG_RADIO_SI470X is not set
# CONFIG_RADIO_SI4713 is not set
CONFIG_RADIO_MAXIRADIO=y
CONFIG_RADIO_TEA5764=y
# CONFIG_RADIO_TEA5764_XTAL is not set
CONFIG_RADIO_SAA7706H=y
CONFIG_RADIO_TEF6862=y
CONFIG_RADIO_TIMBERDALE=y
# CONFIG_RADIO_WL1273 is not set

#
# Texas Instruments WL128x FM driver (ST based)
#
CONFIG_V4L_RADIO_ISA_DRIVERS=y
CONFIG_RADIO_ISA=y
# CONFIG_RADIO_CADET is not set
# CONFIG_RADIO_RTRACK is not set
# CONFIG_RADIO_RTRACK2 is not set
CONFIG_RADIO_AZTECH=y
CONFIG_RADIO_AZTECH_PORT=350
CONFIG_RADIO_GEMTEK=y
CONFIG_RADIO_GEMTEK_PORT=34c
CONFIG_RADIO_GEMTEK_PROBE=y
# CONFIG_RADIO_SF16FMI is not set
# CONFIG_RADIO_SF16FMR2 is not set
CONFIG_RADIO_TERRATEC=y
CONFIG_RADIO_TRUST=y
CONFIG_RADIO_TRUST_PORT=350
CONFIG_RADIO_TYPHOON=y
CONFIG_RADIO_TYPHOON_PORT=316
CONFIG_RADIO_TYPHOON_MUTEFREQ=87500
# CONFIG_RADIO_ZOLTRIX is not set

#
# Supported FireWire (IEEE 1394) Adapters
#
CONFIG_DVB_FIREDTV=y
CONFIG_DVB_FIREDTV_INPUT=y
CONFIG_MEDIA_COMMON_OPTIONS=y

#
# common driver options
#
CONFIG_VIDEO_CX2341X=y
CONFIG_VIDEO_TVEEPROM=y
CONFIG_DVB_B2C2_FLEXCOP=y
CONFIG_DVB_B2C2_FLEXCOP_DEBUG=y
CONFIG_VIDEO_SAA7146=y
CONFIG_VIDEO_SAA7146_VV=y
CONFIG_SMS_SIANO_MDTV=y
# CONFIG_SMS_SIANO_RC is not set
CONFIG_VIDEO_V4L2_TPG=y

#
# Media ancillary drivers (tuners, sensors, i2c, spi, frontends)
#
# CONFIG_MEDIA_SUBDRV_AUTOSELECT is not set
CONFIG_VIDEO_IR_I2C=y

#
# I2C Encoders, decoders, sensors and other helper chips
#

#
# Audio decoders, processors and mixers
#
CONFIG_VIDEO_TVAUDIO=y
CONFIG_VIDEO_TDA7432=y
CONFIG_VIDEO_TDA9840=y
CONFIG_VIDEO_TEA6415C=y
CONFIG_VIDEO_TEA6420=y
CONFIG_VIDEO_MSP3400=y
CONFIG_VIDEO_CS3308=y
CONFIG_VIDEO_CS5345=y
CONFIG_VIDEO_CS53L32A=y
CONFIG_VIDEO_TLV320AIC23B=y
CONFIG_VIDEO_UDA1342=y
CONFIG_VIDEO_WM8775=y
CONFIG_VIDEO_WM8739=y
# CONFIG_VIDEO_VP27SMPX is not set
CONFIG_VIDEO_SONY_BTF_MPX=y

#
# RDS decoders
#
CONFIG_VIDEO_SAA6588=y

#
# Video decoders
#
CONFIG_VIDEO_ADV7183=y
CONFIG_VIDEO_BT819=y
# CONFIG_VIDEO_BT856 is not set
CONFIG_VIDEO_BT866=y
CONFIG_VIDEO_KS0127=y
CONFIG_VIDEO_ML86V7667=y
# CONFIG_VIDEO_AD5820 is not set
CONFIG_VIDEO_SAA7110=y
CONFIG_VIDEO_SAA711X=y
CONFIG_VIDEO_TVP514X=y
CONFIG_VIDEO_TVP5150=y
CONFIG_VIDEO_TVP7002=y
# CONFIG_VIDEO_TW2804 is not set
# CONFIG_VIDEO_TW9903 is not set
CONFIG_VIDEO_TW9906=y
CONFIG_VIDEO_VPX3220=y

#
# Video and audio decoders
#
CONFIG_VIDEO_SAA717X=y
CONFIG_VIDEO_CX25840=y

#
# Video encoders
#
# CONFIG_VIDEO_SAA7127 is not set
CONFIG_VIDEO_SAA7185=y
CONFIG_VIDEO_ADV7170=y
# CONFIG_VIDEO_ADV7175 is not set
CONFIG_VIDEO_ADV7343=y
# CONFIG_VIDEO_ADV7393 is not set
CONFIG_VIDEO_AK881X=y
CONFIG_VIDEO_THS8200=y

#
# Camera sensor devices
#
CONFIG_VIDEO_OV2659=y
CONFIG_VIDEO_OV7640=y
CONFIG_VIDEO_OV7670=y
CONFIG_VIDEO_VS6624=y
CONFIG_VIDEO_MT9M111=y
CONFIG_VIDEO_MT9V011=y
# CONFIG_VIDEO_SR030PC30 is not set

#
# Flash devices
#
# CONFIG_VIDEO_ADP1653 is not set
CONFIG_VIDEO_AS3645A=y
# CONFIG_VIDEO_LM3560 is not set
# CONFIG_VIDEO_LM3646 is not set

#
# Video improvement chips
#
CONFIG_VIDEO_UPD64031A=y
CONFIG_VIDEO_UPD64083=y

#
# Audio/Video compression chips
#
# CONFIG_VIDEO_SAA6752HS is not set

#
# Miscellaneous helper chips
#
CONFIG_VIDEO_THS7303=y
# CONFIG_VIDEO_M52790 is not set

#
# Sensors used on soc_camera driver
#

#
# SPI helper chips
#
CONFIG_MEDIA_TUNER=y

#
# Customize TV tuners
#
# CONFIG_MEDIA_TUNER_SIMPLE is not set
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
CONFIG_MEDIA_TUNER_TDA9887=y
# CONFIG_MEDIA_TUNER_TEA5761 is not set
CONFIG_MEDIA_TUNER_TEA5767=y
CONFIG_MEDIA_TUNER_MSI001=y
# CONFIG_MEDIA_TUNER_MT20XX is not set
CONFIG_MEDIA_TUNER_MT2060=y
CONFIG_MEDIA_TUNER_MT2063=y
CONFIG_MEDIA_TUNER_MT2266=y
# CONFIG_MEDIA_TUNER_MT2131 is not set
# CONFIG_MEDIA_TUNER_QT1010 is not set
CONFIG_MEDIA_TUNER_XC2028=y
# CONFIG_MEDIA_TUNER_XC5000 is not set
# CONFIG_MEDIA_TUNER_XC4000 is not set
CONFIG_MEDIA_TUNER_MXL5005S=y
CONFIG_MEDIA_TUNER_MXL5007T=y
CONFIG_MEDIA_TUNER_MC44S803=y
CONFIG_MEDIA_TUNER_MAX2165=y
CONFIG_MEDIA_TUNER_TDA18218=y
# CONFIG_MEDIA_TUNER_FC0011 is not set
# CONFIG_MEDIA_TUNER_FC0012 is not set
# CONFIG_MEDIA_TUNER_FC0013 is not set
# CONFIG_MEDIA_TUNER_TDA18212 is not set
# CONFIG_MEDIA_TUNER_E4000 is not set
CONFIG_MEDIA_TUNER_FC2580=y
CONFIG_MEDIA_TUNER_M88RS6000T=y
# CONFIG_MEDIA_TUNER_TUA9001 is not set
CONFIG_MEDIA_TUNER_SI2157=y
CONFIG_MEDIA_TUNER_IT913X=y
# CONFIG_MEDIA_TUNER_R820T is not set
CONFIG_MEDIA_TUNER_MXL301RF=y
CONFIG_MEDIA_TUNER_QM1D1C0042=y

#
# Customise DVB Frontends
#

#
# Multistandard (satellite) frontends
#
CONFIG_DVB_STB0899=y
CONFIG_DVB_STB6100=y
CONFIG_DVB_STV090x=y
CONFIG_DVB_STV6110x=y
CONFIG_DVB_M88DS3103=y

#
# Multistandard (cable + terrestrial) frontends
#
CONFIG_DVB_DRXK=y
CONFIG_DVB_TDA18271C2DD=y
CONFIG_DVB_SI2165=y
CONFIG_DVB_MN88472=y
CONFIG_DVB_MN88473=y

#
# DVB-S (satellite) frontends
#
# CONFIG_DVB_CX24110 is not set
CONFIG_DVB_CX24123=y
# CONFIG_DVB_MT312 is not set
CONFIG_DVB_ZL10036=y
CONFIG_DVB_ZL10039=y
# CONFIG_DVB_S5H1420 is not set
CONFIG_DVB_STV0288=y
CONFIG_DVB_STB6000=y
# CONFIG_DVB_STV0299 is not set
CONFIG_DVB_STV6110=y
CONFIG_DVB_STV0900=y
CONFIG_DVB_TDA8083=y
CONFIG_DVB_TDA10086=y
# CONFIG_DVB_TDA8261 is not set
# CONFIG_DVB_VES1X93 is not set
CONFIG_DVB_TUNER_ITD1000=y
CONFIG_DVB_TUNER_CX24113=y
# CONFIG_DVB_TDA826X is not set
CONFIG_DVB_TUA6100=y
# CONFIG_DVB_CX24116 is not set
# CONFIG_DVB_CX24117 is not set
CONFIG_DVB_CX24120=y
# CONFIG_DVB_SI21XX is not set
CONFIG_DVB_TS2020=y
# CONFIG_DVB_DS3000 is not set
# CONFIG_DVB_MB86A16 is not set
CONFIG_DVB_TDA10071=y

#
# DVB-T (terrestrial) frontends
#
CONFIG_DVB_SP8870=y
# CONFIG_DVB_SP887X is not set
# CONFIG_DVB_CX22700 is not set
CONFIG_DVB_CX22702=y
CONFIG_DVB_S5H1432=y
CONFIG_DVB_DRXD=y
# CONFIG_DVB_L64781 is not set
# CONFIG_DVB_TDA1004X is not set
CONFIG_DVB_NXT6000=y
CONFIG_DVB_MT352=y
CONFIG_DVB_ZL10353=y
# CONFIG_DVB_DIB3000MB is not set
CONFIG_DVB_DIB3000MC=y
CONFIG_DVB_DIB7000M=y
CONFIG_DVB_DIB7000P=y
CONFIG_DVB_DIB9000=y
CONFIG_DVB_TDA10048=y
CONFIG_DVB_AF9013=y
CONFIG_DVB_EC100=y
# CONFIG_DVB_STV0367 is not set
CONFIG_DVB_CXD2820R=y
# CONFIG_DVB_CXD2841ER is not set
CONFIG_DVB_RTL2830=y
CONFIG_DVB_RTL2832=y
# CONFIG_DVB_SI2168 is not set
# CONFIG_DVB_AS102_FE is not set
CONFIG_DVB_ZD1301_DEMOD=y
# CONFIG_DVB_GP8PSK_FE is not set

#
# DVB-C (cable) frontends
#
CONFIG_DVB_VES1820=y
CONFIG_DVB_TDA10021=y
# CONFIG_DVB_TDA10023 is not set
# CONFIG_DVB_STV0297 is not set

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
CONFIG_DVB_NXT200X=y
CONFIG_DVB_OR51211=y
CONFIG_DVB_OR51132=y
CONFIG_DVB_BCM3510=y
CONFIG_DVB_LGDT330X=y
# CONFIG_DVB_LGDT3305 is not set
CONFIG_DVB_LGDT3306A=y
CONFIG_DVB_LG2160=y
# CONFIG_DVB_S5H1409 is not set
CONFIG_DVB_AU8522=y
CONFIG_DVB_AU8522_DTV=y
# CONFIG_DVB_AU8522_V4L is not set
CONFIG_DVB_S5H1411=y

#
# ISDB-T (terrestrial) frontends
#
CONFIG_DVB_S921=y
CONFIG_DVB_DIB8000=y
# CONFIG_DVB_MB86A20S is not set

#
# ISDB-S (satellite) & ISDB-T (terrestrial) frontends
#
CONFIG_DVB_TC90522=y

#
# Digital terrestrial only tuners/PLL
#
CONFIG_DVB_PLL=y
CONFIG_DVB_TUNER_DIB0070=y
# CONFIG_DVB_TUNER_DIB0090 is not set

#
# SEC control devices for DVB-S
#
# CONFIG_DVB_DRX39XYJ is not set
# CONFIG_DVB_LNBH25 is not set
# CONFIG_DVB_LNBP21 is not set
CONFIG_DVB_LNBP22=y
CONFIG_DVB_ISL6405=y
CONFIG_DVB_ISL6421=y
# CONFIG_DVB_ISL6423 is not set
CONFIG_DVB_A8293=y
# CONFIG_DVB_SP2 is not set
CONFIG_DVB_LGS8GL5=y
# CONFIG_DVB_LGS8GXX is not set
CONFIG_DVB_ATBM8830=y
CONFIG_DVB_TDA665x=y
# CONFIG_DVB_IX2505V is not set
# CONFIG_DVB_M88RS2000 is not set
# CONFIG_DVB_AF9033 is not set
# CONFIG_DVB_HORUS3A is not set
CONFIG_DVB_ASCOT2E=y
CONFIG_DVB_HELENE=y

#
# Tools to develop new frontends
#
CONFIG_DVB_DUMMY_FE=y

#
# Graphics support
#
CONFIG_AGP=y
CONFIG_AGP_ALI=y
CONFIG_AGP_ATI=y
CONFIG_AGP_AMD=y
CONFIG_AGP_AMD64=y
CONFIG_AGP_INTEL=y
# CONFIG_AGP_NVIDIA is not set
# CONFIG_AGP_SIS is not set
CONFIG_AGP_SWORKS=y
# CONFIG_AGP_VIA is not set
# CONFIG_AGP_EFFICEON is not set
CONFIG_INTEL_GTT=y
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
CONFIG_VGA_SWITCHEROO=y
CONFIG_DRM=y
CONFIG_DRM_MIPI_DSI=y
CONFIG_DRM_DP_AUX_CHARDEV=y
# CONFIG_DRM_DEBUG_MM is not set
CONFIG_DRM_KMS_HELPER=y
# CONFIG_DRM_FBDEV_EMULATION is not set
CONFIG_DRM_LOAD_EDID_FIRMWARE=y
CONFIG_DRM_TTM=y

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_CH7006=y
CONFIG_DRM_I2C_SIL164=y
CONFIG_DRM_I2C_NXP_TDA998X=y
CONFIG_DRM_RADEON=y
CONFIG_DRM_RADEON_USERPTR=y
# CONFIG_DRM_AMDGPU is not set

#
# ACP (Audio CoProcessor) Configuration
#
# CONFIG_DRM_NOUVEAU is not set
CONFIG_DRM_I915=y
# CONFIG_DRM_I915_ALPHA_SUPPORT is not set
CONFIG_DRM_I915_CAPTURE_ERROR=y
# CONFIG_DRM_I915_COMPRESS_ERROR is not set
# CONFIG_DRM_I915_USERPTR is not set

#
# drm/i915 Debugging
#
CONFIG_DRM_I915_WERROR=y
# CONFIG_DRM_I915_DEBUG is not set
CONFIG_DRM_I915_DEBUG_GEM=y
CONFIG_DRM_VGEM=y
CONFIG_DRM_VMWGFX=y
# CONFIG_DRM_VMWGFX_FBCON is not set
CONFIG_DRM_GMA500=y
# CONFIG_DRM_GMA600 is not set
CONFIG_DRM_GMA3600=y
# CONFIG_DRM_UDL is not set
CONFIG_DRM_AST=y
CONFIG_DRM_MGAG200=y
CONFIG_DRM_CIRRUS_QEMU=y
# CONFIG_DRM_QXL is not set
# CONFIG_DRM_BOCHS is not set
CONFIG_DRM_VIRTIO_GPU=y
CONFIG_DRM_PANEL=y

#
# Display Panels
#
CONFIG_DRM_BRIDGE=y

#
# Display Interface Bridges
#
CONFIG_DRM_ANALOGIX_ANX78XX=y
# CONFIG_DRM_HISI_HIBMC is not set
# CONFIG_DRM_LEGACY is not set

#
# Frame buffer Devices
#
CONFIG_FB=y
CONFIG_FIRMWARE_EDID=y
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
CONFIG_FB_DDC=y
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
CONFIG_FB_FOREIGN_ENDIAN=y
CONFIG_FB_BOTH_ENDIAN=y
# CONFIG_FB_BIG_ENDIAN is not set
# CONFIG_FB_LITTLE_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=y
CONFIG_FB_SVGALIB=y
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
CONFIG_FB_CIRRUS=y
CONFIG_FB_PM2=y
CONFIG_FB_PM2_FIFO_DISCONNECT=y
CONFIG_FB_CYBER2000=y
CONFIG_FB_CYBER2000_DDC=y
CONFIG_FB_ARC=y
# CONFIG_FB_ASILIANT is not set
CONFIG_FB_IMSTT=y
# CONFIG_FB_VGA16 is not set
CONFIG_FB_VESA=y
CONFIG_FB_N411=y
CONFIG_FB_HGA=y
CONFIG_FB_OPENCORES=y
CONFIG_FB_S1D13XXX=y
CONFIG_FB_NVIDIA=y
CONFIG_FB_NVIDIA_I2C=y
# CONFIG_FB_NVIDIA_DEBUG is not set
CONFIG_FB_NVIDIA_BACKLIGHT=y
CONFIG_FB_RIVA=y
CONFIG_FB_RIVA_I2C=y
# CONFIG_FB_RIVA_DEBUG is not set
CONFIG_FB_RIVA_BACKLIGHT=y
CONFIG_FB_I740=y
CONFIG_FB_I810=y
CONFIG_FB_I810_GTF=y
# CONFIG_FB_I810_I2C is not set
CONFIG_FB_LE80578=y
# CONFIG_FB_CARILLO_RANCH is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
CONFIG_FB_ATY=y
CONFIG_FB_ATY_CT=y
CONFIG_FB_ATY_GENERIC_LCD=y
# CONFIG_FB_ATY_GX is not set
# CONFIG_FB_ATY_BACKLIGHT is not set
CONFIG_FB_S3=y
CONFIG_FB_S3_DDC=y
CONFIG_FB_SAVAGE=y
CONFIG_FB_SAVAGE_I2C=y
CONFIG_FB_SAVAGE_ACCEL=y
CONFIG_FB_SIS=y
CONFIG_FB_SIS_300=y
CONFIG_FB_SIS_315=y
CONFIG_FB_VIA=y
# CONFIG_FB_VIA_DIRECT_PROCFS is not set
CONFIG_FB_VIA_X_COMPATIBILITY=y
CONFIG_FB_NEOMAGIC=y
# CONFIG_FB_KYRO is not set
CONFIG_FB_3DFX=y
CONFIG_FB_3DFX_ACCEL=y
CONFIG_FB_3DFX_I2C=y
CONFIG_FB_VOODOO1=y
CONFIG_FB_VT8623=y
CONFIG_FB_TRIDENT=y
CONFIG_FB_ARK=y
# CONFIG_FB_PM3 is not set
CONFIG_FB_CARMINE=y
# CONFIG_FB_CARMINE_DRAM_EVAL is not set
CONFIG_CARMINE_DRAM_CUSTOM=y
CONFIG_FB_GEODE=y
# CONFIG_FB_GEODE_LX is not set
CONFIG_FB_GEODE_GX=y
CONFIG_FB_GEODE_GX1=y
CONFIG_FB_SM501=y
CONFIG_FB_IBM_GXT4500=y
# CONFIG_FB_GOLDFISH is not set
CONFIG_FB_VIRTUAL=y
CONFIG_FB_METRONOME=y
# CONFIG_FB_MB862XX is not set
CONFIG_FB_BROADSHEET=y
# CONFIG_FB_AUO_K190X is not set
# CONFIG_FB_SIMPLE is not set
# CONFIG_FB_SM712 is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
CONFIG_LCD_L4F00242T03=y
# CONFIG_LCD_LMS283GF05 is not set
# CONFIG_LCD_LTV350QV is not set
CONFIG_LCD_ILI922X=y
CONFIG_LCD_ILI9320=y
CONFIG_LCD_TDO24M=y
# CONFIG_LCD_VGG2432A4 is not set
CONFIG_LCD_PLATFORM=y
# CONFIG_LCD_S6E63M0 is not set
CONFIG_LCD_LD9040=y
CONFIG_LCD_AMS369FG06=y
CONFIG_LCD_LMS501KF03=y
CONFIG_LCD_HX8357=y
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
CONFIG_BACKLIGHT_CARILLO_RANCH=y
# CONFIG_BACKLIGHT_DA903X is not set
# CONFIG_BACKLIGHT_DA9052 is not set
# CONFIG_BACKLIGHT_MAX8925 is not set
CONFIG_BACKLIGHT_APPLE=y
# CONFIG_BACKLIGHT_PM8941_WLED is not set
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_WM831X=y
CONFIG_BACKLIGHT_ADP5520=y
# CONFIG_BACKLIGHT_ADP8860 is not set
# CONFIG_BACKLIGHT_ADP8870 is not set
CONFIG_BACKLIGHT_LM3639=y
# CONFIG_BACKLIGHT_PANDORA is not set
CONFIG_BACKLIGHT_SKY81452=y
CONFIG_BACKLIGHT_GPIO=y
# CONFIG_BACKLIGHT_LV5207LP is not set
CONFIG_BACKLIGHT_BD6107=y
CONFIG_VGASTATE=y
CONFIG_HDMI=y
CONFIG_LOGO=y
CONFIG_LOGO_LINUX_MONO=y
CONFIG_LOGO_LINUX_VGA16=y
CONFIG_LOGO_LINUX_CLUT224=y
CONFIG_SOUND=y
CONFIG_SOUND_OSS_CORE=y
CONFIG_SOUND_OSS_CORE_PRECLAIM=y
# CONFIG_SND is not set
CONFIG_SOUND_PRIME=y
# CONFIG_SOUND_OSS is not set

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
CONFIG_HIDRAW=y
CONFIG_UHID=y
# CONFIG_HID_GENERIC is not set

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
CONFIG_HID_ACRUX=y
CONFIG_HID_ACRUX_FF=y
# CONFIG_HID_APPLE is not set
# CONFIG_HID_AUREAL is not set
# CONFIG_HID_BELKIN is not set
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
# CONFIG_HID_CMEDIA is not set
# CONFIG_HID_CYPRESS is not set
CONFIG_HID_DRAGONRISE=y
# CONFIG_DRAGONRISE_FF is not set
CONFIG_HID_EMS_FF=y
# CONFIG_HID_ELECOM is not set
CONFIG_HID_EZKEY=y
CONFIG_HID_GEMBIRD=y
CONFIG_HID_GFRM=y
# CONFIG_HID_KEYTOUCH is not set
CONFIG_HID_KYE=y
CONFIG_HID_WALTOP=y
# CONFIG_HID_GYRATION is not set
CONFIG_HID_ICADE=y
CONFIG_HID_TWINHAN=y
# CONFIG_HID_KENSINGTON is not set
CONFIG_HID_LCPOWER=y
CONFIG_HID_LED=y
CONFIG_HID_LENOVO=y
# CONFIG_HID_LOGITECH is not set
CONFIG_HID_MAGICMOUSE=y
# CONFIG_HID_MAYFLASH is not set
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
# CONFIG_HID_MULTITOUCH is not set
# CONFIG_HID_ORTEK is not set
CONFIG_HID_PANTHERLORD=y
CONFIG_PANTHERLORD_FF=y
CONFIG_HID_PETALYNX=y
CONFIG_HID_PICOLCD=y
CONFIG_HID_PICOLCD_FB=y
# CONFIG_HID_PICOLCD_BACKLIGHT is not set
# CONFIG_HID_PICOLCD_LCD is not set
# CONFIG_HID_PICOLCD_LEDS is not set
CONFIG_HID_PICOLCD_CIR=y
CONFIG_HID_PLANTRONICS=y
# CONFIG_HID_PRIMAX is not set
CONFIG_HID_SAITEK=y
# CONFIG_HID_SAMSUNG is not set
# CONFIG_HID_SPEEDLINK is not set
# CONFIG_HID_STEELSERIES is not set
CONFIG_HID_SUNPLUS=y
CONFIG_HID_RMI=y
CONFIG_HID_GREENASIA=y
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_SMARTJOYPLUS=y
CONFIG_SMARTJOYPLUS_FF=y
CONFIG_HID_TIVO=y
# CONFIG_HID_TOPSEED is not set
CONFIG_HID_THINGM=y
# CONFIG_HID_THRUSTMASTER is not set
CONFIG_HID_UDRAW_PS3=y
CONFIG_HID_WACOM=y
CONFIG_HID_WIIMOTE=y
CONFIG_HID_XINMO=y
CONFIG_HID_ZEROPLUS=y
# CONFIG_ZEROPLUS_FF is not set
# CONFIG_HID_ZYDACRON is not set
# CONFIG_HID_SENSOR_HUB is not set
CONFIG_HID_ALPS=y

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
# CONFIG_USB is not set

#
# USB port drivers
#

#
# USB Physical Layer drivers
#
# CONFIG_USB_PHY is not set
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_USB_GPIO_VBUS is not set
# CONFIG_USB_GADGET is not set
# CONFIG_USB_LED_TRIG is not set
# CONFIG_USB_ULPI_BUS is not set
CONFIG_UWB=y
CONFIG_UWB_WHCI=y
CONFIG_MMC=y
CONFIG_MMC_DEBUG=y
CONFIG_MMC_BLOCK=y
CONFIG_MMC_BLOCK_MINORS=8
# CONFIG_MMC_BLOCK_BOUNCE is not set
CONFIG_SDIO_UART=y
# CONFIG_MMC_TEST is not set

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=y
CONFIG_MMC_SDHCI_PCI=y
# CONFIG_MMC_RICOH_MMC is not set
# CONFIG_MMC_SDHCI_ACPI is not set
CONFIG_MMC_SDHCI_PLTFM=y
CONFIG_MMC_WBSD=y
# CONFIG_MMC_TIFM_SD is not set
# CONFIG_MMC_GOLDFISH is not set
CONFIG_MMC_SDRICOH_CS=y
CONFIG_MMC_CB710=y
# CONFIG_MMC_VIA_SDMMC is not set
CONFIG_MMC_USDHI6ROL0=y
# CONFIG_MMC_TOSHIBA_PCI is not set
# CONFIG_MMC_MTK is not set
# CONFIG_MEMSTICK is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
# CONFIG_LEDS_CLASS_FLASH is not set
# CONFIG_LEDS_BRIGHTNESS_HW_CHANGED is not set

#
# LED drivers
#
CONFIG_LEDS_LM3530=y
CONFIG_LEDS_LM3642=y
CONFIG_LEDS_NET48XX=y
# CONFIG_LEDS_WRAP is not set
CONFIG_LEDS_PCA9532=y
CONFIG_LEDS_PCA9532_GPIO=y
CONFIG_LEDS_GPIO=y
# CONFIG_LEDS_LP3944 is not set
CONFIG_LEDS_LP3952=y
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
CONFIG_LEDS_LP5523=y
# CONFIG_LEDS_LP5562 is not set
# CONFIG_LEDS_LP8501 is not set
# CONFIG_LEDS_LP8788 is not set
CONFIG_LEDS_LP8860=y
# CONFIG_LEDS_PCA955X is not set
CONFIG_LEDS_PCA963X=y
CONFIG_LEDS_WM831X_STATUS=y
CONFIG_LEDS_DA903X=y
CONFIG_LEDS_DA9052=y
CONFIG_LEDS_DAC124S085=y
# CONFIG_LEDS_REGULATOR is not set
# CONFIG_LEDS_BD2802 is not set
CONFIG_LEDS_LT3593=y
CONFIG_LEDS_ADP5520=y
# CONFIG_LEDS_MC13783 is not set
# CONFIG_LEDS_TCA6507 is not set
# CONFIG_LEDS_TLC591XX is not set
CONFIG_LEDS_MAX8997=y
CONFIG_LEDS_LM355x=y
CONFIG_LEDS_OT200=y

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
# CONFIG_LEDS_BLINKM is not set
CONFIG_LEDS_USER=y
CONFIG_LEDS_NIC78BX=y

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
# CONFIG_LEDS_TRIGGER_TIMER is not set
CONFIG_LEDS_TRIGGER_ONESHOT=y
# CONFIG_LEDS_TRIGGER_DISK is not set
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
# CONFIG_LEDS_TRIGGER_CPU is not set
CONFIG_LEDS_TRIGGER_GPIO=y
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=y
CONFIG_LEDS_TRIGGER_CAMERA=y
# CONFIG_LEDS_TRIGGER_PANIC is not set
CONFIG_ACCESSIBILITY=y
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
CONFIG_EDAC=y
# CONFIG_EDAC_LEGACY_SYSFS is not set
# CONFIG_EDAC_DEBUG is not set
# CONFIG_EDAC_MM_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
# CONFIG_RTC_CLASS is not set
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
CONFIG_DMA_ENGINE=y
CONFIG_DMA_VIRTUAL_CHANNELS=y
CONFIG_DMA_ACPI=y
CONFIG_INTEL_IDMA64=y
# CONFIG_PCH_DMA is not set
# CONFIG_TIMB_DMA is not set
CONFIG_QCOM_HIDMA_MGMT=y
CONFIG_QCOM_HIDMA=y
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=y
CONFIG_DW_DMAC_PCI=y

#
# DMA Clients
#
# CONFIG_ASYNC_TX_DMA is not set
# CONFIG_DMATEST is not set

#
# DMABUF options
#
CONFIG_SYNC_FILE=y
# CONFIG_SW_SYNC is not set
CONFIG_AUXDISPLAY=y
# CONFIG_KS0108 is not set
CONFIG_IMG_ASCII_LCD=y
CONFIG_UIO=y
CONFIG_UIO_CIF=y
CONFIG_UIO_PDRV_GENIRQ=y
CONFIG_UIO_DMEM_GENIRQ=y
CONFIG_UIO_AEC=y
# CONFIG_UIO_SERCOS3 is not set
CONFIG_UIO_PCI_GENERIC=y
# CONFIG_UIO_NETX is not set
# CONFIG_UIO_PRUSS is not set
CONFIG_UIO_MF624=y
CONFIG_VFIO_IOMMU_TYPE1=y
CONFIG_VFIO_VIRQFD=y
CONFIG_VFIO=y
# CONFIG_VFIO_NOIOMMU is not set
CONFIG_VFIO_PCI=y
CONFIG_VFIO_PCI_VGA=y
CONFIG_VFIO_PCI_MMAP=y
CONFIG_VFIO_PCI_INTX=y
CONFIG_VFIO_PCI_IGD=y
CONFIG_VFIO_MDEV=y
CONFIG_VFIO_MDEV_DEVICE=y
CONFIG_IRQ_BYPASS_MANAGER=y
CONFIG_VIRT_DRIVERS=y
CONFIG_VIRTIO=y

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
CONFIG_VIRTIO_BALLOON=y
# CONFIG_VIRTIO_INPUT is not set
CONFIG_VIRTIO_MMIO=y
# CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACER_WMI is not set
# CONFIG_ACERHDF is not set
# CONFIG_ALIENWARE_WMI is not set
CONFIG_ASUS_LAPTOP=y
CONFIG_DELL_WMI_AIO=y
# CONFIG_DELL_SMO8800 is not set
CONFIG_FUJITSU_LAPTOP=y
CONFIG_FUJITSU_LAPTOP_DEBUG=y
CONFIG_FUJITSU_TABLET=y
CONFIG_TC1100_WMI=y
# CONFIG_HP_ACCEL is not set
CONFIG_HP_WIRELESS=y
# CONFIG_HP_WMI is not set
CONFIG_PANASONIC_LAPTOP=y
CONFIG_THINKPAD_ACPI=y
# CONFIG_THINKPAD_ACPI_DEBUGFACILITIES is not set
# CONFIG_THINKPAD_ACPI_DEBUG is not set
CONFIG_THINKPAD_ACPI_UNSAFE_LEDS=y
# CONFIG_THINKPAD_ACPI_VIDEO is not set
# CONFIG_THINKPAD_ACPI_HOTKEY_POLL is not set
CONFIG_SENSORS_HDAPS=y
CONFIG_INTEL_MENLOW=y
CONFIG_ASUS_WIRELESS=y
CONFIG_ACPI_WMI=y
CONFIG_MSI_WMI=y
CONFIG_TOPSTAR_LAPTOP=y
# CONFIG_TOSHIBA_BT_RFKILL is not set
CONFIG_TOSHIBA_HAPS=y
CONFIG_TOSHIBA_WMI=y
CONFIG_ACPI_CMPC=y
CONFIG_INTEL_HID_EVENT=y
CONFIG_INTEL_VBTN=y
CONFIG_INTEL_IPS=y
CONFIG_INTEL_IMR=y
CONFIG_INTEL_PMC_CORE=y
# CONFIG_IBM_RTL is not set
# CONFIG_SAMSUNG_LAPTOP is not set
CONFIG_MXM_WMI=y
CONFIG_SAMSUNG_Q10=y
# CONFIG_APPLE_GMUX is not set
CONFIG_INTEL_RST=y
# CONFIG_INTEL_SMARTCONNECT is not set
# CONFIG_PVPANIC is not set
# CONFIG_INTEL_PMC_IPC is not set
CONFIG_SURFACE_PRO3_BUTTON=y
CONFIG_INTEL_PUNIT_IPC=y
CONFIG_MLX_CPLD_PLATFORM=y
# CONFIG_GOLDFISH_BUS is not set
# CONFIG_GOLDFISH_PIPE is not set
CONFIG_CHROME_PLATFORMS=y
# CONFIG_CHROMEOS_PSTORE is not set
CONFIG_CROS_KBD_LED_BACKLIGHT=y
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
CONFIG_COMMON_CLK_WM831X=y
CONFIG_COMMON_CLK_SI5351=y
# CONFIG_COMMON_CLK_CDCE706 is not set
CONFIG_COMMON_CLK_CS2000_CP=y
# CONFIG_COMMON_CLK_NXP is not set
CONFIG_COMMON_CLK_PALMAS=y
# CONFIG_COMMON_CLK_PXA is not set
# CONFIG_COMMON_CLK_PIC32 is not set
CONFIG_COMMON_CLK_MEDIATEK=y
CONFIG_COMMON_CLK_MT2701=y
# CONFIG_COMMON_CLK_MT2701_MMSYS is not set
CONFIG_COMMON_CLK_MT2701_IMGSYS=y
CONFIG_COMMON_CLK_MT2701_VDECSYS=y
CONFIG_COMMON_CLK_MT2701_HIFSYS=y
CONFIG_COMMON_CLK_MT2701_ETHSYS=y
# CONFIG_COMMON_CLK_MT2701_BDPSYS is not set

#
# Hardware Spinlock drivers
#

#
# Clock Source drivers
#
CONFIG_CLKSRC_I8253=y
CONFIG_CLKEVT_I8253=y
CONFIG_CLKBLD_I8253=y
# CONFIG_ATMEL_PIT is not set
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
# CONFIG_MAILBOX is not set
CONFIG_IOMMU_API=y
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#
CONFIG_IOMMU_IOVA=y
CONFIG_DMAR_TABLE=y
CONFIG_INTEL_IOMMU=y
# CONFIG_INTEL_IOMMU_SVM is not set
CONFIG_INTEL_IOMMU_DEFAULT_ON=y
CONFIG_INTEL_IOMMU_FLOPPY_WA=y

#
# Remoteproc drivers
#
# CONFIG_REMOTEPROC is not set

#
# Rpmsg drivers
#

#
# SOC (System On Chip) specific Drivers
#

#
# Broadcom SoC drivers
#
# CONFIG_SUNXI_SRAM is not set
CONFIG_SOC_TI=y
# CONFIG_PM_DEVFREQ is not set
# CONFIG_EXTCON is not set
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
CONFIG_NTB=y
CONFIG_NTB_PINGPONG=y
# CONFIG_NTB_TOOL is not set
# CONFIG_NTB_PERF is not set
CONFIG_NTB_TRANSPORT=y
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set
CONFIG_ARM_GIC_MAX_NR=1
CONFIG_IPACK_BUS=y
CONFIG_BOARD_TPCI200=y
# CONFIG_SERIAL_IPOCTAL is not set
# CONFIG_RESET_CONTROLLER is not set
CONFIG_FMC=y
CONFIG_FMC_FAKEDEV=y
CONFIG_FMC_TRIVIAL=y
CONFIG_FMC_WRITE_EEPROM=y
# CONFIG_FMC_CHARDEV is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_PHY_PXA_28NM_HSIC=y
CONFIG_PHY_PXA_28NM_USB2=y
# CONFIG_BCM_KONA_USB2_PHY is not set
# CONFIG_POWERCAP is not set
CONFIG_MCB=y
CONFIG_MCB_PCI=y
# CONFIG_MCB_LPC is not set

#
# Performance monitor support
#
CONFIG_RAS=y
# CONFIG_THUNDERBOLT is not set

#
# Android
#
# CONFIG_ANDROID is not set
CONFIG_NVMEM=y
# CONFIG_STM is not set
CONFIG_INTEL_TH=y
# CONFIG_INTEL_TH_PCI is not set
# CONFIG_INTEL_TH_GTH is not set
# CONFIG_INTEL_TH_MSU is not set
CONFIG_INTEL_TH_PTI=y
# CONFIG_INTEL_TH_DEBUG is not set

#
# FPGA Configuration Support
#
# CONFIG_FPGA is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
CONFIG_EDD_OFF=y
# CONFIG_FIRMWARE_MEMMAP is not set
# CONFIG_DELL_RBU is not set
# CONFIG_DCDBAS is not set
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_FW_CFG_SYSFS=y
# CONFIG_FW_CFG_SYSFS_CMDLINE is not set
CONFIG_GOOGLE_FIRMWARE=y

#
# Google Firmware Drivers
#
CONFIG_UEFI_CPER=y
# CONFIG_EFI_DEV_PATH_PARSER is not set

#
# Tegra firmware driver
#

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_EXT2_FS=y
# CONFIG_EXT2_FS_XATTR is not set
CONFIG_EXT3_FS=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
CONFIG_EXT4_FS=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
# CONFIG_EXT4_ENCRYPTION is not set
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD2=y
CONFIG_JBD2_DEBUG=y
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
CONFIG_REISERFS_CHECK=y
# CONFIG_REISERFS_PROC_INFO is not set
# CONFIG_REISERFS_FS_XATTR is not set
CONFIG_JFS_FS=y
# CONFIG_JFS_POSIX_ACL is not set
CONFIG_JFS_SECURITY=y
# CONFIG_JFS_DEBUG is not set
CONFIG_JFS_STATISTICS=y
# CONFIG_OCFS2_FS is not set
# CONFIG_BTRFS_FS is not set
CONFIG_NILFS2_FS=y
CONFIG_F2FS_FS=y
# CONFIG_F2FS_STAT_FS is not set
# CONFIG_F2FS_FS_XATTR is not set
CONFIG_F2FS_CHECK_FS=y
CONFIG_F2FS_FAULT_INJECTION=y
# CONFIG_FS_DAX is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_EXPORTFS_BLOCK_OPS=y
CONFIG_FILE_LOCKING=y
# CONFIG_MANDATORY_FILE_LOCKING is not set
CONFIG_FS_ENCRYPTION=y
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
# CONFIG_QUOTA is not set
# CONFIG_QUOTACTL is not set
CONFIG_AUTOFS4_FS=y
# CONFIG_FUSE_FS is not set
CONFIG_OVERLAY_FS=y
CONFIG_OVERLAY_FS_REDIRECT_DIR=y

#
# Caches
#
CONFIG_FSCACHE=y
CONFIG_FSCACHE_STATS=y
# CONFIG_FSCACHE_HISTOGRAM is not set
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set
CONFIG_CACHEFILES=y
CONFIG_CACHEFILES_DEBUG=y
# CONFIG_CACHEFILES_HISTOGRAM is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
# CONFIG_JOLIET is not set
# CONFIG_ZISOFS is not set
# CONFIG_UDF_FS is not set

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
# CONFIG_MSDOS_FS is not set
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
# CONFIG_FAT_DEFAULT_UTF8 is not set
CONFIG_NTFS_FS=y
# CONFIG_NTFS_DEBUG is not set
CONFIG_NTFS_RW=y

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_VMCORE=y
# CONFIG_PROC_SYSCTL is not set
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_PROC_CHILDREN=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
CONFIG_ORANGEFS_FS=y
# CONFIG_ADFS_FS is not set
CONFIG_AFFS_FS=y
# CONFIG_ECRYPT_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
CONFIG_BEFS_FS=y
CONFIG_BEFS_DEBUG=y
CONFIG_BFS_FS=y
CONFIG_EFS_FS=y
CONFIG_CRAMFS=y
CONFIG_SQUASHFS=y
CONFIG_SQUASHFS_FILE_CACHE=y
# CONFIG_SQUASHFS_FILE_DIRECT is not set
CONFIG_SQUASHFS_DECOMP_SINGLE=y
# CONFIG_SQUASHFS_DECOMP_MULTI is not set
# CONFIG_SQUASHFS_DECOMP_MULTI_PERCPU is not set
# CONFIG_SQUASHFS_XATTR is not set
# CONFIG_SQUASHFS_ZLIB is not set
# CONFIG_SQUASHFS_LZ4 is not set
CONFIG_SQUASHFS_LZO=y
# CONFIG_SQUASHFS_XZ is not set
# CONFIG_SQUASHFS_4K_DEVBLK_SIZE is not set
# CONFIG_SQUASHFS_EMBEDDED is not set
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
CONFIG_VXFS_FS=y
CONFIG_MINIX_FS=y
# CONFIG_OMFS_FS is not set
# CONFIG_HPFS_FS is not set
CONFIG_QNX4FS_FS=y
CONFIG_QNX6FS_FS=y
CONFIG_QNX6FS_DEBUG=y
# CONFIG_ROMFS_FS is not set
CONFIG_PSTORE=y
CONFIG_PSTORE_ZLIB_COMPRESS=y
# CONFIG_PSTORE_LZO_COMPRESS is not set
# CONFIG_PSTORE_LZ4_COMPRESS is not set
CONFIG_PSTORE_CONSOLE=y
# CONFIG_PSTORE_PMSG is not set
CONFIG_PSTORE_RAM=y
CONFIG_SYSV_FS=y
# CONFIG_UFS_FS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=y
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=y
CONFIG_NLS_CODEPAGE_852=y
CONFIG_NLS_CODEPAGE_855=y
CONFIG_NLS_CODEPAGE_857=y
CONFIG_NLS_CODEPAGE_860=y
CONFIG_NLS_CODEPAGE_861=y
# CONFIG_NLS_CODEPAGE_862 is not set
# CONFIG_NLS_CODEPAGE_863 is not set
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=y
CONFIG_NLS_CODEPAGE_866=y
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
CONFIG_NLS_CODEPAGE_932=y
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=y
CONFIG_NLS_ISO8859_8=y
CONFIG_NLS_CODEPAGE_1250=y
CONFIG_NLS_CODEPAGE_1251=y
# CONFIG_NLS_ASCII is not set
# CONFIG_NLS_ISO8859_1 is not set
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
# CONFIG_NLS_ISO8859_7 is not set
CONFIG_NLS_ISO8859_9=y
CONFIG_NLS_ISO8859_13=y
# CONFIG_NLS_ISO8859_14 is not set
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
CONFIG_NLS_KOI8_U=y
CONFIG_NLS_MAC_ROMAN=y
# CONFIG_NLS_MAC_CELTIC is not set
CONFIG_NLS_MAC_CENTEURO=y
# CONFIG_NLS_MAC_CROATIAN is not set
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
# CONFIG_NLS_MAC_GREEK is not set
CONFIG_NLS_MAC_ICELAND=y
# CONFIG_NLS_MAC_INUIT is not set
CONFIG_NLS_MAC_ROMANIAN=y
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_CONSOLE_LOGLEVEL_DEFAULT=7
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
# CONFIG_ENABLE_WARN_DEPRECATED is not set
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=1024
CONFIG_STRIP_ASM_SYMS=y
# CONFIG_READABLE_ASM is not set
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_PAGE_OWNER=y
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
# CONFIG_SECTION_MISMATCH_WARN_ONLY is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
CONFIG_DEBUG_PAGEALLOC=y
CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT=y
CONFIG_PAGE_POISONING=y
# CONFIG_PAGE_POISONING_NO_SANITY is not set
# CONFIG_PAGE_POISONING_ZERO is not set
CONFIG_DEBUG_PAGE_REF=y
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_DEBUG_SLAB is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
# CONFIG_DEBUG_VM is not set
CONFIG_DEBUG_VIRTUAL=y
CONFIG_DEBUG_MEMORY_INIT=y
# CONFIG_DEBUG_HIGHMEM is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_KMEMCHECK is not set
# CONFIG_DEBUG_REFCOUNT is not set
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=1
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
# CONFIG_BOOTPARAM_HUNG_TASK_PANIC is not set
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=0
CONFIG_WQ_WATCHDOG=y
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
# CONFIG_SCHED_INFO is not set
# CONFIG_SCHEDSTATS is not set
CONFIG_SCHED_STACK_END_CHECK=y
# CONFIG_DEBUG_TIMEKEEPING is not set

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_LOCK_TORTURE_TEST=y
# CONFIG_WW_MUTEX_SELFTEST is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
# CONFIG_DEBUG_PI_LIST is not set
CONFIG_DEBUG_SG=y
CONFIG_DEBUG_NOTIFIERS=y
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
CONFIG_PROVE_RCU=y
# CONFIG_PROVE_RCU_REPEATEDLY is not set
# CONFIG_SPARSE_RCU_POINTER is not set
CONFIG_TORTURE_TEST=y
# CONFIG_RCU_PERF_TEST is not set
CONFIG_RCU_TORTURE_TEST=y
# CONFIG_RCU_TORTURE_TEST_SLOW_PREINIT is not set
# CONFIG_RCU_TORTURE_TEST_SLOW_INIT is not set
# CONFIG_RCU_TORTURE_TEST_SLOW_CLEANUP is not set
# CONFIG_RCU_TRACE is not set
# CONFIG_RCU_EQS_DEBUG is not set
# CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
CONFIG_NOTIFIER_ERROR_INJECTION=y
# CONFIG_NETDEV_NOTIFIER_ERROR_INJECT is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
# CONFIG_FUNCTION_TRACER is not set
# CONFIG_IRQSOFF_TRACER is not set
# CONFIG_SCHED_TRACER is not set
CONFIG_HWLAT_TRACER=y
CONFIG_FTRACE_SYSCALLS=y
# CONFIG_TRACER_SNAPSHOT is not set
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
# CONFIG_STACK_TRACER is not set
CONFIG_BLK_DEV_IO_TRACE=y
CONFIG_UPROBE_EVENT=y
CONFIG_PROBE_EVENTS=y
# CONFIG_FTRACE_STARTUP_TEST is not set
CONFIG_MMIOTRACE=y
CONFIG_TRACING_MAP=y
CONFIG_HIST_TRIGGERS=y
# CONFIG_TRACEPOINT_BENCHMARK is not set
# CONFIG_RING_BUFFER_BENCHMARK is not set
# CONFIG_RING_BUFFER_STARTUP_TEST is not set
CONFIG_TRACE_ENUM_MAP_FILE=y
# CONFIG_TRACING_EVENTS_GPIO is not set

#
# Runtime Testing
#
# CONFIG_LKDTM is not set
CONFIG_TEST_LIST_SORT=y
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_RBTREE_TEST=y
# CONFIG_ATOMIC64_SELFTEST is not set
CONFIG_TEST_HEXDUMP=y
CONFIG_TEST_STRING_HELPERS=y
CONFIG_TEST_KSTRTOX=y
CONFIG_TEST_PRINTF=y
# CONFIG_TEST_BITMAP is not set
CONFIG_TEST_UUID=y
CONFIG_TEST_RHASHTABLE=y
# CONFIG_TEST_HASH is not set
CONFIG_PROVIDE_OHCI1394_DMA_INIT=y
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_TEST_FIRMWARE is not set
CONFIG_TEST_UDELAY=y
CONFIG_MEMTEST=y
CONFIG_BUG_ON_DATA_CORRUPTION=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
# CONFIG_ARCH_WANTS_UBSAN_NO_NULL is not set
# CONFIG_UBSAN is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
CONFIG_STRICT_DEVMEM=y
# CONFIG_IO_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
# CONFIG_EARLY_PRINTK is not set
CONFIG_X86_PTDUMP_CORE=y
CONFIG_X86_PTDUMP=y
# CONFIG_DEBUG_RODATA_TEST is not set
CONFIG_DEBUG_WX=y
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_IOMMU_STRESS=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
# CONFIG_IO_DELAY_0XED is not set
CONFIG_IO_DELAY_UDELAY=y
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=2
CONFIG_DEBUG_BOOT_PARAMS=y
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
CONFIG_DEBUG_ENTRY=y
CONFIG_DEBUG_NMI_SELFTEST=y
# CONFIG_DEBUG_IMR_SELFTEST is not set
CONFIG_X86_DEBUG_FPU=y
CONFIG_PUNIT_ATOM_DEBUG=y

#
# Security options
#
CONFIG_KEYS=y
CONFIG_PERSISTENT_KEYRINGS=y
CONFIG_BIG_KEYS=y
CONFIG_TRUSTED_KEYS=y
CONFIG_ENCRYPTED_KEYS=y
CONFIG_KEY_DH_OPERATIONS=y
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
# CONFIG_SECURITY_NETWORK is not set
CONFIG_SECURITY_PATH=y
CONFIG_INTEL_TXT=y
CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR=y
CONFIG_HAVE_ARCH_HARDENED_USERCOPY=y
# CONFIG_HARDENED_USERCOPY is not set
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
# CONFIG_SECURITY_LOADPIN is not set
CONFIG_SECURITY_YAMA=y
# CONFIG_INTEGRITY is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_RNG_DEFAULT=y
CONFIG_CRYPTO_AKCIPHER2=y
CONFIG_CRYPTO_AKCIPHER=y
CONFIG_CRYPTO_KPP2=y
CONFIG_CRYPTO_KPP=y
CONFIG_CRYPTO_ACOMP2=y
CONFIG_CRYPTO_RSA=y
CONFIG_CRYPTO_DH=y
CONFIG_CRYPTO_ECDH=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_MCRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_ABLK_HELPER=y
CONFIG_CRYPTO_SIMD=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
# CONFIG_CRYPTO_GCM is not set
CONFIG_CRYPTO_CHACHA20POLY1305=y
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_ECHAINIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
# CONFIG_CRYPTO_PCBC is not set
CONFIG_CRYPTO_XTS=y
CONFIG_CRYPTO_KEYWRAP=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
# CONFIG_CRYPTO_XCBC is not set
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_CRC32=y
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_POLY1305=y
# CONFIG_CRYPTO_MD4 is not set
CONFIG_CRYPTO_MD5=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_SHA3=y
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_586=y
CONFIG_CRYPTO_AES_NI_INTEL=y
CONFIG_CRYPTO_ANUBIS=y
# CONFIG_CRYPTO_ARC4 is not set
# CONFIG_CRYPTO_BLOWFISH is not set
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_FCRYPT=y
# CONFIG_CRYPTO_KHAZAD is not set
CONFIG_CRYPTO_SALSA20=y
# CONFIG_CRYPTO_SALSA20_586 is not set
CONFIG_CRYPTO_CHACHA20=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_586=y
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
# CONFIG_CRYPTO_TWOFISH_586 is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_LZO=y
CONFIG_CRYPTO_842=y
CONFIG_CRYPTO_LZ4=y
# CONFIG_CRYPTO_LZ4HC is not set

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
CONFIG_CRYPTO_DRBG_HASH=y
CONFIG_CRYPTO_DRBG_CTR=y
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
# CONFIG_CRYPTO_USER_API_RNG is not set
# CONFIG_CRYPTO_USER_API_AEAD is not set
CONFIG_CRYPTO_HASH_INFO=y
CONFIG_CRYPTO_HW=y
# CONFIG_CRYPTO_DEV_PADLOCK is not set
CONFIG_CRYPTO_DEV_GEODE=y
# CONFIG_CRYPTO_DEV_HIFN_795X is not set
# CONFIG_CRYPTO_DEV_FSL_CAAM_CRYPTO_API_DESC is not set
# CONFIG_CRYPTO_DEV_CCP is not set
CONFIG_CRYPTO_DEV_QAT=y
# CONFIG_CRYPTO_DEV_QAT_DH895xCC is not set
CONFIG_CRYPTO_DEV_QAT_C3XXX=y
CONFIG_CRYPTO_DEV_QAT_C62X=y
CONFIG_CRYPTO_DEV_QAT_DH895xCCVF=y
# CONFIG_CRYPTO_DEV_QAT_C3XXXVF is not set
# CONFIG_CRYPTO_DEV_QAT_C62XVF is not set
CONFIG_CRYPTO_DEV_VIRTIO=y
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_X509_CERTIFICATE_PARSER=y
CONFIG_PKCS7_MESSAGE_PARSER=y

#
# Certificates for signature checking
#
CONFIG_SYSTEM_TRUSTED_KEYRING=y
CONFIG_SYSTEM_TRUSTED_KEYS=""
# CONFIG_SYSTEM_EXTRA_CERTIFICATE is not set
CONFIG_SECONDARY_TRUSTED_KEYRING=y
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
# CONFIG_KVM is not set
# CONFIG_VHOST_NET is not set
# CONFIG_VHOST_CROSS_ENDIAN_LEGACY is not set
CONFIG_LGUEST=y
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_BITREVERSE=y
# CONFIG_HAVE_ARCH_BITREVERSE is not set
CONFIG_RATIONAL=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
# CONFIG_CRC32_SLICEBY8 is not set
CONFIG_CRC32_SLICEBY4=y
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
# CONFIG_CRC7 is not set
# CONFIG_LIBCRC32C is not set
CONFIG_CRC8=y
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
CONFIG_RANDOM32_SELFTEST=y
CONFIG_842_COMPRESS=y
CONFIG_842_DECOMPRESS=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
# CONFIG_XZ_DEC_IA64 is not set
# CONFIG_XZ_DEC_ARM is not set
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_ENC8=y
CONFIG_REED_SOLOMON_DEC8=y
CONFIG_INTERVAL_TREE=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_DQL=y
CONFIG_GLOB=y
CONFIG_GLOB_SELFTEST=y
CONFIG_NLATTR=y
CONFIG_CLZ_TAB=y
# CONFIG_CORDIC is not set
# CONFIG_DDR is not set
CONFIG_IRQ_POLL=y
CONFIG_MPILIB=y
CONFIG_OID_REGISTRY=y
CONFIG_FONT_SUPPORT=y
CONFIG_FONT_8x16=y
CONFIG_FONT_AUTOSELECT=y
# CONFIG_SG_SPLIT is not set
CONFIG_SG_POOL=y
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_ARCH_HAS_MMIO_FLUSH=y
CONFIG_STACKDEPOT=y
CONFIG_SBITMAP=y
# CONFIG_PARMAN is not set

--jl252dk3czobalyd--
