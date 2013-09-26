From: Fengguang Wu <fengguang.wu@intel.com>
Subject: +157.8% netperf throughput by "ipv4: raise IP_MAX_MTU to theoretical
 limit"
Date: Thu, 26 Sep 2013 09:21:44 +0800
Message-ID: <20130926012144.GA9931@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Willem de Bruijn <willemb@google.com>, lkp@01.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

We are glad to find that your below commit brings large increase in
lo netperf throughput:

    35596b2796713c6a9dc0      734d2725db879f3f6fcd  
------------------------  ------------------------  
                  761.80      +534.6%      4834.60  lkp-ib03/micro/netperf/120s-200%-UDP_STREAM
                  168.10     +1317.4%      2382.70  lkp-nex04/micro/netperf/120s-200%-UDP_STREAM
                  169.60      +979.4%      1830.70  lkp-nex05/micro/netperf/120s-200%-UDP_STREAM
                 2154.20      +135.7%      5077.50  lkp-sb03/micro/netperf/120s-200%-UDP_STREAM
                 3559.00        -3.5%      3435.20  lkp-t410/micro/netperf/120s-200%-TCP_STREAM
                 6812.70      +157.8%     17560.70  TOTAL netperf.Throughput_Mbps

The side effects are some increased/decreased lock contentions:

    35596b2796713c6a9dc0      734d2725db879f3f6fcd  
------------------------  ------------------------  
                 7695.93    +16534.7%   1280196.60  lkp-ib03/micro/netperf/120s-200%-UDP_STREAM
                 1917.74   +159631.5%   3063227.91  lkp-nex04/micro/netperf/120s-200%-UDP_STREAM
                 2293.73   +118436.8%   2718918.57  lkp-nex05/micro/netperf/120s-200%-UDP_STREAM
                50823.71     +1881.3%   1006978.18  lkp-sb03/micro/netperf/120s-200%-UDP_STREAM
                62731.11    +12763.3%   8069321.26  TOTAL lock_stat.slock-AF_INET.waittime-total

    35596b2796713c6a9dc0      734d2725db879f3f6fcd  
------------------------  ------------------------  
                 7007.20    +17377.5%   1224681.80  lkp-ib03/micro/netperf/120s-200%-UDP_STREAM
                  960.80    +74382.1%    715623.90  lkp-nex04/micro/netperf/120s-200%-UDP_STREAM
                  951.40    +55033.2%    524536.90  lkp-nex05/micro/netperf/120s-200%-UDP_STREAM
                49582.00     +2141.1%   1111185.60  lkp-sb03/micro/netperf/120s-200%-UDP_STREAM
                58501.40     +6012.7%   3576028.20  TOTAL lock_stat.slock-AF_INET.contentions

    35596b2796713c6a9dc0      734d2725db879f3f6fcd  
------------------------  ------------------------  
                 7289.40    +16702.1%   1224771.60  lkp-ib03/micro/netperf/120s-200%-UDP_STREAM
                  922.40    +77764.1%    718218.60  lkp-nex04/micro/netperf/120s-200%-UDP_STREAM
                  910.10    +58394.1%    532355.20  lkp-nex05/micro/netperf/120s-200%-UDP_STREAM
                51325.70     +2062.2%   1109739.10  lkp-sb03/micro/netperf/120s-200%-UDP_STREAM
                60447.60     +5830.9%   3585084.50  TOTAL lock_stat.slock-AF_INET.contentions.udp_queue_rcv_skb

    35596b2796713c6a9dc0      734d2725db879f3f6fcd  
------------------------  ------------------------  
                 4266.20    +13915.1%    597912.60  lkp-ib03/micro/netperf/120s-200%-UDP_STREAM
                  560.50    +57667.0%    323783.90  lkp-nex04/micro/netperf/120s-200%-UDP_STREAM
                  518.80    +46369.9%    241086.00  lkp-nex05/micro/netperf/120s-200%-UDP_STREAM
                23391.50     +1891.7%    465887.80  lkp-sb03/micro/netperf/120s-200%-UDP_STREAM
                28737.00     +5567.5%   1628670.30  TOTAL lock_stat.&(&list->lock)->rlock#2.contentions.__skb_recv_datagram

    35596b2796713c6a9dc0      734d2725db879f3f6fcd  
