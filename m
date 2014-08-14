From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: null pointer dereference caused by a188a54d1162 ("macvlan: simplify
 the structure port")
Date: Thu, 14 Aug 2014 15:11:55 +0800
Message-ID: <53EC613B.5020908@huawei.com>
References: <1407967062.28924.33.camel@jekeller-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:60441 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751836AbaHNHOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 03:14:47 -0400
In-Reply-To: <1407967062.28924.33.camel@jekeller-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/8/14 5:57, Keller, Jacob E wrote:
> Hello,
> 

Hi Jacob E:

Thanks for your detail analysis, really good catch, I will send a new patch to fix it soon, thanks again.

Regards
Ding

> I found a null pointer dereference caused by instantiating multiple
> macvlans on a single parent port device. Below is a copy of the NULL
> pointer dereference stack dump.
> 
> 
>> [   80.643286] BUG: unable to handle kernel NULL pointer dereference at 0000000000000878
>> [   80.670103] IP: [<ffffffff810832e4>] try_to_grab_pending+0x64/0x1f0
>> [   80.691289] PGD 22c102067 PUD 235bf0067 PMD 0 
>> [   80.706611] Oops: 0002 [#1] SMP 
>> [   80.717836] Modules linked in: macvlan nfsd lockd nfs_acl exportfs auth_rpcgss sunrpc oid_registry ioatdma ixgbe(-) mdio igb dca
>> [   80.757935] CPU: 37 PID: 6724 Comm: rmmod Not tainted 3.16.0-net-next-08-12-2014-FCoE+ #1
>> [   80.785688] Hardware name: Intel Corporation S2600CO/S2600CO, BIOS SE5C600.86B.02.03.0003.041920141333 04/19/2014
>> [   80.820310] task: ffff880235a9eae0 ti: ffff88022e844000 task.ti: ffff88022e844000
>> [   80.845770] RIP: 0010:[<ffffffff810832e4>]  [<ffffffff810832e4>] try_to_grab_pending+0x64/0x1f0
>> [   80.875326] RSP: 0018:ffff88022e847b28  EFLAGS: 00010046
>> [   80.893251] RAX: 0000000000037a6a RBX: 0000000000000878 RCX: 0000000000000000
>> [   80.917187] RDX: ffff880235a9eae0 RSI: 0000000000000001 RDI: ffffffff810832db
>> [   80.941125] RBP: ffff88022e847b58 R08: 0000000000000000 R09: 0000000000000000
>> [   80.965056] R10: 0000000000000001 R11: 0000000000000001 R12: ffff88022e847b70
>> [   80.988994] R13: 0000000000000000 R14: ffff88022e847be8 R15: ffffffff81ebe440
>> [   81.012929] FS:  00007fab90b07700(0000) GS:ffff88043f7a0000(0000) knlGS:0000000000000000
>> [   81.040400] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [   81.059757] CR2: 0000000000000878 CR3: 0000000235a42000 CR4: 00000000001407e0
>> [   81.083689] Stack:
>> [   81.090739]  ffff880235a9eae0 0000000000000878 ffff88022e847b70 0000000000000000
>> [   81.116253]  ffff88022e847be8 ffffffff81ebe440 ffff88022e847b98 ffffffff810847f1
>> [   81.141766]  ffff88022e847b78 0000000000000286 ffff880234200000 0000000000000000
>> [   81.167282] Call Trace:
>> [   81.175768]  [<ffffffff810847f1>] __cancel_work_timer+0x31/0x170
>> [   81.195985]  [<ffffffff8108494b>] cancel_work_sync+0xb/0x10
>> [   81.214769]  [<ffffffffa015ae68>] macvlan_port_destroy+0x28/0x60 [macvlan]
>> [   81.237844]  [<ffffffffa015b930>] macvlan_uninit+0x40/0x50 [macvlan]
>> [   81.259209]  [<ffffffff816bf6e2>] rollback_registered_many+0x1a2/0x2c0
>> [   81.281140]  [<ffffffff816bf81a>] unregister_netdevice_many+0x1a/0xb0
>> [   81.302786]  [<ffffffffa015a4ff>] macvlan_device_event+0x1ef/0x240 [macvlan]
>> [   81.326439]  [<ffffffff8108a13d>] notifier_call_chain+0x4d/0x70
>> [   81.346366]  [<ffffffff8108a201>] raw_notifier_call_chain+0x11/0x20
>> [   81.367439]  [<ffffffff816bf25b>] call_netdevice_notifiers_info+0x3b/0x70
>> [   81.390228]  [<ffffffff816bf2a1>] call_netdevice_notifiers+0x11/0x20
>> [   81.411587]  [<ffffffff816bf6bd>] rollback_registered_many+0x17d/0x2c0
>> [   81.433518]  [<ffffffff816bf925>] unregister_netdevice_queue+0x75/0x110
>> [   81.455735]  [<ffffffff816bfb2b>] unregister_netdev+0x1b/0x30
>> [   81.475094]  [<ffffffffa0039b50>] ixgbe_remove+0x170/0x1d0 [ixgbe]
>> [   81.495886]  [<ffffffff813512a2>] pci_device_remove+0x32/0x60
>> [   81.515246]  [<ffffffff814c75c4>] __device_release_driver+0x64/0xd0
>> [   81.536321]  [<ffffffff814c76f8>] driver_detach+0xc8/0xd0
>> [   81.554530]  [<ffffffff814c656e>] bus_remove_driver+0x4e/0xa0
>> [   81.573888]  [<ffffffff814c828b>] driver_unregister+0x2b/0x60
>> [   81.593246]  [<ffffffff8135143e>] pci_unregister_driver+0x1e/0xa0
>> [   81.613749]  [<ffffffffa005db18>] ixgbe_exit_module+0x1c/0x2e [ixgbe]
>> [   81.635401]  [<ffffffff810e738b>] SyS_delete_module+0x15b/0x1e0
>> [   81.655334]  [<ffffffff8187a395>] ? sysret_check+0x22/0x5d
>> [   81.673833]  [<ffffffff810abd2d>] ? trace_hardirqs_on_caller+0x11d/0x1e0
>> [   81.696339]  [<ffffffff8132bfde>] ? trace_hardirqs_on_thunk+0x3a/0x3f
>> [   81.717985]  [<ffffffff8187a369>] system_call_fastpath+0x16/0x1b
>> [   81.738199] Code: 00 48 83 3d 6e bb da 00 00 48 89 c2 0f 84 67 01 00 00 fa 66 0f 1f 44 00 00 49 89 14 24 e8 b5 4b 02 00 45 84 ed 0f 85 ac 00 00 00 <f0> 0f ba 2b 00 72 1d 31 c0 48 8b 5d d8 4c 8b 65 e0 4c 8b 6d e8 
>> [   81.807026] RIP  [<ffffffff810832e4>] try_to_grab_pending+0x64/0x1f0
>> [   81.828468]  RSP <ffff88022e847b28>
>> [   81.840384] CR2: 0000000000000878
>> [   81.851731] ---[ end trace 9f6c7232e3464e11 ]---
> 
> Also, here is the sequence of commands possible to generate the bug.
> 
> 
>> #modprobe ixgbe ; modprobe macvlan
>> #ip link add link p96p1 address 00:1B:21:6E:06:00 macvlan0 type macvlan
>> #ip link add link p96p1 address 00:1B:21:6E:06:01 macvlan1 type macvlan
>> #ip link add link p96p1 address 00:1B:21:6E:06:02 macvlan2 type macvlan
>> #ip link add link p96p1 address 00:1B:21:6E:06:03 macvlan3 type macvlan
>> #rmmod ixgbe
> 
> Where p96p1 is an ethernet device which supports macvlans.
> 
> I also have here the git-bisect log which led me to this specific patch
> as the point of failure.
> 
> 
>> # bad: [205c13256451bb1bd093d99186c459e77b889b81] ixgbevf: introduce delay for checking VFLINKS on 82599
>> # good: [d8ec26d7f8287f5788a494f56e8814210f0e64be] Linux 3.13
>> git bisect start 'origin/ixgbe-queue' 'HEAD'
>> # good: [5fb6b953bb7aa86a9c8ea760934982cedc45c52b] include/linux/syscalls.h: add sys_renameat2() prototype
>> git bisect good 5fb6b953bb7aa86a9c8ea760934982cedc45c52b
>> # good: [412dd3a6daf0cadce1b2d6a34fa3713f40255579] Merge tag 'xfs-for-linus-3.16-rc1' of git://oss.sgi.com/xfs/xfs
>> git bisect good 412dd3a6daf0cadce1b2d6a34fa3713f40255579
>> # bad: [5d6e2298b29113e6b71f1c30bfcfc70051abdcec] staging: comedi: ni_pcidio: remove forward declarations
>> git bisect bad 5d6e2298b29113e6b71f1c30bfcfc70051abdcec
>> # bad: [6d87c225f5d82d29243dc124f1ffcbb0e14ec358] Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/sage/ceph-client
>> git bisect bad 6d87c225f5d82d29243dc124f1ffcbb0e14ec358
>> # bad: [04b73bd7a46b0294456301e237041cca5adb33d7] i40e: Change the notion of src and dst for FD_SB in ethtool
>> git bisect bad 04b73bd7a46b0294456301e237041cca5adb33d7
>> # bad: [91c1d980d6013dec4292309aa1700af36b400477] Documentation: devicetree: add old and deprecated 'fixed-link'
>> git bisect bad 91c1d980d6013dec4292309aa1700af36b400477
>> # good: [406a94d7fae94a893c3afb9c2d18c83124d3cd9b] Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next into for-davem
>> git bisect good 406a94d7fae94a893c3afb9c2d18c83124d3cd9b
>> # good: [f3c2af7ba17a83809806880062c9ad541744fb95] net: filter: x86: split bpf_jit_compile()
>> git bisect good f3c2af7ba17a83809806880062c9ad541744fb95
>> # bad: [38ea4e6e4a21fb88104be2a666a7e88176150b00] net: ethernet: ibm: ehea: ehea_qmr.c: Fix for possible null pointer dereference
>> git bisect bad 38ea4e6e4a21fb88104be2a666a7e88176150b00
>> # bad: [ad2ebb3d4dd244f9fd6b24f523b06134e571ae92] Merge branch 'dt_fixed_phy'
>> git bisect bad ad2ebb3d4dd244f9fd6b24f523b06134e571ae92
>> # bad: [8557cd74ca8af9a71ae19d445e33d92bd50a6dc5] bonding: replace SLAVE_IS_OK() with bond_slave_can_tx()
>> git bisect bad 8557cd74ca8af9a71ae19d445e33d92bd50a6dc5
>> # good: [112a3513b51976111e5e4a3115485d3fc89410c1] vti6: delete unneeded call to netdev_priv
>> git bisect good 112a3513b51976111e5e4a3115485d3fc89410c1
>> # bad: [267bed777a5f8a8f5acd50a9134c7341fc46d822] bonding: make BOND_NO_USES_ARP an inline function
>> git bisect bad 267bed777a5f8a8f5acd50a9134c7341fc46d822
>> # bad: [31ff6aa5c86f7564f0dd97c5b3e1404cad238d00] net: unix: Align send data_len up to PAGE_SIZE
>> git bisect bad 31ff6aa5c86f7564f0dd97c5b3e1404cad238d00
>> # bad: [a188a54d11629bef2169052297e61f3767ca8ce5] macvlan: simplify the structure port
>> git bisect bad a188a54d11629bef2169052297e61f3767ca8ce5
>> # first bad commit: [a188a54d11629bef2169052297e61f3767ca8ce5] macvlan: simplify the structure port
> 
> Though the first bad commit I believe may not yet be public on Dave's
> net or net-next tree.
> 
> I also discovered the actual problem via an ftrace on the macvlan module
> (in addition to the unregister_netdevice_queue and
> unregister_netdevice_many functions). This helped ensure my suspicion of
> the problem.
> 
>>  7)   0.090 us    |    unregister_netdevice_many();
>>  7)               |    macvlan_device_event [macvlan]() {
>>  7)               |      macvlan_dellink [macvlan]() {
>>  7)   0.076 us    |        unregister_netdevice_queue();
>>  7)   0.101 us    |        macvlan_device_event [macvlan]();
>>  7) + 14.055 us   |      }
>>  7)               |      macvlan_dellink [macvlan]() {
>>  7)   0.062 us    |        unregister_netdevice_queue();
>>  7)   0.043 us    |        macvlan_device_event [macvlan]();
>>  7)   5.053 us    |      }
>>  7)               |      macvlan_dellink [macvlan]() {
>>  7)   0.055 us    |        unregister_netdevice_queue();
>>  7)   0.042 us    |        macvlan_device_event [macvlan]();
>>  7)   4.760 us    |      }
>>  7)               |      macvlan_dellink [macvlan]() {
>>  7)   0.052 us    |        unregister_netdevice_queue();
>>  7)   0.043 us    |        macvlan_device_event [macvlan]();
>>  7)   4.977 us    |      }
>>  7)               |      unregister_netdevice_many() {
>>  2)   0.142 us    |        unregister_netdevice_many();
>>  2)   0.090 us    |        macvlan_device_event [macvlan]();
>>  2)               |        macvlan_uninit [macvlan]() {
>>  2)               |          /* macvlan_uninit: macvlan port is empty... */
>>  2)   0.625 us    |        }
>>  2)   0.059 us    |        macvlan_get_size [macvlan]();
>>  2)   0.341 us    |        macvlan_dev_get_stats64 [macvlan]();
>>  2)   0.186 us    |        macvlan_fill_info [macvlan]();
>>  2)   0.084 us    |        unregister_netdevice_many();
>>  2)   0.046 us    |        macvlan_device_event [macvlan]();
>>  2)               |        macvlan_uninit [macvlan]() {
>>  2)               |          /* macvlan_uninit: macvlan port is empty... */
>>  2)   0.368 us    |        }
>>  2)   0.033 us    |        macvlan_get_size [macvlan]();
>>  2)   0.321 us    |        macvlan_dev_get_stats64 [macvlan]();
>>  2)   0.111 us    |        macvlan_fill_info [macvlan]();
>>  2)   0.046 us    |        unregister_netdevice_many();
>>  2)   0.044 us    |        macvlan_device_event [macvlan]();
>>  2)               |        macvlan_uninit [macvlan]() {
>>  2)               |          /* macvlan_uninit: macvlan port is empty... */
>>  2)   0.332 us    |        }
>>  2)   0.032 us    |        macvlan_get_size [macvlan]();
>>  2)   0.273 us    |        macvlan_dev_get_stats64 [macvlan]();
>>  2)   0.110 us    |        macvlan_fill_info [macvlan]();
>>  2)   0.057 us    |        unregister_netdevice_many();
>>  2)   0.044 us    |        macvlan_device_event [macvlan]();
>>  2)               |        macvlan_uninit [macvlan]() {
>>  2)               |          /* macvlan_uninit: macvlan port is empty... */
>>  2) ! 745.443 us  |          macvlan_port_destroy [macvlan]();
>>  2) ! 746.430 us  |        }
>>  2)   0.057 us    |        macvlan_get_size [macvlan]();
>>  2)   0.299 us    |        macvlan_dev_get_stats64 [macvlan]();
>>  2)   0.195 us    |        macvlan_fill_info [macvlan]();
>>  1) ! 1502.454 us |      } /* unregister_netdevice_many */
>>  1) ! 1533.944 us |    } /* macvlan_device_event [macvlan] */
>>  4) ! 77965.18 us |  } /* unregister_netdevice_queue */
> 
> This was done on the head of net tree with the offending patch reverted,
> but I also added in a trace_printk to show when the macvlan port was
> empty via the list_head vlans parameter. As you can see above, the
> macvlan_uninit is called multiple, but only after the dellink has been
> called. We call list_del on the vlan item in macvlan_dellink, but then
> we later call macvlan_uninit for each item. Because we deleted the item
> from the list in macvlan_dellink, the list is already emptied completely
> by the time we call macvlan_uninit. In the bugged case, we would have
> ended up calling macvlan_port_destroy for each macvlan we created. (Four
> in my scenario above.)
> 
> I think a possible fix besides simply reverting the patch might be to
> move the list_del into the macvlan_uninit. This is the same place we
> originally decremented the count, so thus makes more sense than doing
> the list_del in the macvlan_dellink function.
> 
> Hopefully the above provided information is enough to determine a good
> solution to resolve the issue. My opinion is that either the above
> list_del fix or simply reverting this patch is enough.
> 
> As one final note for stable maintainers, I believe that this bug is in
> 3.15 and 3.16.
> 
> Regards,
> Jak
> 
