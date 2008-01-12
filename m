From: slavon@bigtelecom.ru
Subject: Re: e1000_clean_tx_irq: Detected Tx Unit Hang - it's bug?
Date: Sat, 12 Jan 2008 11:48:43 +0300
Message-ID: <20080112114843.x64k0xl3wg0s8wo8@mail.bigtelecom.ru>
References: <477E2833.70301@bigtelecom.ru> <477E92E3.1000202@intel.com>
	<20080112111553.hfrfyghwggcgsk0c@mail.bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=UTF-8;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:52687 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758949AbYALIsr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 03:48:47 -0500
In-Reply-To: <20080112111553.hfrfyghwggcgsk0c@mail.bigtelecom.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wow! Now at another PC have this messages in dmesg:
[83646.646305] NETDEV WATCHDOG: eth0: transmit timed out
[83646.646391] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
[83646.646392] Tx Queue <0>
[83646.646393] TDH <eb>
[83646.646394] TDT <eb>
[83646.646395] next_to_use <eb>
[83646.646396] next_to_clean <41>
[83646.646397] buffer_info[next_to_clean]
[83646.646398] time_stamp <4e0919c>
[83646.646399] next_to_watch <41>
[83646.646400] jiffies <4e0ab8e>
[83646.646400] next_to_watch.status <1>
[83651.683460] e1000: eth0: e1000_watchdog: NIC Link is Up 1000 Mbps  
Full Duplex, Flow Control: RX
[84849.372924] htb: too many events !
[86047.797913] htb: too many events !

PC not response some time to all packets! After
[83651.683460] e1000: eth0: e1000_watchdog: NIC Link is Up 1000 Mbps  
Full Duplex, Flow Control: RX
Its work again!

Strange
fw2 ~ # uname -a
Linux fw2 2.6.24-rc7-git2-fw #6 Fri Jan 11 11:07:42 MSK 2008 i686  
Intel(R) Pentium(R) 4 CPU 3.40GHz GenuineIntel GNU/Linux

fw2 ~ # lspci
00:00.0 Host bridge: Intel Corporation 82865G/PE/P DRAM  
Controller/Host-Hub Interface (rev 02)
00:02.0 VGA compatible controller: Intel Corporation 82865G Integrated  
Graphics Controller (rev 02)
00:1d.0 USB Controller: Intel Corporation 82801EB/ER (ICH5/ICH5R) USB  
UHCI Controller #1 (rev 02)
00:1d.1 USB Controller: Intel Corporation 82801EB/ER (ICH5/ICH5R) USB  
UHCI Controller #2 (rev 02)
00:1d.2 USB Controller: Intel Corporation 82801EB/ER (ICH5/ICH5R) USB  
UHCI Controller #3 (rev 02)
00:1d.3 USB Controller: Intel Corporation 82801EB/ER (ICH5/ICH5R) USB  
UHCI Controller #4 (rev 02)
00:1d.7 USB Controller: Intel Corporation 82801EB/ER (ICH5/ICH5R) USB2  
EHCI Controller (rev 02)
00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev c2)
00:1f.0 ISA bridge: Intel Corporation 82801EB/ER (ICH5/ICH5R) LPC  
Interface Bridge (rev 02)
00:1f.1 IDE interface: Intel Corporation 82801EB/ER (ICH5/ICH5R) IDE  
Controller (rev 02)
00:1f.3 SMBus: Intel Corporation 82801EB/ER (ICH5/ICH5R) SMBus  
Controller (rev 02)
01:09.0 Ethernet controller: Intel Corporation 82540EM Gigabit  
Ethernet Controller (rev 02)
01:0a.0 Ethernet controller: Intel Corporation 82540EM Gigabit  
Ethernet Controller (rev 02)
01:0b.0 SCSI storage controller: Adaptec ASC-39320 U320 (rev 03)
01:0b.1 SCSI storage controller: Adaptec ASC-39320 U320 (rev 03)