------------------------  ------------------------  
                 4245.80    +13836.7%    591726.20  lkp-ib03/micro/netperf/120s-200%-UDP_STREAM
                  563.30    +57100.8%    322211.90  lkp-nex04/micro/netperf/120s-200%-UDP_STREAM
                  520.40    +45650.2%    238084.00  lkp-nex05/micro/netperf/120s-200%-UDP_STREAM
                23157.10     +1898.6%    462812.40  lkp-sb03/micro/netperf/120s-200%-UDP_STREAM
                28486.60     +5568.8%   1614834.50  TOTAL lock_stat.&(&list->lock)->rlock#2.contentions.sock_queue_rcv_skb

    35596b2796713c6a9dc0      734d2725db879f3f6fcd  
------------------------  ------------------------  
                  466.24    +20666.8%     96823.64  lkp-ib03/micro/netperf/120s-200%-UDP_STREAM
                  227.96    +39775.4%     90899.22  lkp-nex04/micro/netperf/120s-200%-UDP_STREAM
                  165.76    +63787.9%    105903.10  lkp-nex05/micro/netperf/120s-200%-UDP_STREAM
                 3031.79     +2325.1%     73523.25  lkp-sb03/micro/netperf/120s-200%-UDP_STREAM
                 3891.75     +9334.0%    367149.20  TOTAL lock_stat.&wq->wait.waittime-total

    35596b2796713c6a9dc0      734d2725db879f3f6fcd  
------------------------  ------------------------  
                  891.80    +21266.3%    190545.00  lkp-ib03/micro/netperf/120s-200%-UDP_STREAM
                  213.30    +50036.7%    106941.50  lkp-nex04/micro/netperf/120s-200%-UDP_STREAM
                  152.60    +58410.9%     89287.60  lkp-nex05/micro/netperf/120s-200%-UDP_STREAM
                 6143.00     +2623.3%    167291.40  lkp-sb03/micro/netperf/120s-200%-UDP_STREAM
                 7400.70     +7386.7%    554065.50  TOTAL lock_stat.&wq->wait.contentions.__wake_up_sync_key

    35596b2796713c6a9dc0      734d2725db879f3f6fcd  
------------------------  ------------------------  
              4174266.80     +3137.3% 135134002.00  lkp-ib03/micro/netperf/120s-200%-UDP_STREAM
              1541864.80     +3808.9%  60270231.50  lkp-nex04/micro/netperf/120s-200%-UDP_STREAM
              1754844.30     +3034.9%  55013405.80  lkp-nex05/micro/netperf/120s-200%-UDP_STREAM
             22053438.30      +263.9%  80244072.30  lkp-sb03/micro/netperf/120s-200%-UDP_STREAM
             29524414.20     +1020.0% 330661711.60  TOTAL lock_stat.&(&zone->lock)->rlock.contentions.__free_pages_ok

    35596b2796713c6a9dc0      734d2725db879f3f6fcd  
------------------------  ------------------------  
              4303082.60     +2809.1% 125179298.60  lkp-ib03/micro/netperf/120s-200%-UDP_STREAM
              1638845.10     +3613.5%  60859041.30  lkp-nex04/micro/netperf/120s-200%-UDP_STREAM
              1883848.20     +3012.7%  58638288.40  lkp-nex05/micro/netperf/120s-200%-UDP_STREAM
             22293114.60      +216.3%  70505512.80  lkp-sb03/micro/netperf/120s-200%-UDP_STREAM
             30118890.50      +946.5% 315182141.10  TOTAL lock_stat.&(&zone->lock)->rlock.contentions.get_page_from_freelist

    35596b2796713c6a9dc0      734d2725db879f3f6fcd  
------------------------  ------------------------  
               291821.83       -96.6%      9957.12  lkp-nex04/micro/netperf/120s-200%-UDP_STREAM
               400941.64       -94.0%     24083.56  lkp-nex05/micro/netperf/120s-200%-UDP_STREAM
               692763.47       -95.1%     34040.68  TOTAL lock_stat.&mm->mmap_sem/1.holdtime-max

    35596b2796713c6a9dc0      734d2725db879f3f6fcd  
