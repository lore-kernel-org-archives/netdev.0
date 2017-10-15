From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: Linux 4.12+ memory leak on router with i40e NICs
Date: Sun, 15 Oct 2017 17:03:30 +0200
Message-ID: <8739349e-d61c-9127-b9ff-530382036e4a@itcare.pl>
References: <1507121766.30720.4.camel@cohaesio.com>
 <CAKgT0UfAqzuEbFA_hs8f4goL2hTMqeJ5no2sAc8NO_KJO120tA@mail.gmail.com>
 <1507180753.20182.8.camel@cohaesio.com>
 <227d17ae-b040-07d0-3c57-e9acd1a3b5b4@itcare.pl>
 <c49a750f-c47c-9de0-ebf0-148db5e3d3c5@itcare.pl>
 <CAKgT0UcOWxnrsGEjTopPP-JKyKGTG3j6KNKUbhQRgaCStyzr_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "Anders K. Pedersen | Cohaesio" <akp@cohaesio.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp16.iq.pl ([86.111.242.222]:56889 "EHLO smtp16.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750854AbdJOPDd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 15 Oct 2017 11:03:33 -0400
In-Reply-To: <CAKgT0UcOWxnrsGEjTopPP-JKyKGTG3j6KNKUbhQRgaCStyzr_A@mail.gmail.com>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously attached graphs was for:

4.14.0-rc4-next-20171012

from git:

git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git


In kernel drivers.
Just tested by replacing cards in server from 8x10G based on 82599 to
02:00.0 Ethernet controller: Intel Corporation Ethernet Controller X710 
for 10GbE SFP+ (rev 01)
02:00.1 Ethernet controller: Intel Corporation Ethernet Controller X710 
for 10GbE SFP+ (rev 01)
02:00.2 Ethernet controller: Intel Corporation Ethernet Controller X710 
for 10GbE SFP+ (rev 01)
02:00.3 Ethernet controller: Intel Corporation Ethernet Controller X710 
for 10GbE SFP+ (rev 01)
03:00.0 Ethernet controller: Intel Corporation Ethernet Controller X710 
for 10GbE SFP+ (rev 02)
03:00.1 Ethernet controller: Intel Corporation Ethernet Controller X710 
for 10GbE SFP+ (rev 02)
03:00.2 Ethernet controller: Intel Corporation Ethernet Controller X710 
for 10GbE SFP+ (rev 02)
03:00.3 Ethernet controller: Intel Corporation Ethernet Controller X710 
for 10GbE SFP+ (rev 02)

And with same configuration - have leaking memory somewhere - there is 
no process that can
  ps aux --sort -rss
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root      5103 41.2 31.1 10357508 10242860 ?   Sl   Oct14 1010:33 
/usr/local/sbin/bgpd -d -A 127.0.0.1 -u root -g root -I 
--ignore_warnings -F /usr/local/etc/Quagga.conf -t
root      5094  0.0  0.8 295372 270868 ?       Ss   Oct14   1:26 
/usr/local/sbin/zebra -d -A 127.0.0.1 -u root -g root -I 
--ignore_warnings -F /usr/local/etc/Quagga.conf
root      4356  3.4  0.2  98780 75852 ?        S    Oct14  84:21 
/usr/sbin/snmpd -p /var/run/snmpd.pid -Ln -I -smux
root      3448  0.0  0.0  32172  6204 ?        Ss   Oct14   0:00 
/sbin/udevd --daemon
root      5385  0.0  0.0  61636  5044 ?        Ss   Oct14   0:00 sshd: 
paol [priv]
root      4116  0.0  0.0 346312  4804 ?        Ss   Oct14   0:33 
/usr/sbin/syslog-ng --persist-file /var/lib/syslog-ng/syslog-ng.persist 
--cfgfile /etc/syslog-ng/syslog-ng.conf --pidfile /run/syslog-ng.pid
paol      5390  0.0  0.0  61636  3564 ?        S    Oct14   0:06 sshd: 
paol@pts/1
root      5403  0.0  0.0 709344  3520 ?        Ssl  Oct14   0:26 
/opt/collectd/sbin/collectd
root      5397  0.0  0.0  18280  3288 pts/1    S    Oct14   0:00 -su
root      4384  0.0  0.0  30472  3016 ?        Ss   Oct14   0:00 
/usr/sbin/sshd
paol      5391  0.0  0.0  18180  2884 pts/1    Ss   Oct14   0:00 -bash
root      5394  0.0  0.0  43988  2376 pts/1    S    Oct14   0:00 su -
root     20815  0.0  0.0  17744  2312 pts/1    R+   16:58   0:00 ps aux 
--sort -rss
root      4438  0.0  0.0  28820  2256 ?        S    Oct14   0:00 teamd 
-d -f /etc/teamd.conf
root      4030  0.0  0.0   6976  2024 ?        Ss   Oct14   0:00 mdadm 
--monitor --scan --daemonise --pid-file /var/run/mdadm.pid --syslog
root      4408  0.0  0.0  16768  1884 ?        Ss   Oct14   0:00 
/usr/sbin/cron
root      5357  0.0  0.0 120532  1724 tty6     Ss+  Oct14   0:00 
/sbin/agetty 38400 tty6 linux
root      5352  0.0  0.0 120532  1712 tty1     Ss+  Oct14   0:00 
/sbin/agetty 38400 tty1 linux
root      5356  0.0  0.0 120532  1692 tty5     Ss+  Oct14   0:00 
/sbin/agetty 38400 tty5 linux
root      5353  0.0  0.0 120532  1648 tty2     Ss+  Oct14   0:00 
/sbin/agetty 38400 tty2 linux
root      5355  0.0  0.0 120532  1628 tty4     Ss+  Oct14   0:00 
/sbin/agetty 38400 tty4 linux
root      5354  0.0  0.0 120532  1620 tty3     Ss+  Oct14   0:00 
/sbin/agetty 38400 tty3 linux
root         1  0.0  0.0   4184  1420 ?        Ss   Oct14   0:02 init [3]
root      4115  0.0  0.0  34336   608 ?        S    Oct14   0:00 
supervising syslog-ng
root         2  0.0  0.0      0     0 ?        S    Oct14   0:00 [kthreadd]
root         4  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[kworker/0:0H]
root         6  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[mm_percpu_wq]
root         7  0.8  0.0      0     0 ?        S    Oct14  22:01 
[ksoftirqd/0]
root         8  0.0  0.0      0     0 ?        I    Oct14   1:36 [rcu_sched]
root         9  0.0  0.0      0     0 ?        I    Oct14   0:00 [rcu_bh]
root        10  0.0  0.0      0     0 ?        S    Oct14   0:00 
[migration/0]
root        11  0.0  0.0      0     0 ?        S    Oct14   0:00 [cpuhp/0]
root        12  0.0  0.0      0     0 ?        S    Oct14   0:00 [cpuhp/1]
root        13  0.0  0.0      0     0 ?        S    Oct14   0:00 
[migration/1]
root        14  0.8  0.0      0     0 ?        S    Oct14  21:39 
[ksoftirqd/1]
root        16  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[kworker/1:0H]
root        17  0.0  0.0      0     0 ?        S    Oct14   0:00 [cpuhp/2]
root        18  0.0  0.0      0     0 ?        S    Oct14   0:00 
[migration/2]
root        19  0.8  0.0      0     0 ?        S    Oct14  20:48 
[ksoftirqd/2]
root        21  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[kworker/2:0H]
root        22  0.0  0.0      0     0 ?        S    Oct14   0:00 [cpuhp/3]
root        23  0.0  0.0      0     0 ?        S    Oct14   0:00 
[migration/3]
root        24  1.0  0.0      0     0 ?        S    Oct14  24:36 
[ksoftirqd/3]
root        26  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[kworker/3:0H]
root        27  0.0  0.0      0     0 ?        S    Oct14   0:00 [cpuhp/4]
root        28  0.0  0.0      0     0 ?        S    Oct14   0:00 
[migration/4]
root        29  0.8  0.0      0     0 ?        S    Oct14  20:14 
[ksoftirqd/4]
root        31  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[kworker/4:0H]
root        32  0.0  0.0      0     0 ?        S    Oct14   0:00 [cpuhp/5]
root        33  0.0  0.0      0     0 ?        S    Oct14   0:00 
[migration/5]
root        34  0.8  0.0      0     0 ?        S    Oct14  20:22 
[ksoftirqd/5]
root        36  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[kworker/5:0H]
root        37  0.0  0.0      0     0 ?        S    Oct14   0:00 [cpuhp/6]
root        38  0.0  0.0      0     0 ?        S    Oct14   0:00 
[migration/6]
root        39  0.8  0.0      0     0 ?        S    Oct14  20:43 
[ksoftirqd/6]
root        41  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[kworker/6:0H]
root        42  0.0  0.0      0     0 ?        S    Oct14   0:00 [cpuhp/7]
root        43  0.0  0.0      0     0 ?        S    Oct14   0:00 
[migration/7]
root        44  0.8  0.0      0     0 ?        S    Oct14  21:51 
[ksoftirqd/7]
root        46  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[kworker/7:0H]
root        47  0.0  0.0      0     0 ?        S    Oct14   0:00 [cpuhp/8]
root        48  0.0  0.0      0     0 ?        S    Oct14   0:00 
[migration/8]
root        49  0.7  0.0      0     0 ?        S    Oct14  18:49 
[ksoftirqd/8]
root        51  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[kworker/8:0H]
root        52  0.0  0.0      0     0 ?        S    Oct14   0:00 [cpuhp/9]
root        53  0.0  0.0      0     0 ?        S    Oct14   0:00 
[migration/9]
root        54  0.8  0.0      0     0 ?        S    Oct14  20:48 
[ksoftirqd/9]
root        56  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[kworker/9:0H]
root        57  0.0  0.0      0     0 ?        S    Oct14   0:00 [cpuhp/10]
root        58  0.0  0.0      0     0 ?        S    Oct14   0:00 
[migration/10]
root        59  0.7  0.0      0     0 ?        S    Oct14  19:07 
[ksoftirqd/10]
root        61  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[kworker/10:0H]
root        62  0.0  0.0      0     0 ?        S    Oct14   0:00 [cpuhp/11]
root        63  0.0  0.0      0     0 ?        S    Oct14   0:00 
[migration/11]
root        64  0.8  0.0      0     0 ?        S    Oct14  19:54 
[ksoftirqd/11]
root        66  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[kworker/11:0H]
root        67  0.0  0.0      0     0 ?        S    Oct14   0:00 [kdevtmpfs]
root        70  0.0  0.0      0     0 ?        S    Oct14   0:00 [kauditd]
root       410  0.0  0.0      0     0 ?        S    Oct14   0:00 
[khungtaskd]
root       411  0.0  0.0      0     0 ?        S    Oct14   0:00 
[oom_reaper]
root       412  0.0  0.0      0     0 ?        I<   Oct14   0:00 [writeback]
root       414  0.0  0.0      0     0 ?        S    Oct14   0:00 
[kcompactd0]
root       415  0.0  0.0      0     0 ?        SN   Oct14   0:00 [ksmd]
root       416  0.0  0.0      0     0 ?        SN   Oct14   0:00 
[khugepaged]
root       417  0.0  0.0      0     0 ?        I<   Oct14   0:00 [crypto]
root       419  0.0  0.0      0     0 ?        I<   Oct14   0:00 [kblockd]
root      1314  0.0  0.0      0     0 ?        I<   Oct14   0:00 [ata_sff]
root      1329  0.0  0.0      0     0 ?        I<   Oct14   0:00 [md]
root      1425  0.0  0.0      0     0 ?        I<   Oct14   0:00 [rpciod]
root      1426  0.0  0.0      0     0 ?        I<   Oct14   0:00 [xprtiod]
root      1515  0.0  0.0      0     0 ?        S    Oct14   0:00 [kswapd0]
root      1614  0.0  0.0      0     0 ?        I<   Oct14   0:00 [nfsiod]
root      1684  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[acpi_thermal_pm]
root      1801  0.0  0.0      0     0 ?        S    Oct14   0:00 [scsi_eh_0]
root      1802  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[scsi_tmf_0]
root      1806  0.0  0.0      0     0 ?        S    Oct14   0:00 [scsi_eh_1]
root      1807  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[scsi_tmf_1]
root      1810  0.0  0.0      0     0 ?        S    Oct14   0:00 [scsi_eh_2]
root      1811  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[scsi_tmf_2]
root      1814  0.0  0.0      0     0 ?        S    Oct14   0:00 [scsi_eh_3]
root      1815  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[scsi_tmf_3]
root      1838  0.0  0.0      0     0 ?        S    Oct14   0:00 [scsi_eh_4]
root      1839  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[scsi_tmf_4]
root      1842  0.0  0.0      0     0 ?        S    Oct14   0:00 [scsi_eh_5]
root      1843  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[scsi_tmf_5]
root      1846  0.0  0.0      0     0 ?        S    Oct14   0:00 [scsi_eh_6]
root      1847  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[scsi_tmf_6]
root      1850  0.0  0.0      0     0 ?        S    Oct14   0:00 [scsi_eh_7]
root      1851  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[scsi_tmf_7]
root      1854  0.0  0.0      0     0 ?        S    Oct14   0:00 [scsi_eh_8]
root      1855  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[scsi_tmf_8]
root      1858  0.0  0.0      0     0 ?        S    Oct14   0:00 [scsi_eh_9]
root      1859  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[scsi_tmf_9]
root      1921  0.0  0.0      0     0 ?        I<   Oct14   0:00 [ixgbe]
root      1923  0.0  0.0      0     0 ?        I<   Oct14   0:00 [i40e]
root      3058  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[ipv6_addrconf]
root      3087  0.0  0.0      0     0 ?        S    Oct14   0:01 [md3_raid1]
root      3092  0.0  0.0      0     0 ?        S    Oct14   0:00 [md2_raid1]
root      3097  0.0  0.0      0     0 ?        S    Oct14   0:00 [md1_raid1]
root      3099  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[reiserfs/md2]
root      3100  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[kworker/0:1H]
root      3124  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[kworker/6:1H]
root      3155  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[kworker/1:1H]
root      3244  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[kworker/11:1H]
root      3351  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[kworker/5:1H]
root      3467  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[kworker/8:1H]
root      3502  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[kworker/9:1H]
root      3503  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[kworker/2:1H]
root      3521  0.0  0.0      0     0 ?        SN   Oct14   0:00 [kipmi0]
root      3757  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[reiserfs/md3]
root      5096  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[kworker/10:1H]
root      5280  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[kworker/7:1H]
root      5447  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[kworker/3:1H]
root      6573  0.0  0.0      0     0 ?        I    16:10   0:00 
[kworker/3:0]
root      6584  0.0  0.0      0     0 ?        I    16:11   0:00 
[kworker/6:0]
root      6660  0.0  0.0      0     0 ?        I<   Oct14   0:00 
[kworker/4:1H]
root      6967  0.0  0.0      0     0 ?        I    16:15   0:00 
[kworker/5:2]
root      6976  0.0  0.0      0     0 ?        I    16:17   0:00 
[kworker/10:1]
root      7036  0.0  0.0      0     0 ?        I    06:19   0:02 
[kworker/0:4]
root      7750  0.0  0.0      0     0 ?        I    16:22   0:00 
[kworker/4:2]
root      9555  0.0  0.0      0     0 ?        I    16:25   0:00 
[kworker/2:2]
root      9557  0.0  0.0      0     0 ?        I    16:26   0:00 
[kworker/6:2]
root     10146  0.0  0.0      0     0 ?        I    16:27   0:00 
[kworker/8:2]
root     10148  0.0  0.0      0     0 ?        I    16:27   0:00 
[kworker/1:2]
root     13804  0.0  0.0      0     0 ?        I    13:42   0:00 
[kworker/0:1]
root     16109  0.0  0.0      0     0 ?        I    16:33   0:00 
[kworker/9:2]
root     16156  0.0  0.0      0     0 ?        I    16:39   0:00 
[kworker/4:0]
root     16422  0.0  0.0      0     0 ?        I    16:39   0:00 
[kworker/5:1]
root     16423  0.0  0.0      0     0 ?        I    16:39   0:00 
[kworker/9:0]
root     17118  0.0  0.0      0     0 ?        I    16:40   0:00 
[kworker/11:2]
root     17250  0.0  0.0      0     0 ?        I    16:42   0:00 
[kworker/3:1]
root     17620  0.0  0.0      0     0 ?        I    16:43   0:00 
[kworker/0:0]
root     17629  0.0  0.0      0     0 ?        I    16:45   0:00 
[kworker/2:1]
root     17639  0.0  0.0      0     0 ?        I    16:47   0:00 
[kworker/u24:0]
root     17640  0.0  0.0      0     0 ?        I    16:47   0:00 
[kworker/10:0]
root     17642  0.0  0.0      0     0 ?        I    16:48   0:00 
[kworker/0:5]
root     19577  0.0  0.0      0     0 ?        I    16:49   0:00 
[kworker/8:1]
root     19578  0.0  0.0      0     0 ?        I    16:49   0:00 
[kworker/8:3]
root     19819  0.0  0.0      0     0 ?        I    16:49   0:00 
[kworker/1:1]
root     19820  0.0  0.0      0     0 ?        I    16:49   0:00 
[kworker/1:3]
root     19972  0.0  0.0      0     0 ?        I    16:52   0:00 
[kworker/7:1]
root     19973  0.0  0.0      0     0 ?        I    16:52   0:00 
[kworker/7:3]
root     19974  0.0  0.0      0     0 ?        I    16:52   0:00 
[kworker/11:1]
root     19976  0.0  0.0      0     0 ?        I    16:52   0:00 
[kworker/u24:1]
root     20106  0.0  0.0      0     0 ?        I    16:53   0:00 
[kworker/4:1]
root     20107  0.0  0.0      0     0 ?        I    16:53   0:00 
[kworker/4:3]
root     20108  0.0  0.0      0     0 ?        I    16:54   0:00 
[kworker/3:2]
root     20109  0.0  0.0      0     0 ?        I    16:54   0:00 
[kworker/3:3]
root     20110  0.0  0.0      0     0 ?        I    16:54   0:00 
[kworker/0:6]
root     20217  0.0  0.0      0     0 ?        I    16:55   0:00 
[kworker/1:0]
root     20219  0.0  0.0      0     0 ?        I    16:56   0:00 
[kworker/9:1]
root     20222  0.0  0.0      0     0 ?        I    16:56   0:00 
[kworker/9:3]
root     20354  0.0  0.0      0     0 ?        I    16:57   0:00 
[kworker/5:0]
root     20355  0.0  0.0      0     0 ?        I    16:57   0:00 
[kworker/5:3]
root     20814  0.0  0.0      0     0 ?        I    16:57   0:00 
[kworker/u24:2]
root     26845  0.0  0.0      0     0 ?        I    15:40   0:00 
[kworker/7:2]
root     26979  0.0  0.0      0     0 ?        I    15:43   0:00 
[kworker/0:3]
root     27375  0.0  0.0      0     0 ?        I    15:48   0:00 
[kworker/0:2]

but free -m
free -m
               total        used        free      shared buff/cache   
available
Mem:          32113       18345       13598           0 169       13419
Swap:          3911           0        3911


less and less about 0.5MB per hour

it looks like this commit:

https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git/commit/drivers/net/ethernet/intel/i40e/i40e_txrx.c?id=2b9478ffc550f17c6cd8c69057234e91150f5972


Is not included in:
git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git


Ok will upgrade tomorrow - and will check with that fix.



W dniu 2017-10-15 o 02:58, Alexander Duyck pisze:
> Hi Pawel,
>
> To clarify is that Dave Miller's tree or Linus's that you are talking
> about? If it is Dave's tree how long ago was it you pulled it since I
> think the fix was just pushed by Jeff Kirsher a few days ago.
>
> The issue should be fixed in the following commit:
> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git/commit/drivers/net/ethernet/intel/i40e/i40e_txrx.c?id=2b9478ffc550f17c6cd8c69057234e91150f5972
>
> Thanks.
>
> - Alex
>
> On Sat, Oct 14, 2017 at 3:03 PM, Paweł Staszewski <pstaszewski@itcare.pl> wrote:
>> Forgot to add - this graphs are tested with Kernel 4.14-rc4-next
>>
>>
>> W dniu 2017-10-15 o 00:00, Paweł Staszewski pisze:
>>
>> Same problem here
>>
>> Also only difference is change 82599 intel to x710 and have memleak
>>
>> mem with ixgbe driver over time - same config saame kernel
>>
>>
>>
>> changed NIC's to x710 i40e driver (this is the only change)
>>
>> And mem over time:
>>
>>
>>
>> There is no process that is eating memory - looks like there is some problem
>> with i40e driver - but it not a surprise :) this driver is really buggy -
>> with many things - most tickets on e1000e sourceforge that i openned have no
>> reply for year or more - or if somebody reply after year they are closing
>> ticket after 1 day with info about no activity :)
>>
>>
>>
>> W dniu 2017-10-05 o 07:19, Anders K. Pedersen | Cohaesio pisze:
>>
>> On ons, 2017-10-04 at 08:32 -0700, Alexander Duyck wrote:
>>
>> On Wed, Oct 4, 2017 at 5:56 AM, Anders K. Pedersen | Cohaesio
>> <akp@cohaesio.com> wrote:
>>
>> Hello,
>>
>> After updating one of our Linux based routers to kernel 4.13 it
>> began
>> leaking memory quite fast (about 1 GB every half hour). To narrow
>> we
>> tried various kernel versions and found that 4.11.12 is okay, while
>> 4.12 also leaks, so we did a bisection between 4.11 and 4.12.
>>
>> The first bisection ended at
>> "[6964e53f55837b0c49ed60d36656d2e0ee4fc27b] i40e: fix handling of
>> HW
>> ATR eviction", which fixes some flag handling that was broken by
>> 47994c119a36 "i40e: remove hw_disabled_flags in favor of using
>> separate
>> flag bits", so I did a second bisection, where I added 6964e53f5583
>> "i40e: fix handling of HW ATR eviction" to the steps that had
>> 47994c119a36 "i40e: remove hw_disabled_flags in favor of using
>> separate
>> flag bits" in them.
>>
>> The second bisection ended at
>> "[0e626ff7ccbfc43c6cc4aeea611c40b899682382] i40e: Fix support for
>> flow
>> director programming status", where I don't see any obvious
>> problems,
>> so I'm hoping for some assistance.
>>
>> The router is a PowerEdge R730 server (Haswell based) with three
>> Intel
>> NICs (all using the i40e driver):
>>
>> X710 quad port 10 GbE SFP+: eth0 eth1 eth2 eth3
>> X710 quad port 10 GbE SFP+: eth4 eth5 eth6 eth7
>> XL710 dual port 40 GbE QSFP+: eth8 eth9
>>
>> The NICs are aggregated with LACP with the team driver:
>>
>> team0: eth9 (40 GbE selected primary), and eth3, eth7 (10 GbE non-
>> selected backups)
>> team1: eth0, eth1, eth4, eth5 (all 10 GbE selected)
>>
>> team0 is used for internal networks and has one untagged and four
>> tagged VLAN interfaces, while team1 has an external uplink
>> connection
>> without any VLANs.
>>
>> The router runs an eBGP session on team1 to one of our uplinks, and
>> iBGP via team0 to our other border routers. It also runs OSPF on
>> the
>> internal VLANs on team0. One thing I've noticed is that when OSPF
>> is
>> not announcing a default gateway to the internal networks, so there
>> is
>> almost no traffic coming in on team0 and out on team1, but still
>> plenty
>> of traffic coming in on team1 and out via team0, there's no memory
>> leak
>> (or at least it is so small that we haven't detected it). But as
>> soon
>> as we configure OSPF to announce a default gateway to the internal
>> VLANs, so we get traffic from team0 to team1 the leaking begins.
>> Stopping the OSPF default gateway announcement again also stops the
>> leaking, but does not release already leaked memory.
>>
>> So this leads to me suspect that the leaking is related to RX on
>> team0
>> (where XL710 eth9 is normally the only active interface) or TX on
>> team1
>> (X710 eth0, eth1, eth4, eth5). The first bad commit is related to
>> RX
>> cleaning, which suggests RX on team0. Since we're only seeing the
>> leak
>> for our outbound traffic, I suspect either a difference between the
>> X710 vs. XL710 NICs, or that the inbound traffic is for relatively
>> few
>> destination addresses (only our own systems) while the outbound
>> traffic
>> is for many different addresses on the internet. But I'm just
>> guessing
>> here.
>>
>> I've tried kmemleak, but it only found a few kB of suspected memory
>> leaks (several of which disappeared again after a while).
>>
>> Below I've included more details - git bisect logs, ethtool -i,
>> dmesg,
>> Kernel .config, and various memory related /proc files. Any help or
>> suggestions would be much appreciated, and please let me know if
>> more
>> information is needed or there's something I should try.
>>
>> Regards,
>> Anders K. Pedersen
>>
>> Hi Anders,
>>
>> I think I see the problem and should have a patch submitted shortly
>> to
>> address it. From what I can tell it looks like the issue is that we
>> weren't properly recycling the pages associated with descriptors that
>> contained an Rx programming status. For now the workaround would be
>> to
>> try disabling ATR via the "ethtool --set-priv-flags" command. I
>> should
>> have a patch out in the next hour or so that you can try testing to
>> verify if it addresses the issue.
>>
>> Thanks.
>>
>> - Alex
>>
>> Thanks Alex,
>>
>> I will test the patch in our next service window on Tuesday morning.
>>
>> Regards,
>> Anders
>>
>>
>>
