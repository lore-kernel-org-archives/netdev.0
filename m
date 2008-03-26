From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: 2.6.24 BUG: soft lockup - CPU#X
Date: Wed, 26 Mar 2008 09:46:32 -0700
Message-ID: <47EA7DE8.9070203@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:48412 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753935AbYCZQyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 12:54:43 -0400
Received: from fe-sfbay-09.sun.com ([192.18.43.129])
	by sca-es-mail-2.sun.com (8.13.7+Sun/8.12.9) with ESMTP id m2QGllfi009832
	for <netdev@vger.kernel.org>; Wed, 26 Mar 2008 09:47:47 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-09.sun.com by fe-sfbay-09.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0JYC00701JT2V000@fe-sfbay-09.sun.com>
 (original mail from Matheos.Worku@Sun.COM) for netdev@vger.kernel.org; Wed,
 26 Mar 2008 09:47:47 -0700 (PDT)
Received: from [129.146.59.102] by fe-sfbay-09.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 with ESMTPSA id <0JYC00IJUJZJ9ZF0@fe-sfbay-09.sun.com> for
 netdev@vger.kernel.org; Wed, 26 Mar 2008 09:47:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All,

While running iperf (transmit) on NIU driver I get several soft lockup 
errors.  I have seen similar soft lockup errors on kernels 2.6.18 and 
later (with other 10G NIC drivers with LSO disabled) but it is more 
frequent/pronounced on 2.6.24 kernel.  oprofile is not giving  much clue 
as where the cpus are spending time (atleast doesn't indicate any thing 
abnormal in the driver(s)). The lockup location as indicated by the 
error message is not consistent and varies from time time and could be 
outside the driver as well.  I have attached several lockup  error 
traces and corresponding profile data. Any clues?

Regards
matheos


Test system is 8xdual core AMD opteron, with 8 cpus booted.


[root@nsn57-110 ~]# more /proc/cpuinfo
processor       : 0
vendor_id       : AuthenticAMD
cpu family      : 15
model           : 33
model name      : Dual Core AMD Opteron(tm) Processor 885
stepping        : 2
cpu MHz         : 1000.000
cache size      : 1024 KB
physical id     : 0
siblings        : 2
core id         : 0
cpu cores       : 2
fpu             : yes
fpu_exception   : yes
cpuid level     : 1
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge 
mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext 
fxsr_opt lm 3dnowext 3dnow rep_good pni lahf_lm cmp_legacy
bogomips        : 2019.84
TLB size        : 1024 4K pages
clflush size    : 64
cache_alignment : 64
address sizes   : 40 bits physical, 48 bits virtual
power management: ts fid vid ttp