------------------------  ------------------------  
             38718739.60       -95.8%   1637024.20  lkp-ib03/micro/netperf/120s-200%-UDP_STREAM
             13064940.40       -84.5%   2031181.40  lkp-nex05/micro/netperf/120s-200%-UDP_STREAM
             64201496.70       -98.2%   1166711.50  lkp-sb03/micro/netperf/120s-200%-UDP_STREAM
              2302513.00       -97.9%     48685.00  lkp-t410/micro/netperf/120s-200%-UDP_STREAM
            118287689.70       -95.9%   4883602.10  TOTAL lock_stat.&(&base->lock)->rlock.acquisitions
......

commit 734d2725db879f3f6fcdc2b1d2a5deae105f5e95
Author: Eric Dumazet <edumazet@google.com>
Date:   Sun Aug 18 19:08:07 2013 -0700

    ipv4: raise IP_MAX_MTU to theoretical limit
    
    As discussed last year [1], there is no compelling reason
    to limit IPv4 MTU to 0xFFF0, while real limit is 0xFFFF
    
    [1] : http://marc.info/?l=linux-netdev&m=135607247609434&w=2
    

:040000 040000 f2085347b7781a6a42020dc1bc5ca090f7077361 fcb2c411b5073c8ac5009a41f7a1908a352c23d5 M	net
bisect run success

# bad: [272b98c6455f00884f0350f775c5342358ebb73f] Linux 3.12-rc1
# good: [6e4664525b1db28f8c4e1130957f70a94c19213e] Linux 3.11
git bisect start '272b98c6455f00884f0350f775c5342358ebb73f' '6e4664525b1db28f8c4e1130957f70a94c19213e' '--'
# good: [57d730924d5cc2c3e280af16a9306587c3a511db] Merge branch 'timers-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect good 57d730924d5cc2c3e280af16a9306587c3a511db
# bad: [27c7651a6a5f143eccd66db38c7a3035e1f8bcfb] Merge tag 'gpio-v3.12-1' of git://git.kernel.org/pub/scm/linux/kernel/git/linusw/linux-gpio
git bisect bad 27c7651a6a5f143eccd66db38c7a3035e1f8bcfb
# bad: [06c54055bebf919249aa1eb68312887c3cfe77b4] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
git bisect bad 06c54055bebf919249aa1eb68312887c3cfe77b4
# bad: [d75ea942b360690a380da8012a51eaf6a6ebb1b1] can: flexcan: use platform_set_drvdata()
git bisect bad d75ea942b360690a380da8012a51eaf6a6ebb1b1
# good: [926489be1d2b030c17d38fa10b5921bf3409d91d] drivers: net: cpsw: Add support for new CPSW IP version present in AM43xx SoC
git bisect good 926489be1d2b030c17d38fa10b5921bf3409d91d
# good: [a5354ccaaf54ac61c6d1b350e8d3e4234dd28849] ath9k: Enable WLAN/BT Ant Diversity for WB225/WB195
git bisect good a5354ccaaf54ac61c6d1b350e8d3e4234dd28849
# good: [84ce1ddfefc3d5a8af5ede6fe16546c143117616] 6lowpan: init ipv6hdr buffer to zero
git bisect good 84ce1ddfefc3d5a8af5ede6fe16546c143117616
# bad: [a0e186003be7892fd75613a23aaafaf09f3611e6] net: fsl_pq_mdio: use platform_{get,set}_drvdata()
git bisect bad a0e186003be7892fd75613a23aaafaf09f3611e6
# good: [89d5e23210f53ab53b7ff64843bce62a106d454f] Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next
git bisect good 89d5e23210f53ab53b7ff64843bce62a106d454f
# good: [0aa857f83fe2674f973ad89ec7c0202f5c5d9554] moxa: fix missing unlock on error in moxart_mac_start_xmit()
git bisect good 0aa857f83fe2674f973ad89ec7c0202f5c5d9554
# bad: [0dde80268ee0a5a1511935bdb9c547191d616aa9] myri10ge: Add support for ndo_busy_poll
git bisect bad 0dde80268ee0a5a1511935bdb9c547191d616aa9
# good: [397b41746333ad386d91d23ea0f79481320dcdcc] tcp: trivial: Remove nocache argument from tcp_v4_send_synack
git bisect good 397b41746333ad386d91d23ea0f79481320dcdcc
# bad: [734d2725db879f3f6fcdc2b1d2a5deae105f5e95] ipv4: raise IP_MAX_MTU to theoretical limit
git bisect bad 734d2725db879f3f6fcdc2b1d2a5deae105f5e95
# good: [35596b2796713c6a9dc05759837fa9f0e156a200] vhost: Include linux/uio.h instead of linux/socket.h
git bisect good 35596b2796713c6a9dc05759837fa9f0e156a200
# first bad commit: [734d2725db879f3f6fcdc2b1d2a5deae105f5e95] ipv4: raise IP_MAX_MTU to theoretical limit


