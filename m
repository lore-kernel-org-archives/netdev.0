From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 0/6] debugfs for mv88e6xxx
Date: Sat, 20 Jun 2015 18:42:27 +0200
Message-ID: <1434818553-10239-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59951 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932459AbbFTQst (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Jun 2015 12:48:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds some debugfs files for seeing into a mv88e6xxx
family of switch chips.

# cat atu
DB   T/P  Vec State Addr
003  Port 008   7   00:22:02:00:18:44
003  Port 008   6   80:ee:73:83:60:27
005  Port 020   7   94:10:3e:80:bc:f3
0f8  Port 001   6   8e:25:13:53:44:de

This walks all possible entries, so is a bit slow, but is always
correct.

# cat device_map
Target Port
   0   15
   1   15
   2   15
   3   15
   4   15
   5   15
   6   15
   7   15
   8   15
   9   15
-->snip<--
  31   15

A rather boring example, since i only have one switch here. But this shows
the routing between multiple switches.

# cat regs
    GLOBAL GLOBAL2   0    1    2    3    4    5    6
 0:  c804       0  1e4f 100f 100f 1e4f 1e0f  e07  e07
 1:    fe       0     3    3    3    3    3 c03e c03f
 2:     0    ffff     0    0    0    0    0    0    0
 3:     0    ffff  1721 1721 1721 1721 1721 1721 1721
 4:  6000     258   433  431  431  433  433 373f  433
 5:     0      ff     0    0    0    0    0    0    0
 6:  c000    1f0f  2026 2025 2023 3020 4020 501f 6020
 7:     0    707f     0    0    0    0    0    0    0
 8:     0    7800  2080 2080 2080 2080 2080 2080 2080
 9:     0    1600     1    1    1    1    1    1    1
 a:   148       0     0    0    0    0    0    0    0
 b:  4000    1000     1    2    4    8   10   20   40
 c:     0      7f     0    0    0    0    0    0    0
 d:  ffff     5f3     0    0    0    0    0    0    0
 e:  ffff       6     0    0    0    0    0    0    0
 f:  ffff     f00  dada dada dada dada dada dada dada
10:     0       0     0    0    0    0    0    0    0
11:     0       0     0    0    0    0    0    0    0
12:  5555       0     0    0    0    0    0    0    0
13:  5555       0    1a    0    0 1df0    0 1e07    0
14:  aaaa     400     0    0    0    0    0    0    0
15:  aaaa       0     0    0    0    0    0    0    0
16:  ffff       0  6011 6011 6011 6011   33   33    0
17:  ffff       0     0    0    0    0    0    0    0
18:  fa41    1844  3210 3210 3210 3210 3210 3210 3210
19:     0     1e1  7654 7654 7654 7654 7654 7654 7654
1a:  5550       0     0    0    0    0    0    0    0
1b:   1fb    f869  8000 8000 8000 8000 8000 8000 8000
1c:     0       0     0    0    0    0    0    0    0
1d:   c00       0     0    0    0    0    0    0    0
1e:     0       0     0    0    0    0    0    0    0
1f:     0       0     0    0    0    0    0    0    0

All the switch registers which are directly accessible.

# cat stats
      Statistic       Port  0  Port  1  Port  2  Port  3  Port  4  Port  5  Port 6
     in_good_octets:     2176        0        0  4263711        0   499540       0
      in_bad_octets:    46050        0        0    50196        0        0       0
         in_unicast:        0        0        0     7693        0     7691       0
      in_broadcasts:        0        0        0        0        0        3       0
      in_multicasts:       34        0        0        0        0       27       0
           in_pause:        0        0        0        0        0        0       0
       in_undersize:        0        0        0        0        0        0       0
       in_fragments:       45        0        0        2        0        0       0
        in_oversize:        0        0        0        0        0        0       0
          in_jabber:        0        0        0        0        0        0       0
        in_rx_error:        0        0        0        0        0        0       0
       in_fcs_error:      159        0        0       37        0        0       0
         out_octets:      808        0        0   496608      336  4267159       0
        out_unicast:        0        0        0     7691        0     7693       0
     out_broadcasts:        1        0        0        3        0        0       0
     out_multicasts:        9        0        0        6        4       34       0
          out_pause:        0        0        0        0        0        0       0
          excessive:        0        0        0        0        0        0       0
         collisions:        0        0        0        0        0        0       0
           deferred:        0        0        0        0        0        0       0
             single:        0        0        0        0        0        0       0
           multiple:        0        0        0        0        0        0       0
      out_fcs_error:        0        0        0        0        0        0       0
               late:        0        0        0        0        0        0       0
       hist_64bytes:       36        0        0     7577        0     7574       0
   hist_65_127bytes:       53        0        0      241        4      298       0
  hist_128_255bytes:       50        0        0       12        0       10       0
  hist_256_511bytes:       43        0        0        8        0        2       0
 hist_512_1023bytes:       18        0        0     7573        0     7564       0
hist_1024_max_bytes:        3        0        0       19        0        0       0
     sw_in_discards:        0        0        0        0        0        0       0
     sw_in_filtered:        0        0        0        0        0        0       0
    sw_out_filtered:       34        0        0     7693        0     7721       0

Of particular interest here is that you get to see all ports,
including the CPU port and any DSA ports. You cannot get statistics
for these ports via ethtool.

Andrew Lunn (6):
  dsa: mv88e6xxx: Add debugfs interface for registers
  dsa: mv88e6xxx: Add debugfs interface for ATU
  dsa: mv88x6xxx: Refactor getting a single statistic
  dsa: mv88x6xxx: Add debugfs interface for statistics
  dsa: mv88x6xxx: Add debugfs interface for device map
  dsa: mv88x6xxx: Add debugfs interface for scratch registers

 drivers/net/dsa/mv88e6xxx.c | 348 ++++++++++++++++++++++++++++++++++++++++----
 drivers/net/dsa/mv88e6xxx.h |  13 ++
 2 files changed, 334 insertions(+), 27 deletions(-)

-- 
2.1.4