>>> Hello all.
>>> Some time in dmesg i see this:
>>>
>>> [16121.400422] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
>>> [16121.400426] Tx Queue <0>
>>> [16121.400427] TDH <28>
>>> [16121.400429] TDT <28>
>>> [16121.400430] next_to_use <28>
>>> [16121.400431] next_to_clean <7d>
>>> [16121.400433] buffer_info[next_to_clean]
>>> [16121.400434] time_stamp <17b949>
>>> [16121.400435] next_to_watch <7d>
>>> [16121.400437] jiffies <17ba57>
>>> [16121.400438] next_to_watch.status <1>
>>
>> might be a bug. What kernel version are you using?
>
> Hello.
>
> Now i try 2.6.24-rc7-git2 - its have NAPI patches that work GREAT!
>
> Have many messages like up in dmeseg.
>
> Also more info for You
> fw ~ # ethtool -S eth0
>
> NIC statistics:
> rx_packets: 1048831452
> tx_packets: 28418
> rx_bytes: 644208597062
> tx_bytes: 3458632
> rx_broadcast: 1840
> tx_broadcast: 5
> rx_multicast: 0
> tx_multicast: 0
> rx_errors: 1663
> tx_errors: 0
> tx_dropped: 0
> multicast: 0
> collisions: 0
> rx_length_errors: 0
> rx_over_errors: 0
> rx_crc_errors: 5172
> rx_frame_errors: 0
> rx_no_buffer_count: 153305
> rx_missed_errors: 883176
> tx_aborted_errors: 0
> tx_carrier_errors: 0
> tx_fifo_errors: 0
> tx_heartbeat_errors: 0
> tx_window_errors: 0
> tx_abort_late_coll: 0
> tx_deferred_ok: 0
> tx_single_coll_ok: 0
> tx_multi_coll_ok: 0
> tx_timeout_count: 0
> tx_restart_queue: 0
> rx_long_length_errors: 0
> rx_short_length_errors: 0
> rx_align_errors: 0
> tx_tcp_seg_good: 10
> tx_tcp_seg_failed: 0
> rx_flow_control_xon: 0
> rx_flow_control_xoff: 0
> tx_flow_control_xon: 0
> tx_flow_control_xoff: 0
> rx_long_byte_count: 644208597062
> rx_csum_offload_good: 1030747822
> rx_csum_offload_errors: 7086
> rx_header_split: 0
> alloc_rx_buff_failed: 0
> tx_smbus: 0
> rx_smbus: 0
> dropped_smbus: 0
>
>
> That my dmesg:
> [ 5280.282257] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [ 5280.282264] Tx Queue <0>
> [ 5280.282265] TDH <67>
> [ 5280.282265] TDT <a9>
> [ 5280.282266] next_to_use <a9>
> [ 5280.282267] next_to_clean <fe>
> [ 5280.282268] buffer_info[next_to_clean]
> [ 5280.282269] time_stamp <76c86>
> [ 5280.282270] next_to_watch <fe>
> [ 5280.282271] jiffies <76d33>
> [ 5280.282272] next_to_watch.status <1>
> [ 272.396662] opreport[5752]: segfault at b7be1010 eip 080b396e esp
> bfba9480 error 4
> [ 2264.085353] htb: too many events !
> [ 3376.658037] htb: too many events !
> [ 5724.766531] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [ 5724.766533] Tx Queue <0>
> [ 5724.766534] TDH <23>
> [ 5724.766535] TDT <23>
> [ 5724.766536] next_to_use <23>
> [ 5724.766537] next_to_clean <fd>
> [ 5724.766537] buffer_info[next_to_clean]
> [ 5724.766538] time_stamp <50db81>
> [ 5724.766539] next_to_watch <fd>
> [ 5724.766540] jiffies <50e3ab>
> [ 5724.766541] next_to_watch.status <1>
> [ 5724.767771] htb: too many events !
> [10527.197125] htb: too many events !
> [11744.405451] htb: too many events !
> [12925.662880] htb: too many events !
> [14123.186443] htb: too many events !
> [15333.652189] htb: too many events !
> [16522.524045] htb: too many events !
> [17722.572386] htb: too many events !
> [18925.121034] htb: too many events !
> [20117.689133] htb: too many events !
> [20117.690436] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [20117.690438] Tx Queue <0>
> [20117.690439] TDH <8>
> [20117.690440] TDT <4b>
> [20117.690441] next_to_use <4b>
> [20117.690442] next_to_clean <a0>
> [20117.690443] buffer_info[next_to_clean]
> [20117.690443] time_stamp <128b414>
> [20117.690444] next_to_watch <a0>
> [20117.690445] jiffies <128bc3f>
> [20117.690446] next_to_watch.status <1>
> [21314.498859] htb: too many events !
> [22192.855455] htb: too many events !
> [22520.640345] htb: too many events !
> [23712.083687] htb: too many events !
> [24912.407418] htb: too many events !
> [26128.954774] htb: too many events !
> [27314.726708] htb: too many events !
> [28517.307859] htb: too many events !
> [28517.309179] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [28517.309181] Tx Queue <0>
> [28517.309182] TDH <1a>
> [28517.309183] TDT <4f>
> [28517.309184] next_to_use <4f>
> [28517.309185] next_to_clean <a4>
> [28517.309186] buffer_info[next_to_clean]
> [28517.309187] time_stamp <1a5c7c3>
> [28517.309187] next_to_watch <a4>
> [28517.309188] jiffies <1a5cf20>
> [28517.309189] next_to_watch.status <1>
> [30922.659736] htb: too many events !
> [30922.661064] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [30922.661066] Tx Queue <0>
> [30922.661067] TDH <51>
> [30922.661068] TDT <76>
> [30922.661069] next_to_use <76>
> [30922.661070] next_to_clean <cb>
> [30922.661071] buffer_info[next_to_clean]
> [30922.661071] time_stamp <1c9ad65>
> [30922.661072] next_to_watch <cb>
> [30922.661073] jiffies <1c9b459>
> [30922.661074] next_to_watch.status <1>
> [32124.687849] htb: too many events !
> [33345.636940] htb: too many events !
> [34528.356531] htb: too many events !
> [34528.358024] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [34528.358027] Tx Queue <0>
> [34528.358028] TDH <fa>
> [34528.358029] TDT <3>
> [34528.358029] next_to_use <3>
> [34528.358030] next_to_clean <58>
> [34528.358031] buffer_info[next_to_clean]
> [34528.358032] time_stamp <1ff85ab>
> [34528.358033] next_to_watch <58>
> [34528.358034] jiffies <1ff8d27>
> [34528.358035] next_to_watch.status <1>
> [35734.669698] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [35734.669700] Tx Queue <0>
> [35734.669701] TDH <5f>
> [35734.669702] TDT <5f>
> [35734.669703] next_to_use <5f>
> [35734.669704] next_to_clean <bf>
> [35734.669705] buffer_info[next_to_clean]
> [35734.669705] time_stamp <211994b>
> [35734.669706] next_to_watch <bf>
> [35734.669707] jiffies <211a017>
> [35734.669708] next_to_watch.status <1>
> [35734.672161] htb: too many events !
> [36955.160096] htb: too many events !
> [38118.346906] htb: too many events !
> [39330.213684] htb: too many events !
> [39330.214762] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [39330.214764] Tx Queue <0>
> [39330.214765] TDH <eb>
> [39330.214766] TDT <45>
> [39330.214767] next_to_use <45>
> [39330.214767] next_to_clean <9a>
> [39330.214768] buffer_info[next_to_clean]
> [39330.214769] time_stamp <2477328>
> [39330.214770] next_to_watch <9a>
> [39330.214771] jiffies <2477b16>
> [39330.214772] next_to_watch.status <1>
> [40551.898491] htb: too many events !
> [40551.899264] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [40551.899266] Tx Queue <0>
> [40551.899267] TDH <bf>
> [40551.899268] TDT <ca>
> [40551.899269] next_to_use <ca>
> [40551.899269] next_to_clean <1f>
> [40551.899270] buffer_info[next_to_clean]
> [40551.899271] time_stamp <259c212>
> [40551.899272] next_to_watch <1f>
> [40551.899273] jiffies <259c91e>
> [40551.899274] next_to_watch.status <1>
> [41724.774002] htb: too many events !
> [42920.657519] htb: too many events !
> [44143.420904] htb: too many events !
> [45303.157047] htb: too many events !
> [46492.258329] htb: too many events !
> [47694.779740] htb: too many events !
> [58471.571956] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [58471.571959] Tx Queue <0>
> [58471.571960] TDH <7b>
> [58471.571960] TDT <7b>
> [58471.571961] next_to_use <7b>
> [58471.571962] next_to_clean <d0>
> [58471.571963] buffer_info[next_to_clean]
> [58471.571964] time_stamp <36516dd>
> [58471.571965] next_to_watch <d0>
> [58471.571966] jiffies <36531cc>
> [58471.571967] next_to_watch.status <1>
> [59669.526000] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [59669.526002] Tx Queue <0>
> [59669.526003] TDH <6>
> [59669.526004] TDT <1e>
> [59669.526005] next_to_use <1e>
> [59669.526006] next_to_clean <73>
> [59669.526007] buffer_info[next_to_clean]
> [59669.526008] time_stamp <37718da>
> [59669.526009] next_to_watch <73>
> [59669.526009] jiffies <3773434>
> [59669.526010] next_to_watch.status <1>
> [60865.254499] NETDEV WATCHDOG: eth0: transmit timed out
> [60865.254584] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [60865.254585] Tx Queue <0>
> [60865.254586] TDH <ed>
> [60865.254587] TDT <ed>
> [60865.254588] next_to_use <ed>
> [60865.254589] next_to_clean <4c>
> [60865.254590] buffer_info[next_to_clean]
> [60865.254590] time_stamp <38919bb>
> [60865.254591] next_to_watch <4c>
> [60865.254592] jiffies <38934a2>
> [60865.254593] next_to_watch.status <1>
> [62064.876121] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [62064.876123] Tx Queue <0>
> [62064.876124] TDH <6a>
> [62064.876125] TDT <71>
> [62064.876126] next_to_use <71>
> [62064.876126] next_to_clean <c6>
> [62064.876127] buffer_info[next_to_clean]
> [62064.876128] time_stamp <39b221d>
> [62064.876129] next_to_watch <c6>
> [62064.876130] jiffies <39b3d07>
> [62064.876131] next_to_watch.status <1>
> [63261.288625] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [63261.288628] Tx Queue <0>
> [63261.288629] TDH <b9>
> [63261.288630] TDT <b9>
> [63261.288631] next_to_use <b9>
> [63261.288631] next_to_clean <e>
> [63261.288632] buffer_info[next_to_clean]
> [63261.288633] time_stamp <3ad1b46>
> [63261.288634] next_to_watch <e>
> [63261.288635] jiffies <3ad3b43>
> [63261.288636] next_to_watch.status <1>
> [64459.486793] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [64459.486796] Tx Queue <0>
> [64459.486797] TDH <19>
> [64459.486798] TDT <19>
> [64459.486798] next_to_use <19>
> [64459.486799] next_to_clean <ae>
> [64459.486800] buffer_info[next_to_clean]
> [64459.486801] time_stamp <3bf25e5>
> [64459.486802] next_to_watch <ae>
> [64459.486803] jiffies <3bf422f>
> [64459.486804] next_to_watch.status <1>
> [65663.246067] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [65663.246069] Tx Queue <0>
> [65663.246070] TDH <c3>
> [65663.246071] TDT <17>
> [65663.246072] next_to_use <17>
> [65663.246073] next_to_clean <6c>
> [65663.246074] buffer_info[next_to_clean]
> [65663.246075] time_stamp <3d141e5>
> [65663.246076] next_to_watch <6c>
> [65663.246077] jiffies <3d15cca>
> [65663.246077] next_to_watch.status <1>
> [66855.416474] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [66855.416477] Tx Queue <0>
> [66855.416478] TDH <e5>
> [66855.416479] TDT <e5>
> [66855.416480] next_to_use <e5>
> [66855.416480] next_to_clean <96>
> [66855.416481] buffer_info[next_to_clean]
> [66855.416482] time_stamp <3e333f4>
> [66855.416483] next_to_watch <96>
> [66855.416484] jiffies <3e35090>
> [66855.416485] next_to_watch.status <1>
> [68054.040533] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [68054.040536] Tx Queue <0>
> [68054.040537] TDH <b2>
> [68054.040538] TDT <2>
> [68054.040538] next_to_use <2>
> [68054.040539] next_to_clean <57>
> [68054.040540] buffer_info[next_to_clean]
> [68054.040541] time_stamp <3f546cd>
> [68054.040542] next_to_watch <57>
> [68054.040542] jiffies <3f560f6>
> [68054.040543] next_to_watch.status <1>
> [69260.670653] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [69260.670656] Tx Queue <0>
> [69260.670657] TDH <83>
> [69260.670657] TDT <e9>
> [69260.670658] next_to_use <e9>
> [69260.670659] next_to_clean <3e>
> [69260.670660] buffer_info[next_to_clean]
> [69260.670661] time_stamp <4077a70>
> [69260.670662] next_to_watch <3e>
> [69260.670663] jiffies <40795d1>
> [69260.670663] next_to_watch.status <1>
> [70450.618127] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [70450.618130] Tx Queue <0>
> [70450.618131] TDH <e5>
> [70450.618131] TDT <35>
> [70450.618132] next_to_use <35>
> [70450.618133] next_to_clean <8a>
> [70450.618134] buffer_info[next_to_clean]
> [70450.618135] time_stamp <4196ed3>
> [70450.618136] next_to_watch <8a>
> [70450.618137] jiffies <41987ab>
> [70450.618137] next_to_watch.status <1>
> [71648.909256] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [71648.909258] Tx Queue <0>
> [71648.909259] TDH <41>
> [71648.909260] TDT <42>
> [71648.909261] next_to_use <42>
> [71648.909262] next_to_clean <97>
> [71648.909262] buffer_info[next_to_clean]
> [71648.909263] time_stamp <42b8542>
> [71648.909264] next_to_watch <97>
> [71648.909265] jiffies <42b9fa1>
> [71648.909266] next_to_watch.status <1>
> [72851.697294] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [72851.697297] Tx Queue <0>
> [72851.697298] TDH <30>
> [72851.697298] TDT <54>
> [72851.697299] next_to_use <54>
> [72851.697300] next_to_clean <a9>
> [72851.697301] buffer_info[next_to_clean]
> [72851.697302] time_stamp <43dadd4>
> [72851.697303] next_to_watch <a9>
> [72851.697304] jiffies <43dc870>
> [72851.697305] next_to_watch.status <1>
> [75245.677954] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [75245.677957] Tx Queue <0>
> [75245.677958] TDH <85>
> [75245.677958] TDT <b5>
> [75245.677959] next_to_use <b5>
> [75245.677960] next_to_clean <a>
> [75245.677961] buffer_info[next_to_clean]
> [75245.677962] time_stamp <461dd97>
> [75245.677963] next_to_watch <a>
> [75245.677964] jiffies <461f952>
> [75245.677965] next_to_watch.status <1>
> [76448.839007] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [76448.839009] Tx Queue <0>
> [76448.839011] TDH <18>
> [76448.839012] TDT <68>
> [76448.839012] next_to_use <68>
> [76448.839013] next_to_clean <bd>
> [76448.839014] buffer_info[next_to_clean]
> [76448.839015] time_stamp <4740b7f>
> [76448.839016] next_to_watch <bd>
> [76448.839017] jiffies <4742788>
> [76448.839018] next_to_watch.status <1>
> [77641.472192] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [77641.472195] Tx Queue <0>
> [77641.472197] TDH <f>
> [77641.472198] TDT <6a>
> [77641.472198] next_to_use <6a>
> [77641.472199] next_to_clean <d7>
> [77641.472200] buffer_info[next_to_clean]
> [77641.472201] time_stamp <48612f3>
> [77641.472202] next_to_watch <d7>
> [77641.472203] jiffies <4862c1f>
> [77641.472204] next_to_watch.status <1>
> [78841.540399] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [78841.540401] Tx Queue <0>
> [78841.540402] TDH <49>
> [78841.540403] TDT <49>
> [78841.540404] next_to_use <49>
> [78841.540405] next_to_clean <40>
> [78841.540406] buffer_info[next_to_clean]
> [78841.540406] time_stamp <49832d4>
> [78841.540407] next_to_watch <40>
> [78841.540408] jiffies <4984da3>
> [78841.540409] next_to_watch.status <1>
> [80047.286824] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [80047.286827] Tx Queue <0>
> [80047.286828] TDH <fc>
> [80047.286829] TDT <37>
> [80047.286830] next_to_use <37>
> [80047.286830] next_to_clean <8c>
> [80047.286831] buffer_info[next_to_clean]
> [80047.286832] time_stamp <4aa66e4>
> [80047.286833] next_to_watch <8c>
> [80047.286834] jiffies <4aa812b>
> [80047.286835] next_to_watch.status <1>
> [81240.261877] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [81240.261879] Tx Queue <0>
> [81240.261880] TDH <8f>
> [81240.261881] TDT <be>
> [81240.261882] next_to_use <be>
> [81240.261883] next_to_clean <13>
> [81240.261884] buffer_info[next_to_clean]
> [81240.261884] time_stamp <4bc5b32>
> [81240.261885] next_to_watch <13>
> [81240.261886] jiffies <4bc73d9>
> [81240.261887] next_to_watch.status <1>
> [82440.249836] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [82440.249838] Tx Queue <0>
> [82440.249839] TDH <9d>
> [82440.249840] TDT <9d>
> [82440.249841] next_to_use <9d>
> [82440.249842] next_to_clean <f2>
> [82440.249842] buffer_info[next_to_clean]
> [82440.249843] time_stamp <4ce6735>
> [82440.249844] next_to_watch <f2>
> [82440.249845] jiffies <4ce8149>
> [82440.249846] next_to_watch.status <1>
>
>
>
>> it appears the tx
>> handler was
>> just sitting idle and this message might be bogus, which is one of
>> the things that
>> we fixed recently.
>>
>> Auke
>>
>>

----------------------------------------------------------------
This message was sent using IMP, the Internet Messaging Program.