Compare of all good/bad commits during the bisect.

                                  iostat.cpu.user

   2.2 ++-------------------------------------------------------------------+
     2 ++               O   O              O                                |
       |                  O  O O O OO O O O  O OO O O OO   OO O O O         |
   1.8 ++                                                O                  |
   1.6 ++                                                                   |
       |                                                                    |
   1.4 O+OO O O OO O O O                                                    |
   1.2 ++                                                                   |
     1 ++                                                                   |
       |                                                                    |
   0.8 ++                                                                   |
   0.6 ++                                                                   |
       |                                                                    |
   0.4 ++               *.*.           .*.**.    .*.                       .*
   0.2 *+**-*-*-**-*-*-*----**-*-*-**-*------*-**---*-**-*-**-*-*-**-*-*-**-+


                               netperf.Throughput_Mbps

   2000 ++------------------------------------------------------------------+
   1800 ++               O OO O O OO O OO O OO O O OO O OO O OO O O         |
        |                                                                   |
   1600 ++                                                                  |
   1400 ++                                                                  |
        O OO O O OO O OO                                                    |
   1200 ++                                                                  |
   1000 ++                                                                  |
    800 ++                                                                  |
        |                                                                   |
    600 ++                                                                  |
    400 ++                                                                  |
        |                                                                   |
    200 *+**.*.*.**.*.**.*.**.*.*.**.*.**.*.**.*.*.**.*.**.*.**.*.*.**.*.**.*
      0 ++------------------------------------------------------------------+


                                  vmstat.system.in

   34000 ++---------------------O-----------O-------------------------------+
         |                     O  O OO O O O  O    O  O O OO O OO O         |
   32000 ++                                     OO   O                      |
   30000 ++                                                                 |
         |                                                                  |
   28000 ++                                                                 |
   26000 O+   O OO O O  O                                                   |
         | OO         O                                                     |
   24000 ++                                                                 |
   22000 ++                                                                 |
         |                                                                  |
   20000 ++                O                                                |
   18000 ++                                    .*                           |
         *.**.*.**.*.**.*.  .*.**.*.**.*.*.**.*  *.*.**.*.**.*.**.*.**.*.**.*
   16000 ++---------------**------------------------------------------------+


                                   vmstat.system.cs

   900000 ++---------------O------------------------------------------------+
          |                   O                                             |
   800000 ++                O  O O O    OO O OO O OO O OO   OO OO O         |
   700000 ++                        O O                   O                 |
          |                                                                 |
   600000 ++                                                                |
   500000 O+OO O OO O OO O                                                  |
          |                                                                 |
   400000 ++                                                                |
   300000 ++                                                                |
          |                                                                 |
   200000 ++                                                                |
   100000 ++                                                                |
          *.**.*.**.*.**.*.**.**.*.**.*.**.*.**.*.**.*.**.*.**.**.*.**.*.**.*
        0 ++----------------------------------------------------------------+


                     lock_stat.&(&zone->lock)->rlock.contentions

   7e+07 ++---------------O-------------------------------------------------+
         |                 O O                                              |
   6e+07 ++                    OO O      O O  O OO O OO O OO O OO O         |
         |                          OO O    O                               |
   5e+07 O+OO O OO O OO O                                                   |
         |                                                                  |
   4e+07 ++                                                                 |
         |                                                                  |
   3e+07 ++                                                                 |
         |                                                                  |
   2e+07 ++                                                                 |
         |                                                                  |
   1e+07 ++                                                                 |
         |               .**.*.                                             |
       0 *+**-*-**-*-**-*------**-*-**-*-*-**-*-**-*-**-*-**-*-**-*-**-*-**-*


             lock_stat.&(&zone->lock)->rlock.contentions.__free_pages_ok

   7e+07 ++-----------------------------------------------------------------+
         |                O  O                                              |
   6e+07 ++                O   OO O           O OO O O  O  O O  O O         |
         |                          OO O O OO         O   O                 |
   5e+07 O+OO O OO O OO O                                                   |
         |                                                                  |
   4e+07 ++                                                                 |
         |                                                                  |
   3e+07 ++                                                    O            |
         |                                                                  |
   2e+07 ++                                                                 |
         |                                                                  |
   1e+07 ++                                                                 |
         |                                                                  |
       0 *+**-*-**-*-**-*-**-*-**-*-**-*-*-**-*-**-*-**-*-**-*-**-*-**-*-**-*


         lock_stat.&(&zone->lock)->rlock.contentions.get_page_from_freelist

   7e+07 ++---------------O-------------------------------------------------+
         |                 O O                                              |
   6e+07 ++                    OO O OO O O OO O OO O OO O OO O OO O         |
         |                                                                  |
   5e+07 O+OO O OO O OO O                                                   |
         |                                                                  |
   4e+07 ++                                                                 |
         |                                                                  |
   3e+07 ++                                                                 |
         |                                                                  |
   2e+07 ++                                                                 |
         |                                                                  |
   1e+07 ++                                                                 |
         |               .**.*.                                             |
       0 *+**-*-**-*-**-*------**-*-**-*-*-**-*-**-*-**-*-**-*-**-*-**-*-**-*


                            lock_stat.&rq->lock.contentions

   300000 ++---------------------O------OO-O-O---------------O--------------+
          |                    O   OO O       O O OO O OO O O  OO O         |
   250000 ++                                                                |
          |                                                                 |
          |            O                                                    |
   200000 O+OO O OO O O  O                                                  |
          |                                                                 |
   150000 ++                                                                |
          |                                                                 |
   100000 ++                                                                |
          *. *.                      .*.* .*.* .*.*   .* .*.    *. .**.    .*
          | *  *.**.*.**.*     *.*.**    *    *    *.*  *   **.*  *    *.** |
    50000 ++              :    :                                            |
          |               : O O                                             |
        0 ++---------------**-*---------------------------------------------+


               lock_stat.clockevents_lock.contentions.clockevents_notify

   120000 ++----------------------------------------------------------------+
          |                                     *                           |
   100000 ++                                    :                           |
          |                                     :                           |
          |                                    : :                          |
    80000 ++                                   : :                          |
          |           *                        : :                          |
    60000 ++         ::                        : :                          |
          |       *. : :                    .* : :                          |
    40000 ++      : *  *.       .*         * ::   :                .*       *
          *. *.  :       *.**.**  + *.*.  +   :   :*.   *. .**.* .*  *. .* +|
          | *  *.*                 *    **    *   *  *.*  *     *      *  * |
    20000 ++          O    OO OO   O  O OO O    O    O OO O  O O            |
          O OO O OO O  O O       O  O        OO   OO        O   O O         |
        0 ++----------------------------------------------------------------+


             lock_stat.&(&base->lock)->rlock.contentions.lock_timer_base

   12000 ++-----------------------------------------------------------------+
         |              *                                                   |
   10000 *+* .*.**.    + :     * .*.          *.  .*.            .*. *.     |
         |  *      *.**  :    : *   *        +  **   **.*.**.*. *   *  *.**.*
         |                :   :      *.*.*.**                  *            |
    8000 ++               **.*                                              |
         |                                                                  |
    6000 ++                                                                 |
         |                                                                  |
    4000 ++                                                                 |
         |                                                                  |
         |                                                                  |
    2000 ++                                                                 |
         |                                                                  |
       0 O+OO-O-OO-O-OO-O-OO-O-OO-O-OO-O-O-OO-O-OO-O-OO-O-OO-O-OO-O---------+


            lock_stat.&(&base->lock)->rlock.contentions.run_timer_softirq

   7000 ++------------------------------------------------------------------+
        |                        .*                                         |
   6000 ++*            *      *.* :          *.   .*             .*. *.     |
        *  :.*.*.* .*. :      :    :         : *.*  *.*.**.    .*   *  *.**.*
   5000 ++ *      *   * :    :     :         :             *.**             |
        |               :    :     *.*.*    :                               |
   4000 ++               :  :           *.*.*                               |
        |                *.**                                               |
   3000 ++                                                                  |
        |                                                                   |
   2000 ++                                                                  |
        |                                                                   |
   1000 ++                                                                  |
        |                                                                   |
      0 O+OO-O-O-OO-O-OO-O-OO-O-O-OO-O-OO-O-OO-O-O-OO-O-OO-O-OO-O-O---------+


                           lock_stat.rcu_node_1.contentions

   120000 ++----------------------------------------------------------------+
          |                                                                 |
   100000 ++                O OO O      OO                     OO O         |
          |                O       OO      O O  O O  O OO O O               |
          | OO O O       O            O       O    O         O              |
    80000 O+      O O OO                                                    |
          |                                                                 |
    60000 ++                                                                |
          |                                                                 |
    40000 ++                                                                |
          |                                                                 |
          |                                                                 |
    20000 ++                                                                |
          |                                                                 |
        0 *+**-*-**-*-**-*-**-**-*-**-*-**-*-**-*-**-*-**-*-**-**-*-**-*-**-*


                lock_stat.rcu_node_1.contentions.rcu_process_callbacks

   200000 ++------------------O---------------------------------------------+
   180000 ++                O  O O      OO O O       O O  O    OO O         |
          |                O       OO           O O     O   OO              |
   160000 ++OO O O       O            O       O    O                        |
   140000 O+      O O OO                                                    |
          |                                                                 |
   120000 ++                                                                |
   100000 ++                                                                |
    80000 ++                                                                |
          |                                                                 |
    60000 ++                                                                |
    40000 ++                                                                |
          |                                                                 |
    20000 ++                                                                |
        0 *+**-*-**-*-**-*-**-**-*-**-*-**-*-**-*-**-*-**-*-**-**-*-**-*-**-*


                    lock_stat.rcu_node_1.contentions.force_qs_rnp

   20000 ++-----------------------------------------------------------------+
   18000 ++               O  O                                              |
         |                 O                                                |
   16000 ++                                                                 |
   14000 ++                                                                 |
         |                               O                                  |
   12000 ++                    OO O O  O   OO   OO   OO O OO O OO O         |
   10000 O+OO O OO O    O            O        O    O                        |
    8000 ++          OO                                                     |
         |                                                                  |
    6000 ++                                                                 |
    4000 ++                                                                 |
         |                                                                  |
    2000 ++                                                                 |
       0 *+**-*-**-*-**-*-**-*-**-*-**-*-*-**-*-**-*-**-*-**-*-**-*-**-*-**-*


                          lock_stat.slock-AF_INET.contentions

   600000 ++----------------------------------------------------------------+
          |                    O O  O   O          O   OO O  O              |
   500000 ++                       O  O  O O OO   O         O  OO O         |
          |                                     O    O                      |
          |                                                                 |
   400000 ++                O                                               |
          |                                                                 |
   300000 O+OO O OO O OO O                                                  |
          |                                                                 |
   200000 ++                                                                |
          |                                                                 |
          |                                                                 |
   100000 ++                                                                |
          |                   O                                             |
        0 *+**-*-**-*-**-*-**-**-*-**-*-**-*-**-*-**-*-**-*-**-**-*-**-*-**-*


                  lock_stat.slock-AF_INET.contentions.lock_sock_fast

   600000 ++----------------------------------------------------------------+
          |                    O O                        O                 |
   500000 ++                       OO O OO O OO   OO   OO   OO OO O         |
          |                                     O    O                      |
          |                                                                 |
   400000 ++                                                                |
          |                                                                 |
   300000 O+OO O OO O OO O  O                                               |
          |                                                                 |
   200000 ++                                                                |
          |                                                                 |
          |                                                                 |
   100000 ++                                                                |
          |                   O                                             |
        0 *+**-*-**-*-**-*-**-**-*-**-*-**-*-**-*-**-*-**-*-**-**-*-**-*-**-*


                 lock_stat.slock-AF_INET.contentions.udp_queue_rcv_skb

   600000 ++----------------------------------------------O-----------------+
          |                    O O  O   O    O     O   OO    O              |
   500000 ++                       O  O  O O  O   O         O  OO O         |
          |                 O                   O    O                      |
          |                                                                 |
   400000 ++                                                                |
          |                                                                 |
   300000 O+OO O OO O OO O                                                  |
          |                                                                 |
   200000 ++                                                                |
          |                                                                 |
          |                                                                 |
   100000 ++                                                                |
          |                   O                                             |
        0 *+**-*-**-*-**-*-**-**-*-**-*-**-*-**-*-**-*-**-*-**-**-*-**-*-**-*


                     lock_stat.&(&list->lock)->rlock#2.contentions

   300000 ++----------------------------------------------------------------+
          |                           O O                                   |
   250000 ++                        O    O O OO   O    OO                   |
          |                    O O O            O  O      O OO OO O         |
          |                                          O                      |
   200000 ++                                                                |
          |                                                                 |
   150000 ++                                                                |
          O OO O OO O OO O                                                  |
   100000 ++                                                                |
          |                                                                 |
          |                 O                                               |
    50000 ++                                                                |
          |                   O                                             |
        0 *+**-*-**-*-**-*-**-**-*-**-*-**-*-**-*-**-*-**-*-**-**-*-**-*-**-*


           lock_stat.&(&list->lock)->rlock#2.contentions.__skb_recv_datagram

   300000 ++----------------------------------------------------------------+
          |                           O O                                   |
   250000 ++                        O    O O OO   O    OO                   |
          |                    O O O            O  O      O OO OO O         |
          |                                          O                      |
   200000 ++                                                                |
          |                                                                 |
   150000 ++                                                                |
          O OO O OO O OO O                                                  |
   100000 ++                                                                |
          |                                                                 |
          |                 O                                               |
    50000 ++                                                                |
          |                   O                                             |
        0 *+**-*-**-*-**-*-**-**-*-**-*-**-*-**-*-**-*-**-*-**-**-*-**-*-**-*


           lock_stat.&(&list->lock)->rlock#2.contentions.sock_queue_rcv_skb

   300000 ++----------------------------------------------------------------+
          |                           O O                                   |
   250000 ++                        O    O O OO   O    OO                   |
          |                    O O O            O  O      O OO OO O         |
          |                                          O                      |
   200000 ++                                                                |
          |                                                                 |
   150000 ++                                                                |
          O OO O OO O OO O                                                  |
   100000 ++                                                                |
          |                                                                 |
          |                 O                                               |
    50000 ++                                                                |
          |                   O                                             |
        0 *+**-*-**-*-**-*-**-**-*-**-*-**-*-**-*-**-*-**-*-**-**-*-**-*-**-*


                            lock_stat.&wq->wait.contentions

   100000 ++-------------------O--------------------------------------------+
    90000 ++                     O  O    O O  O O OO O OO O    O            |
          |                        O  O O    O              OO  O O         |
    80000 ++                                                                |
    70000 ++                                                                |
          |                                                                 |
    60000 ++     O                                                          |
    50000 O+OO O  O O OO O                                                  |
    40000 ++                                                                |
          |                                                                 |
    30000 ++                                                                |
    20000 ++                                                                |
          |                 O                                               |
    10000 ++                  O                                             |
        0 *+**-*-**-*-**-*-**-**-*-**-*-**-*-**-*-**-*-**-*-**-**-*-**-*-**-*


                      lock_stat.&wq->wait.contentions.finish_wait

   100000 ++----------------------------------------------------------------+
    90000 ++                   O         O O  O O O    OO O    O            |
          |                      O OO O O    O     O O       O  O O         |
    80000 ++                                                O               |
    70000 ++                                                                |
          |                                                                 |
    60000 ++                                                                |
    50000 O+OO O OO O OO O                                                  |
    40000 ++                                                                |
          |                                                                 |
    30000 ++                                                                |
    20000 ++                                                                |
          |                                                                 |
    10000 ++                O                                               |
        0 *+**-*-**-*-**-*-**-**-*-**-*-**-*-**-*-**-*-**-*-**-**-*-**-*-**-*


                  lock_stat.&wq->wait.contentions.__wake_up_sync_key

   100000 ++----------------------------------------------------------------+
    90000 ++                   O         O O  O O OO   OO O    O            |
          |                      O OO O O    O       O      OO  O O         |
    80000 ++                                                                |
    70000 ++                                                                |
          |                                                                 |
    60000 ++     O                                                          |
    50000 O+OO O  O O OO O                                                  |
    40000 ++                                                                |
          |                                                                 |
    30000 ++                                                                |
    20000 ++                                                                |
          |                 O                                               |
    10000 ++                  O                                             |
        0 *+**-*-**-*-**-*-**-**-*-**-*-**-*-**-*-**-*-**-*-**-**-*-**-*-**-*
