From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 0/3] [RFC] Implement multiqueue (RX & TX) virtio-net
Date: Mon, 28 Feb 2011 12:04:27 +0530
Message-ID: <20110228063427.24908.63561.sendpatchset@krkumar2.in.ibm.com>
Cc: eric.dumazet@gmail.com, arnd@arndb.de, netdev@vger.kernel.org,
	horms@verge.net.au, avi@redhat.com, anthony@codemonkey.ws,
	kvm@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: rusty@rustcorp.com.au, davem@davemloft.net, mst@redhat.com
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series is a continuation of an earlier one that
implemented guest MQ TX functionality.  This new patchset
implements both RX and TX MQ.  Qemu changes are not being
included at this time solely to aid in easier review.
Compatibility testing with old/new combinations of qemu/guest
and vhost was done without any issues.

Some early TCP/UDP test results are at the bottom of this
post, I plan to submit more test results in the coming days.

Please review and provide feedback on what can improve.

Thanks!

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---


Test configuration:
          Host:  8 Intel Xeon, 8 GB memory
          Guest: 4 cpus, 2 GB memory

Each test case runs for 60 secs, results below are average over
two runs.  Bandwidth numbers are in gbps.  I have used default
netperf, and no testing/system tuning other than taskset each
vhost to 0xf (cpus 0-3).  Comparison is testing original kernel
vs new kernel with #txqs=8 ("#" refers to number of netperf
sessions).

_______________________________________________________________________
                TCP: Guest -> Local Host (TCP_STREAM)
#    BW1    BW2 (%)         SD1    SD2 (%)       RSD1    RSD2 (%)
_______________________________________________________________________
1    7190   7170 (-.2)      0      0 (0)          3       4 (33.3)
2    8774   11235 (28.0)    3      3 (0)          16      14 (-12.5)
4    9753   15195 (55.7)    17     21 (23.5)      65      59 (-9.2)
8    10224  18265 (78.6)    71     115 (61.9)     251     240 (-4.3)
16   10749  18123 (68.6)    277    456 (64.6)     985     925 (-6.0)
32   11133  17351 (55.8)    1132   1947 (71.9)    3935    3831 (-2.6)
64   11223  17115 (52.4)    4682   7836 (67.3)    15949   15373 (-3.6)
128  11269  16986 (50.7)    19783  31505 (59.2)   66799   61759 (-7.5)
_______________________________________________________________________
Summary:      BW: 37.6      SD: 61.2      RSD: -6.5


_______________________________________________________________________
                 TCP: Local Host -> Guest (TCP_MAERTS)
#    BW1    BW2 (%)        SD1    SD2 (%)        RSD1    RSD2 (%)
_______________________________________________________________________
1    11490  10870 (-5.3)   0      0 (0)          2       2 (0)
2    10612  10554 (-.5)    2      3 (50.0)       12      12 (0)
4    10047  14320 (42.5)   13     16 (23.0)      53      53 (0)
8    9273   15182 (63.7)   56     84 (50.0)      228     233 (2.1)
16   9291   15853 (70.6)   235    390 (65.9)     934     965 (3.3)
32   9382   15741 (67.7)   969    1823 (88.1)    3868    4037 (4.3)
64   9270   14585 (57.3)   3966   8836 (122.7)   15415   17818 (15.5)
128  8997   14678 (63.1)   17024  36649 (115.2)  64933   72677 (11.9)
_______________________________________________________________________
SUM:      BW: 24.8      SD: 114.6      RSD: 12.1

______________________________________________________
            UDP: Local Host -> Guest (UDP_STREAM)
#      BW1      BW2 (%)        SD1    SD2 (%)
______________________________________________________
1      17236    16585 (-3.7)    1      1 (0)
2      16795    22693 (35.1)    5      6 (20.0)
4      13390    21502 (60.5)    37     36 (-2.7)
8      13261    24361 (83.7)    163    175 (7.3)
16     12772    23796 (86.3)    692    826 (19.3)
32     12832    23880 (86.0)    2812   2871 (2.0)
64     12779    24293 (90.1)    11299  11237 (-.5)
128    13006    24857 (91.1)    44778  43884 (-1.9)
______________________________________________________
Summary:      BW: 37.1      SD: -1.2