nsn57-110 login: BUG: soft lockup - CPU#3 stuck for 11s! [iperf:9064]
CPU 3:
Modules linked in: oprofile niu nfs lockd nfs_acl autofs4 hidp rfcomm 
l2cap bluetooth sunrpc ipv6 cpufreq_ondemand rdma_ucm ib_ucm rdma_cm 
iw_cm ib_addr ib_srp scsi_transport_srp  ib_cm ib_ipoib ib_sa ib_uverbs 
ib_umad ib_mad ib_core dm_multipath battery ac parport_pc lp parport 
joydev sr_mod sg e1000 button i2c_nforce2 pcspkr shpchp i2c_core 
dm_snapshotdm_zero dm_mirror dm_mod usb_storage mptsas mptscsih mptbase 
scsi_transport_sas sd_mod scsi_mod ext3 jbd ehci_hcd ohci_hcd uhci_hcd
Pid: 9064, comm: iperf Not tainted 2.6.24-mati #3
RIP: 0010:[<ffffffff80406fb8>]  [<ffffffff80406fb8>] 
pfifo_fast_dequeue+0x3b/0x59
RSP: 0018:ffff8101bece5a20  EFLAGS: 00000286
RAX: 00000000000005ea RBX: ffff8101ced38000 RCX: ffff8102f397a990
RDX: ffff8102facead10 RSI: 000000000000004d RDI: ffff8102faceac00
RBP: ffff8103e10ab700 R08: 0000000000000003 R09: 0400000000000000
R10: 00000003e9d5d700 R11: ffffffff80221995 R12: ffffffff882ee016
R13: ffff8103e9d5d100 R14: 0000000000000006 R15: ffff8103e58a8ed0
FS:  000000004700d940(0063) GS:ffff8101fb072e00(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00000032e6e95770 CR3: 00000001d051a000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400

Call Trace:
 [<ffffffff80406d65>] __qdisc_run+0x31/0x174
 [<ffffffff803f8139>] dev_queue_xmit+0x141/0x270
 [<ffffffff8041a17c>] ip_queue_xmit+0x343/0x396
 [<ffffffff8028596d>] add_partial_tail+0x12/0x3f
 [<ffffffff80267f23>] get_pageblock_flags_group+0x3e/0x7f
 [<ffffffff80267f23>] get_pageblock_flags_group+0x3e/0x7f
 [<ffffffff80429176>] tcp_transmit_skb+0x69f/0x6dc
 [<ffffffff8042aee0>] __tcp_push_pending_frames+0x79f/0x878
 [<ffffffff80427d69>] tcp_rcv_established+0x108/0x6f3
 [<ffffffff8042dab0>] tcp_v4_do_rcv+0x30/0x3a1
 [<ffffffff803ece3e>] release_sock+0x60/0xbf
 [<ffffffff8042048d>] tcp_sendmsg+0x968/0xa67
 [<ffffffff803ea812>] sock_aio_write+0xf8/0x110
 [<ffffffff8028c3b0>] do_sync_write+0xc9/0x10c
 [<ffffffff8027302b>] handle_mm_fault+0x668/0x69b
 [<ffffffff802480e0>] autoremove_wake_function+0x0/0x2e
 [<ffffffff8028cb6b>] vfs_write+0xd9/0x14f
 [<ffffffff8028d0ae>] sys_write+0x45/0x6e
 [<ffffffff8020b7fc>] tracesys+0xdc/0xe1

BUG: soft lockup - CPU#3 stuck for 11s! [iperf:9064]
CPU 3:
Modules linked in: oprofile niu nfs lockd nfs_acl autofs4 hidp rfcomm 
l2cap bluetooth sunrpc ipv6 cpufreq_ondemand rdma_ucm ib_ucm rdma_cm 
iw_cm ib_addr ib_srp scsi_transport_srp  ib_cm ib_ipoib ib_sa ib_uverbs 
ib_umad ib_mad ib_core dm_multipath battery ac parport_pc lp parport 
joydev sr_mod sg e1000 button i2c_nforce2 pcspkr shpchp i2c_core 
dm_snapshotdm_zero dm_mirror dm_mod usb_storage mptsas mptscsih mptbase 
scsi_transport_sas sd_mod scsi_mod ext3 jbd ehci_hcd ohci_hcd uhci_hcd
Pid: 9064, comm: iperf Not tainted 2.6.24-mati #3
RIP: 0010:[<ffffffff802219c8>]  [<ffffffff802219c8>] 
gart_map_single+0x33/0x70
RSP: 0018:ffff8101bece5968  EFLAGS: 00000246
RAX: 00000002f656e100 RBX: 0000000000000600 RCX: 0000000000000001
RDX: 0000000000000600 RSI: ffff8102f656e100 RDI: ffff8102f656e100
RBP: 0000000000000000 R08: 4000111900000000 R09: 0050000000000000
R10: 0000000000000000 R11: ffffffff80221995 R12: 0000000000000286
R13: ffff8103fba11200 R14: ffff8103e9913100 R15: ffffffff8026fc8b
FS:  000000004700d940(0063) GS:ffff8101fb072e00(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00000032e6e95770 CR3: 00000001d051a000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400

Call Trace:
 [<ffffffff802219c1>] gart_map_single+0x2c/0x70
 [<ffffffff882edf65>] :niu:niu_start_xmit+0x339/0x5af
 [<ffffffff80221995>] gart_map_single+0x0/0x70
 [<ffffffff803f5e2b>] dev_hard_start_xmit+0x1d2/0x246
 [<ffffffff80406fa1>] pfifo_fast_dequeue+0x24/0x59
 [<ffffffff80406dab>] __qdisc_run+0x77/0x174
 [<ffffffff803f8139>] dev_queue_xmit+0x141/0x270
 [<ffffffff8041a17c>] ip_queue_xmit+0x343/0x396
 [<ffffffff8028596d>] add_partial_tail+0x12/0x3f
 [<ffffffff80267f23>] get_pageblock_flags_group+0x3e/0x7f
 [<ffffffff80267f23>] get_pageblock_flags_group+0x3e/0x7f
 [<ffffffff80429176>] tcp_transmit_skb+0x69f/0x6dc
 [<ffffffff8042aee0>] __tcp_push_pending_frames+0x79f/0x878
 [<ffffffff80427d69>] tcp_rcv_established+0x108/0x6f3
 [<ffffffff8042dab0>] tcp_v4_do_rcv+0x30/0x3a1
 [<ffffffff803ece3e>] release_sock+0x60/0xbf
 [<ffffffff8042048d>] tcp_sendmsg+0x968/0xa67
 [<ffffffff803ea812>] sock_aio_write+0xf8/0x110
 [<ffffffff8028c3b0>] do_sync_write+0xc9/0x10c
 [<ffffffff8027302b>] handle_mm_fault+0x668/0x69b
 [<ffffffff802480e0>] autoremove_wake_function+0x0/0x2e
 [<ffffffff8028cb6b>] vfs_write+0xd9/0x14f
 [<ffffffff8028d0ae>] sys_write+0x45/0x6e
 [<ffffffff8020b7fc>] tracesys+0xdc/0xe1


CPU: AMD64 processors, speed 1000 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Cycles outside of halt state) with a 
unit mask of 0x00 (No unit mask) count 100000
Samples on CPU 0
Samples on CPU 1
Samples on CPU 2
Samples on CPU 3
Samples on CPU 4
Samples on CPU 5
Samples on CPU 6
Samples on CPU 7
samples  %        samples  %        samples  %        samples  %        
samples  %        samples  %        samples  %        samples  %        
image name               app name                 symbol name
35847    10.0121  15879     5.5917  83932     5.8174  176125   19.8328  
339527   17.1392  290339   14.6522  316262   17.6201  391473   17.5484  
vmlinux
                vmlinux                  _raw_spin_lock
33542     9.3683  13947     4.9113  4596      0.3186  54781     6.1687  
5327      0.2689  4976      0.2511  14967     0.8339  13636     0.6113  
niu.ko
                niu                      niu_start_xmit
20350     5.6838  21907     7.7144  54143     3.7527  69738     7.8530  
239428   12.0862  208502   10.5222  285560   15.9096  184698    8.2794  
vmlinux
                vmlinux                  copy_user_generic_string
13818     3.8594  12931     4.5535  9246      0.6408  24130     2.7172  
66874     3.3758  60730     3.0648  52617     2.9315  83159     3.7277  
vmlinux
                vmlinux                  tcp_ack
12375     3.4563  10647     3.7492  6462      0.4479  16099     1.8129  
45097     2.2765  41207     2.0795  33129     1.8457  56178     2.5183  
vmlinux
                vmlinux                  __tcp_select_window
11995     3.3502  8815      3.1041  5267      0.3651  15376     1.7314  
42396     2.1401  39193     1.9779  29124     1.6226  57981     2.5991  
vmlinux
                vmlinux                  __copy_skb_header
10350     2.8908  7941      2.7964  11467     0.7948  27716     3.1210  
64291     3.2454  56789     2.8659  52322     2.9151  80111     3.5911  
vmlinux
                vmlinux                  __tcp_push_pending_frames
9191      2.5671  2121      0.7469  1062      0.0736  13214     1.4880  
1180      0.0596  1195      0.0603  4256      0.2371  3715      0.1665  
vmlinux
                vmlinux                  pfifo_fast_dequeue
9141      2.5531  5952      2.0959  4051      0.2808  10781     1.2140  
30384     1.5338  28521     1.4393  22391     1.2475  41852     1.8761  
vmlinux
                vmlinux                  free_hot_cold_page
8095      2.2609  2488      0.8761  1697      0.1176  17957     2.0221  
1959      0.0989  1626      0.0821  5020      0.2797  4570      0.2049  
vmlinux
                vmlinux                  __qdisc_run
7922      2.2126  5276      1.8579  6511      0.4513  15156     1.7067  
43016     2.1714  39552     1.9960  32309     1.8001  52778     2.3659  
vmlinux
                vmlinux                  kmem_cache_free
7700      2.1506  6904      2.4312  7348      0.5093  17601     1.9820  
48613     2.4540  40715     2.0547  35488     1.9772  57007     2.5554  
vmlinux
                vmlinux                  ip_queue_xmit
7543      2.1068  6779      2.3872  23039     1.5969  50172     5.6497  
132212    6.6740  112382    5.6715  107581    5.9937  161639    7.2457  
vmlinux
                vmlinux                  dev_queue_xmit
7404      2.0679  8373      2.9485  193876   13.4377  2406      0.2709  
7016      0.3542  45116     2.2768  6269      0.3493  7755      0.3476  
vmlinux
                vmlinux                  skb_release_data
7369      2.0582  8834      3.1108  77903     5.3995  19075     2.1480  
47375     2.3915  61162     3.0866  36048     2.0084  57243     2.5660  
niu.ko
                niu                      niu_interrupt
7207      2.0129  8108      2.8552  56756     3.9338  16089     1.8117  
40057     2.0221  49214     2.4836  33659     1.8753  51010     2.2866  
niu.ko
                niu                      niu_poll
6914      1.9311  4099      1.4434  1058      0.0733  3846      0.4331  
11434     0.5772  11337     0.5721  6269      0.3493  19662     0.8814  
vmlinux
                vmlinux                  get_pageblock_flags_group
5883      1.6431  2139      0.7532  793       0.0550  10490     1.1812  
824       0.0416  779       0.0393  2586      0.1441  2272      0.1018  
vmlinux
                vmlinux                  sock_wfree
5855      1.6353  5284      1.8607  4817      0.3339  16055     1.8079  
35248     1.7793  32311     1.6306  25091     1.3979  49224     2.2065  
vmlinux
                vmlinux                  skb_copy_bits
5665      1.5822  6456      2.2734  12491     0.8658  15495     1.7448  
56038     2.8288  49153     2.4806  69654     3.8807  43563     1.9528  
vmlinux
                vmlinux                  tcp_sendmsg
5094      1.4228  3513      1.2371  1318      0.0914  4933      0.5555  
16424     0.8291  15262     0.7702  10637     0.5926  21869     0.9803  
vmlinux
                vmlinux                  tcp_set_skb_tso_segs
4958      1.3848  4813      1.6949  165349   11.4605  6882      0.7750  
16981     0.8572  44073     2.2242  9780      0.5449  20187     0.9049  
vmlinux
                vmlinux                  skb_release_all
4767      1.3314  4185      1.4737  16709     1.1581  36711     4.1339  
69252     3.4958  57613     2.9075  62623     3.4890  101863    4.5662  
vmlinux
                vmlinux                  pfifo_fast_enqueue
4678      1.3066  3174      1.1177  3419      0.2370  10220     1.1508  
27198     1.3729  24120     1.2172  20724     1.1546  37027     1.6598  
vmlinux
                vmlinux                  tcp_transmit_skb
4532      1.2658  3820      1.3452  12096     0.8384  38766     4.3653  
14964     0.7554  13336     0.6730  17124     0.9540  18142     0.8132  
vmlinux
                vmlinux                  _raw_spin_unlock
4440      1.2401  5000      1.7607  144565   10.0199  0              0  
0              0  40207     2.0291  0              0  0              0  
niu.ko
                niu                      niu_pci_unmap_single
4421      1.2348  4625      1.6287  77354     5.3615  4        4.5e-04  
2        1.0e-04  15377     0.7760  5        2.8e-04  1        4.5e-05  
vmlinux
                vmlinux                  kfree_skb
4264      1.1909  4006      1.4107  3971      0.2752  10260     1.1553  
30687     1.5491  27278     1.3766  24134     1.3446  36029     1.6151  
vmlinux
                vmlinux                  kmem_cache_alloc_node
4094      1.1435  3503      1.2336  3712      0.2573  7679      0.8647  
23417     1.1821  21114     1.0655  21857     1.2177  28370     1.2717  
vmlinux
                vmlinux                  kfree
2964      0.8278  2503      0.8814  2183      0.1513  7702      0.8673  
20190     1.0192  18987     0.9582  13373     0.7451  26578     1.1914  
vmlinux
                vmlinux                  tcp_v4_rcv
2822      0.7882  2502      0.8811  1811      0.1255  6020      0.6779  
20457     1.0327  19217     0.9698  15003     0.8359  27615     1.2379  
vmlinux
                vmlinux                  local_bh_enable
2815      0.7862  2004      0.7057  1814      0.1257  3225      0.3632  
14068     0.7101  13196     0.6659  8887      0.4951  17759     0.7961  
vmlinux
                vmlinux                  __slab_free
2731      0.7628  3904      1.3748  236108   16.3649  0              0  
0              0  51620     2.6051  0              0  0              0  
niu.ko
                niu                      release_tx_packet
2693      0.7522  897       0.3159  402       0.0279  3862      0.4349  
859       0.0434  740       0.0373  1872      0.1043  1605      0.0719  
vmlinux
                vmlinux                  dev_hard_start_xmit
2633      0.7354  2183      0.7687  2805      0.1944  5772      0.6500  
15536     0.7843  13160     0.6641  11056     0.6160  15467     0.6933  
vmlinux
                vmlinux                  ip_finish_output
2567      0.7170  1542      0.5430  3680      0.2551  4625      0.5208  
14971     0.7557  13076     0.6599  16538     0.9214  11771     0.5277  
vmlinux
                vmlinux                  get_page_from_freelist
2504      0.6994  1623      0.5715  1093      0.0758  3293      0.3708  
10124     0.5111  9167      0.4626  7378      0.4111  14708     0.6593  
vmlinux
                vmlinux                  skb_clone
2437      0.6807  816       0.2873  374       0.0259  3701      0.4168  
696       0.0351  618       0.0312  1463      0.0815  1226      0.0550  
vmlinux
                vmlinux                  gart_map_single
2424      0.6770  2060      0.7254  84        0.0058  206       0.0232  
543       0.0274  1183      0.0597  593       0.0330  820       0.0368  
vmlinux
                vmlinux                  eth_header
2007      0.5606  2392      0.8423  7641      0.5296  12076     1.3598  
38413     1.9391  33796     1.7055  40611     2.2626  34932     1.5659  
vmlinux
                vmlinux                  __alloc_skb
1958      0.5469  856       0.3014  2011      0.1394  6385      0.7190  
19324     0.9755  16077     0.8113  11571     0.6447  22939     1.0283  
vmlinux
                vmlinux                  __phys_addr
1868      0.5217  1310      0.4613  4119      0.2855  5267      0.5931  
17008     0.8586  15217     0.7679  19030     1.0602  15463     0.6932  
vmlinux
                vmlinux                  memset_c
1834      0.5122  558       0.1965  344       0.0238  4411      0.4967  
572       0.0289  528       0.0266  1401      0.0781  1332      0.0597  
niu.ko
                niu                      niu_set_txd
1702      0.4754  1381      0.4863  148       0.0103  859       0.0967  
2748      0.1387  2943      0.1485  1009      0.0562  5099      0.2286  
vmlinux
                vmlinux                  free_pages_bulk
1402      0.3916  1614      0.5684  1566      0.1085  5598      0.6304  
10886     0.5495  10396     0.5246  8331      0.4642  13281     0.5953  
vmlinux
                vmlinux                  __pskb_pull_tail
1321      0.3690  1058      0.3726  1253      0.0868  2939      0.3310  
9312      0.4701  7869      0.3971  6736      0.3753  10654     0.4776  
vmlinux
                vmlinux                  tcp_rcv_established
1314      0.3670  11301     3.9795  8380      0.5808  2592      0.2919  
11391     0.5750  1007      0.0508  4551      0.2536  2900      0.1300  
oprofiled                oprofiled                (no symbols)
1311      0.3662  1701      0.5990  1919      0.1330  527       0.0593  
5967      0.3012  5769      0.2911  11960     0.6663  1958      0.0878  
vmlinux
                vmlinux                  __rmqueue
1218      0.3402  635       0.2236  287       0.0199  486       0.0547  
1996      0.1008  2162      0.1091  1289      0.0718  2629      0.1178  
vmlinux
                vmlinux                  __mod_zone_page_state
1177      0.3287  1256      0.4423  1969      0.1365  6394      0.7200  
15622     0.7886  14234     0.7183  11927     0.6645  20082     0.9002  
vmlinux
                vmlinux                  netif_receive_skb
1072      0.2994  1093      0.3849  2235      0.1549  5437      0.6122  
13295     0.6711  12614     0.6366  11498     0.6406  17651     0.7912  
vmlinux
                vmlinux                  ip_route_input
1043      0.2913  680       0.2395  737       0.0511  1932      0.2176  
5400      0.2726  5268      0.2659  4528      0.2523  6865      0.3077  
vmlinux
                vmlinux                  put_page
1034      0.2888  447       0.1574  2398      0.1662  4145      0.4668  
26089     1.3170  24902     1.2567  13333     0.7428  14704     0.6591  
vmlinux
                vmlinux                  __delay
996       0.2782  751       0.2645  21850     1.5144  258       0.0291  
809       0.0408  6957      0.3511  557       0.0310  1027      0.0460  
vmlinux
                vmlinux                  gart_unmap_single
953       0.2662  711       0.2504  1331      0.0923  3741      0.4213  
16598     0.8379  14805     0.7471  5559      0.3097  17815     0.7986  
vmlinux
                vmlinux                  ip_local_deliver
947       0.2645  250       0.0880  1315      0.0911  56        0.0063  
876       0.0442  1013      0.0511  1247      0.0695  255       0.0114  
iperf
                iperf                    reporter_condprintstats
930       0.2597  939       0.3307  936       0.0649  3379      0.3805  
6289      0.3175  6103      0.3080  5442      0.3032  9742      0.4367  
niu.ko
                niu                      niu_find_rxpage
885       0.2472  1082      0.3810  76280     5.2870  533       0.0600  
1716      0.0866  21803     1.1003  1219      0.0679  2108      0.0945  
vmlinux
                vmlinux                  __kfree_skb
876       0.2447  775       0.2729  869       0.0602  2878      0.3241  
7079      0.3573  6356      0.3208  3648      0.2032  8924      0.4000  
vmlinux
                vmlinux                  ip_local_deliver_finish
864       0.2413  552       0.1944  3143      0.2178  6539      0.7363  
18190     0.9182  16338     0.8245  12059     0.6719  20170     0.9042  
vmlinux
                vmlinux                  pfn_to_page
831       0.2321  815       0.2870  71        0.0049  167       0.0188  
440       0.0222  698       0.0352  422       0.0235  650       0.0291  
vmlinux
                vmlinux                  _raw_read_lock
779       0.2176  679       0.2391  2057      0.1426  2551      0.2873  
11112     0.5609  10998     0.5550  13292     0.7405  10674     0.4785  
vmlinux
                vmlinux                  __kmalloc_node_track_caller
700       0.1955  358       0.1261  46        0.0032  81        0.0091  
206       0.0104  294       0.0148  271       0.0151  262       0.0117  
vmlinux
                vmlinux                  local_bh_enable_ip
682       0.1905  853       0.3004  29        0.0020  82        0.0092  
117       0.0059  238       0.0120  170       0.0095  236       0.0106  
vmlinux
                vmlinux                  neigh_resolve_output
640       0.1788  398       0.1402  457       0.0317  838       0.0944  
2527      0.1276  2174      0.1097  3696      0.2059  4044      0.1813  
vmlinux
                vmlinux                  tcp_init_tso_segs
639       0.1785  428       0.1507  541       0.0375  348       0.0392  
1888      0.0953  1729      0.0873  3567      0.1987  838       0.0376  
vmlinux
                vmlinux                  __rmqueue_smallest
626       0.1748  485       0.1708  678       0.0470  1686      0.1899  
3472      0.1753  3666      0.1850  2181      0.1215  4042      0.1812  
vmlinux
                vmlinux                  page_to_pfn
596       0.1665  571       0.2011  202       0.0140  434       0.0489  
1472      0.0743  1303      0.0658  1399      0.0779  1285      0.0576  
vmlinux
                vmlinux                  new_slab
535       0.1494  838       0.2951  854       0.0592  2850      0.3209  
7345      0.3708  5461      0.2756  8328      0.4640  7682      0.3444  
vmlinux
                vmlinux                  ip_rcv_finish
519       0.1450  505       0.1778  3538      0.2452  3250      0.3660  
16741     0.8451  16927     0.8542  23509     1.3098  14544     0.6520  
vmlinux
                vmlinux                  __slab_alloc
509       0.1422  438       0.1542  467       0.0324  1647      0.1855  
4471      0.2257  3949      0.1993  2904      0.1618  5552      0.2489  
vmlinux
                vmlinux                  ___pskb_trim
497       0.1388  402       0.1416  422       0.0292  1373      0.1546  
3719      0.1877  3156      0.1593  2957      0.1647  4635      0.2078  
vmlinux
                vmlinux                  tcp_rtt_estimator
487       0.1360  348       0.1225  502       0.0348  160       0.0180  
1626      0.0821  1474      0.0744  2784      0.1551  684       0.0307  
vmlinux
                vmlinux                  rmqueue_bulk
455       0.1271  360       0.1268  355       0.0246  483       0.0544  
3794      0.1915  3716      0.1875  3955      0.2203  5553      0.2489  
vmlinux
                vmlinux                  add_partial_tail


======

nsn57-110 login: BUG: soft lockup - CPU#3 stuck for 11s! [iperf:10566]
CPU 3:
Modules linked in: oprofile niu nfs lockd nfs_acl autofs4 hidp rfcomm 
l2cap bluetooth sunrpc ipv6 cpufreq_ondemand rdma_ucm ib_ucm rdma_cm 
iw_cm ib_addr ib_srp scsi_transport_srp ib_cm ib_ipoib ib_sa ib_uverbs 
ib_umad ib_mad ib_core dm_multipath battery ac parport_pc lp parport 
joydev sr_mod sg e1000 button i2c_nforce2 pcspkr shpchp i2c_core 
dm_snapshot dm_zero dm_mirror dm_mod usb_storage mptsas mptscsih mptbase 
scsi_transport_sas sd_mod scsi_mod ext3 jbd ehci_hcd ohci_hcd uhci_hcd
Pid: 10566, comm: iperf Not tainted 2.6.24-mati #3
RIP: 0010:[<ffffffff80316d29>]  [<ffffffff80316d29>] 
_raw_spin_lock+0x7d/0xf6
RSP: 0018:ffff8101f99bb9f8  EFLAGS: 00000246
RAX: 0000000000000000 RBX: 000000000000000e RCX: 00000000a0c5b122
RDX: 0000000000003b06 RSI: 0000000000000033 RDI: 0000000000000001
RBP: ffffffff803eecfd R08: 0000000000000003 R09: 0400000000000000
R10: 00000003e24a9700 R11: ffffffff80221995 R12: ffffffff802219c1
R13: ffff8103db913450 R14: ffff8101ced38000 R15: ffff8103dd5c0700
FS:  000000004580a940(0063) GS:ffff8101fb072e00(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00002b762a36c050 CR3: 00000001c6950000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400

Call Trace:
 [<ffffffff80316d3a>] _raw_spin_lock+0x8e/0xf6
 [<ffffffff80406e8a>] __qdisc_run+0x156/0x174
 [<ffffffff80406dd2>] __qdisc_run+0x9e/0x174
 [<ffffffff803f8139>] dev_queue_xmit+0x141/0x270
 [<ffffffff8041a17c>] ip_queue_xmit+0x343/0x396
 [<ffffffff80429176>] tcp_transmit_skb+0x69f/0x6dc
 [<ffffffff8042aee0>] __tcp_push_pending_frames+0x79f/0x878
 [<ffffffff80427d69>] tcp_rcv_established+0x108/0x6f3
 [<ffffffff8042dab0>] tcp_v4_do_rcv+0x30/0x3a1
 [<ffffffff803ece3e>] release_sock+0x60/0xbf
 [<ffffffff8042048d>] tcp_sendmsg+0x968/0xa67
 [<ffffffff8026fc8b>] zone_statistics+0x3f/0x60
 [<ffffffff803ea812>] sock_aio_write+0xf8/0x110
 [<ffffffff8042048d>] tcp_sendmsg+0x968/0xa67
 [<ffffffff8028c3b0>] do_sync_write+0xc9/0x10c
 [<ffffffff8027302b>] handle_mm_fault+0x668/0x69b
 [<ffffffff802480e0>] autoremove_wake_function+0x0/0x2e
 [<ffffffff8022b995>] __dequeue_entity+0x1c/0x32
 [<ffffffff8045e4a1>] _spin_unlock_irq+0x9/0xc
 [<ffffffff802314ce>] finish_task_switch+0x37/0x83
 [<ffffffff8028cb6b>] vfs_write+0xd9/0x14f
 [<ffffffff8028d0ae>] sys_write+0x45/0x6e
 [<ffffffff8020b7fc>] tracesys+0xdc/0xe1

BUG: soft lockup - CPU#3 stuck for 11s! [iperf:10557]
CPU 3:
Modules linked in: oprofile niu nfs lockd nfs_acl autofs4 hidp rfcomm 
l2cap bluetooth sunrpc ipv6 cpufreq_ondemand rdma_ucm ib_ucm rdma_cm 
iw_cm ib_addr ib_srp scsi_transport_srp  ib_cm ib_ipoib ib_sa ib_uverbs 
ib_umad ib_mad ib_core dm_multipath battery ac parport_pc lp parport 
joydev sr_mod sg e1000 button i2c_nforce2 pcspkr shpchp i2c_core 
dm_snapshotdm_zero dm_mirror dm_mod usb_storage mptsas mptscsih mptbase 
scsi_transport_sas sd_mod scsi_mod ext3 jbd ehci_hcd ohci_hcd uhci_hcd
Pid: 10557, comm: iperf Not tainted 2.6.24-mati #3
RIP: 0010:[<ffffffff882edf6c>]  [<ffffffff882edf6c>] 
:niu:niu_start_xmit+0x340/0x5af
RSP: 0018:ffff8101ac1f5998  EFLAGS: 00000293
RAX: 00000003ec4b7100 RBX: ffff8103e54cb610 RCX: 00000003ec4b7100
RDX: 00000fffffffffff RSI: ffff8103ec4b7100 RDI: ffff8103ec4b7100
RBP: ffffffff80221995 R08: ffffffff882edf84 R09: 0050000000000000
R10: 0000000000000000 R11: ffffffff80221995 R12: ffff8102f04d4ed0
R13: 0050000000000000 R14: 0000000000000000 R15: ffffffff80221995
FS:  0000000041001940(0063) GS:ffff8101fb072e00(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00002b762a36c050 CR3: 00000001c6950000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400

Call Trace:
 [<ffffffff882edf65>] :niu:niu_start_xmit+0x339/0x5af
 [<ffffffff803f5e2b>] dev_hard_start_xmit+0x1d2/0x246
 [<ffffffff80406e8a>] __qdisc_run+0x156/0x174
 [<ffffffff80406dab>] __qdisc_run+0x77/0x174
 [<ffffffff803f8139>] dev_queue_xmit+0x141/0x270
 [<ffffffff8041a17c>] ip_queue_xmit+0x343/0x396
 [<ffffffff8028596d>] add_partial_tail+0x12/0x3f
 [<ffffffff80267f23>] get_pageblock_flags_group+0x3e/0x7f
 [<ffffffff802868a5>] __slab_free+0x7a/0x2d5
 [<ffffffff80429176>] tcp_transmit_skb+0x69f/0x6dc
 [<ffffffff8042aee0>] __tcp_push_pending_frames+0x79f/0x878
 [<ffffffff80427d69>] tcp_rcv_established+0x108/0x6f3
 [<ffffffff8042dab0>] tcp_v4_do_rcv+0x30/0x3a1
 [<ffffffff803ece3e>] release_sock+0x60/0xbf
 [<ffffffff8042048d>] tcp_sendmsg+0x968/0xa67
 [<ffffffff802ec44d>] dummy_socket_sendmsg+0x0/0x3
 [<ffffffff803ea812>] sock_aio_write+0xf8/0x110
 [<ffffffff8042048d>] tcp_sendmsg+0x968/0xa67
 [<ffffffff8028c3b0>] do_sync_write+0xc9/0x10c
 [<ffffffff8027302b>] handle_mm_fault+0x668/0x69b
 [<ffffffff802480e0>] autoremove_wake_function+0x0/0x2e
 [<ffffffff8022b995>] __dequeue_entity+0x1c/0x32
 [<ffffffff8028cb6b>] vfs_write+0xd9/0x14f
 [<ffffffff8028d0ae>] sys_write+0x45/0x6e
 [<ffffffff8020b7fc>] tracesys+0xdc/0xe1



samples  %        samples  %        samples  %        samples  %        
samples  %        samples  %        samples  %        samples  %        
image name               app name                 symbol name
7382      5.6251  88        0.0707  39484    17.0818  23        0.0662  
222       0.0663  272       0.0697  483       0.1890  541       0.1645  
vmlinux
                vmlinux                  skb_release_data
5373      4.0942  0              0  29098    12.5885  0              0  
0              0  0              0  0              0  0              0  
niu.ko
                niu                      niu_pci_unmap_single
5143      3.9190  2411      1.9382  1314      0.5685  625       1.8001  
14759     4.4101  7958      2.0390  25960    10.1604  26348     8.0092  
vmlinux
                vmlinux                  _raw_spin_lock
4794      3.6530  4198      3.3748  4016      1.7374  1899      5.4695  
55928    16.7117  29035     7.4392  37442    14.6543  40278    12.2436  
vmlinux
                iperf                    copy_user_generic_string
4660      3.5509  248       0.1994  24570    10.6296  37        0.1066  
767       0.2292  648       0.1660  1125      0.4403  1301      0.3955  
vmlinux
                vmlinux                  skb_release_all
4633      3.5304  1274      1.0242  0              0  137       0.3946  
2946      0.8803  2362      0.6052  4198      1.6430  4657      1.4156  
vmlinux
                vmlinux                  tcp_ack
4620      3.5205  0              0  13861     5.9966  0              0  
0              0  0              0  0              0  0              0  
vmlinux
                vmlinux                  kfree_skb
4557      3.4724  0              0  41087    17.7753  0              0  
0              0  0              0  0              0  0              0  
niu.ko
                niu                      release_tx_packet
4518      3.4427  1410      1.1335  0              0  112       0.3226  
2227      0.6654  1844      0.4725  3439      1.3460  3756      1.1417  
vmlinux
                vmlinux                  __tcp_select_window
4080      3.1090  799       0.6423  0              0  288       0.8295  
6662      1.9907  4099      1.0502  10426     4.0806  11095     3.3726  
vmlinux
                vmlinux                  dev_queue_xmit
4023      3.0655  779       0.6263  66        0.0286  84        0.2419  
1632      0.4877  1249      0.3200  2576      1.0082  3005      0.9135  
vmlinux
                vmlinux                  free_hot_cold_page
3980      3.0328  1254      1.0081  0              0  105       0.3024  
2095      0.6260  1723      0.4415  3342      1.3080  3640      1.1065  
vmlinux
                vmlinux                  __copy_skb_header
3751      2.8583  1133      0.9108  0              0  165       0.4752  
3165      0.9457  2097      0.5373  5288      2.0697  5409      1.6442  
vmlinux
                vmlinux                  __tcp_push_pending_frames
3504      2.6701  611       0.4912  68        0.0294  61        0.1757  
1193      0.3565  917       0.2349  1990      0.7789  2300      0.6991  
vmlinux
                vmlinux                  get_pageblock_flags_group
3274      2.4948  488       0.3923  12477     5.3979  61        0.1757  
1828      0.5462  1409      0.3610  4512      1.7659  5579      1.6959  
niu.ko
                niu                      niu_interrupt
3197      2.4361  8745      7.0303  1519      0.6572  5717     16.4660  
33696    10.0686  51587    13.2174  15227     5.9596  25442     7.7338  
vmlinux
                iperf                    _raw_spin_lock
3172      2.4171  953       0.7661  66        0.0286  103       0.2967  
2313      0.6911  1719      0.4404  3461      1.3546  3618      1.0998  
vmlinux
                vmlinux                  kmem_cache_free
3168      2.4140  493       0.3963  9766      4.2250  67        0.1930  
1712      0.5116  1153      0.2954  3655      1.4305  4368      1.3278  
niu.ko
                niu                      niu_poll
2693      2.0521  436       0.3505  1        4.3e-04  191       0.5501  
3350      1.0010  2245      0.5752  6262      2.4509  7050      2.1430  
vmlinux
                vmlinux                  pfifo_fast_enqueue
2402      1.8303  676       0.5434  0              0  78        0.2247  
1472      0.4398  1137      0.2913  2471      0.9671  3098      0.9417  
vmlinux
                vmlinux                  skb_copy_bits
2297      1.7503  904       0.7267  1        4.3e-04  111       0.3197  
2129      0.6362  1700      0.4356  3091      1.2098  4294      1.3053  
vmlinux
                vmlinux                  ip_queue_xmit
1944      1.4813  2137      1.7180  0              0  0              0  
0              0  0              0  32        0.0125  353       0.1073  
niu.ko
                niu                      niu_start_xmit
1809      1.3785  624       0.5016  0              0  48        0.1382  
1044      0.3120  783       0.2006  1766      0.6912  1912      0.5812  
vmlinux
                vmlinux                  tcp_set_skb_tso_segs
1779      1.3556  644       0.5177  2        8.7e-04  48        0.1382  
1207      0.3607  736       0.1886  1831      0.7166  2233      0.6788  
vmlinux
                vmlinux                  tcp_transmit_skb
1534      1.1689  356       0.2862  6         0.0026  41        0.1181  
933       0.2788  604       0.1548  1465      0.5734  1527      0.4642  
vmlinux
                vmlinux                  kfree
1368      1.0424  1213      0.9752  1054      0.4560  511       1.4718  
13895     4.1519  6859      1.7574  10097     3.9518  10450     3.1766  
vmlinux
                iperf                    tcp_sendmsg
1341      1.0218  320       0.2573  0              0  43        0.1238  
893       0.2668  763       0.1955  2021      0.7910  2460      0.7478  
vmlinux
                vmlinux                  kmem_cache_alloc_node
1260      0.9601  30        0.0241  13743     5.9456  6         0.0173  
65        0.0194  60        0.0154  103       0.0403  124       0.0377  
vmlinux
                vmlinux                  __kfree_skb
1187      0.9045  365       0.2934  0              0  33        0.0950  
670       0.2002  472       0.1209  967       0.3785  1199      0.3645  
vmlinux
                vmlinux                  skb_clone
1185      0.9030  231       0.1857  0              0  29        0.0835  
843       0.2519  624       0.1599  1343      0.5256  1783      0.5420  
vmlinux
                vmlinux                  local_bh_enable
1107      0.8435  288       0.2315  0              0  40        0.1152  
878       0.2624  792       0.2029  1299      0.5084  1456      0.4426  
vmlinux
                vmlinux                  tcp_v4_rcv
1094      0.8336  296       0.2380  0              0  39        0.1123  
480       0.1434  412       0.1056  947       0.3706  1777      0.5402  
vmlinux
                vmlinux                  ip_finish_output
1051      0.8009  217       0.1744  13        0.0056  28        0.0806  
438       0.1309  312       0.0799  769       0.3010  818       0.2487  
vmlinux
                vmlinux                  free_pages_bulk
1016      0.7742  7593      6.1041  203       0.0878  2511      7.2321  
518       0.1548  2476      0.6344  388       0.1519  369       0.1122  
niu.ko
                iperf                    niu_start_xmit
935       0.7125  202       0.1624  32        0.0138  23        0.0662  
495       0.1479  355       0.0910  899       0.3519  742       0.2256  
vmlinux
                vmlinux                  __slab_free
902       0.6873  537       0.4317  0              0  0              0  
0              0  0              0  10        0.0039  99        0.0301  
vmlinux
                vmlinux                  __qdisc_run
787       0.5997  0              0  0              0  0              0  
462       0.1380  1080      0.2767  0              0  0              0  
libperl.so               perl                     (no symbols)
708       0.5395  8         0.0064  4378      1.8940  0              0  
21        0.0063  25        0.0064  60        0.0235  42        0.0128  
vmlinux
                vmlinux                  gart_unmap_single
660       0.5029  153       0.1230  0              0  27        0.0778  
554       0.1655  477       0.1222  914       0.3577  1055      0.3207  
vmlinux
                vmlinux                  ip_route_input

