From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Performance comparision / qdisc / no qdisc / queueing linux kernel
 4.12
Date: Sat, 5 Aug 2017 18:38:11 +0200
Message-ID: <a59c1fdf-9c32-50f6-eb45-040e4ce30cff@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp7.iq.pl ([86.111.240.244]:58702 "EHLO smtp7.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751226AbdHEQrY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 5 Aug 2017 12:47:24 -0400
Received: from [192.168.2.200] (unknown [185.78.72.19])
        (Authenticated sender: pstaszewski@itcare.pl)
        by smtp.iq.pl (Postfix) with ESMTPSA id 3xPqJR3hXsz3x7w
        for <netdev@vger.kernel.org>; Sat,  5 Aug 2017 18:39:35 +0200 (CEST)
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi


Want to send some comparisions about poor performance of kernel when 
simple queueing is enabled


So first - kernel performance for forwarded udp packets generated from 
pktgen:

UDP stream ~10Mpps - random destination from network 172.16.0.0/12 + 
random udp port


Forwarding performance with 8x RSS queues

       enp216s0f0:      9772859.00 P/s             0.00 P/s 9772859.00 P/s
        enp216s0f1:            0.00 P/s       9772883.00 P/s 9772883.00 P/s
------------------------------------------------------------------------------
             total:      9772863.00 P/s       9772886.00 P/s 19545750.00 P/s

mpstat -P ALL 1 10

Average:     CPU    %usr   %nice    %sys %iowait    %irq   %soft %steal  
%guest  %gnice   %idle
Average:     all    0.00    0.00    0.00    0.00    0.00 11.89    
0.00    0.00    0.00   88.11
Average:       0    0.00    0.00    0.00    0.00    0.00 0.10    0.00    
0.00    0.00   99.90
Average:       1    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:       2    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:       3    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:       4    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:       5    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:       6    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:       7    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:       8    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:       9    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      10    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      11    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      12    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      13    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      14    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      15    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      16    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      17    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      18    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      19    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      20    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      21    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      22    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      23    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      24    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      25    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      26    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      27    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      28    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      29    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      30    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      31    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      32    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      33    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      34    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      35    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      36    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      37    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      38    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      39    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      40    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      41    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      42    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      43    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      44    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      45    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      46    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      47    0.00    0.00    0.00    0.00    0.00 0.00    0.00    
0.00    0.00  100.00
Average:      48    0.00    0.00    0.00    0.00    0.00 84.10    
0.00    0.00    0.00   15.90
Average:      49    0.00    0.00    0.00    0.00    0.00 83.20    
0.00    0.00    0.00   16.80
Average:      50    0.00    0.00    0.00    0.00    0.00 81.98    
0.00    0.00    0.00   18.02
Average:      51    0.00    0.00    0.00    0.00    0.00 80.80    
0.00    0.00    0.00   19.20
Average:      52    0.00    0.00    0.00    0.00    0.00 82.20    
0.00    0.00    0.00   17.80
Average:      53    0.00    0.00    0.00    0.00    0.00 85.30    
0.00    0.00    0.00   14.70
Average:      54    0.00    0.00    0.00    0.00    0.00 85.30    
0.00    0.00    0.00   14.70
Average:      55    0.00    0.00    0.00    0.00    0.00 82.88    
0.00    0.00    0.00   17.12


So there is no problem with 8x queues to forward almost 10Mpps with ~90% 
cpu load on 8x queues


some turbostat:

./turbostat
turbostat version 17.06.23 - Len Brown <lenb@kernel.org>
CPUID(0): GenuineIntel 22 CPUID levels; family:model:stepping 0x6:55:4 
(6:85:4)
CPUID(1): SSE3 MONITOR SMX EIST TM2 TSC MSR ACPI-TM TM
CPUID(6): APERF, TURBO, DTS, PTM, No-HWP, No-HWPnotify, No-HWPwindow, 
No-HWPepp, No-HWPpkg, EPB
cpu12: MSR_IA32_MISC_ENABLE: 0x00850089 (TCC EIST No-MWAIT PREFETCH TURBO)
CPUID(7): No-SGX
CPUID(0x15): eax_crystal: 2 ebx_tsc: 208 ecx_crystal_hz: 0
TSC: 2600 MHz (25000000 Hz * 208 / 2 / 1000000)
CPUID(0x16): base_mhz: 2600 max_mhz: 3700 bus_mhz: 100
cpu12: MSR_MISC_PWR_MGMT: 0x00402000 (ENable-EIST_Coordination 
DISable-EPB DISable-OOB)
RAPL: 1872 sec. Joule Counter Range, at 140 Watts
cpu12: MSR_PLATFORM_INFO: 0x70a2cf3811a00
10 * 100.0 = 1000.0 MHz max efficiency frequency
26 * 100.0 = 2600.0 MHz base frequency
cpu12: MSR_IA32_POWER_CTL: 0x2904005b (C1E auto-promotion: ENabled)
cpu12: MSR_TURBO_RATIO_LIMIT: 0x2121212122222325
cpu12: MSR_TURBO_RATIO_LIMIT1: 0x1c18140e0c080402
33 * 100.0 = 3300.0 MHz max turbo 28 active cores
33 * 100.0 = 3300.0 MHz max turbo 24 active cores
33 * 100.0 = 3300.0 MHz max turbo 20 active cores
33 * 100.0 = 3300.0 MHz max turbo 14 active cores
34 * 100.0 = 3400.0 MHz max turbo 12 active cores
34 * 100.0 = 3400.0 MHz max turbo 8 active cores
35 * 100.0 = 3500.0 MHz max turbo 4 active cores
37 * 100.0 = 3700.0 MHz max turbo 2 active cores
cpu12: MSR_CONFIG_TDP_NOMINAL: 0x0000001a (base_ratio=26)
cpu12: MSR_CONFIG_TDP_LEVEL_1: 0x108094800110460 (PKG_MIN_PWR_LVL1=264 
PKG_MAX_PWR_LVL1=2376 LVL1_RATIO=17 PKG_TDP_LVL1=1120)
cpu12: MSR_CONFIG_TDP_LEVEL_2: 0x108094800110460 (PKG_MIN_PWR_LVL2=264 
PKG_MAX_PWR_LVL2=2376 LVL2_RATIO=17 PKG_TDP_LVL2=1120)
cpu12: MSR_CONFIG_TDP_CONTROL: 0x80000000 ( lock=1)
cpu12: MSR_TURBO_ACTIVATION_RATIO: 0x000000ff (MAX_NON_TURBO_RATIO=255 
lock=0)
cpu12: MSR_PKG_CST_CONFIG_CONTROL: 0x00008403 (locked: 
pkg-cstate-limit=3: pc6r)
cpu12: POLL: CPUIDLE CORE POLL IDLE
cpu12: C1: ACPI FFH INTEL MWAIT 0x0
cpu12: C2: ACPI FFH INTEL MWAIT 0x20
cpu12: cpufreq driver: acpi-cpufreq
cpu12: cpufreq governor: performance
cpufreq boost: 1
cpu12: MSR_MISC_FEATURE_CONTROL: 0x00000000 (L2-Prefetch 
L2-Prefetch-pair L1-Prefetch L1-IP-Prefetch)
cpu0: MSR_IA32_ENERGY_PERF_BIAS: 0x00000006 (balanced)
cpu14: MSR_IA32_ENERGY_PERF_BIAS: 0x00000006 (balanced)
cpu0: MSR_RAPL_POWER_UNIT: 0x000a0e03 (0.125000 Watts, 0.000061 Joules, 
0.000977 sec.)
cpu0: MSR_PKG_POWER_INFO: 0xf094802100460 (140 W TDP, RAPL 66 - 297 W, 
0.014648 sec.)
cpu0: MSR_PKG_POWER_LIMIT: 0x3854000148460 (UNlocked)
cpu0: PKG Limit #1: ENabled (140.000000 Watts, 1.000000 sec, clamp DISabled)
cpu0: PKG Limit #2: ENabled (168.000000 Watts, 0.001953* sec, clamp ENabled)
cpu0: MSR_DRAM_POWER_INFO,: 0xf00a000120098 (19 W TDP, RAPL 2 - 20 W, 
0.014648 sec.)
cpu0: MSR_DRAM_POWER_LIMIT: 0x00000000 (UNlocked)
cpu0: DRAM Limit: DISabled (0.000000 Watts, 0.000977 sec, clamp DISabled)
cpu14: MSR_RAPL_POWER_UNIT: 0x000a0e03 (0.125000 Watts, 0.000061 Joules, 
0.000977 sec.)
cpu14: MSR_PKG_POWER_INFO: 0xf094802100460 (140 W TDP, RAPL 66 - 297 W, 
0.014648 sec.)
cpu14: MSR_PKG_POWER_LIMIT: 0x3854000148460 (UNlocked)
cpu14: PKG Limit #1: ENabled (140.000000 Watts, 1.000000 sec, clamp 
DISabled)
cpu14: PKG Limit #2: ENabled (168.000000 Watts, 0.001953* sec, clamp 
ENabled)
cpu14: MSR_DRAM_POWER_INFO,: 0xf00a000120098 (19 W TDP, RAPL 2 - 20 W, 
0.014648 sec.)
cpu14: MSR_DRAM_POWER_LIMIT: 0x00000000 (UNlocked)
cpu14: DRAM Limit: DISabled (0.000000 Watts, 0.000977 sec, clamp DISabled)
cpu0: MSR_IA32_TEMPERATURE_TARGET: 0x00650a00 (101 C)
cpu14: MSR_IA32_TEMPERATURE_TARGET: 0x00650a00 (101 C)
cpu0: MSR_IA32_PACKAGE_THERM_STATUS: 0x882f0800 (54 C)
cpu0: MSR_IA32_PACKAGE_THERM_INTERRUPT: 0x00000003 (101 C, 101 C)
cpu14: MSR_IA32_PACKAGE_THERM_STATUS: 0x88250800 (64 C)
cpu14: MSR_IA32_PACKAGE_THERM_INTERRUPT: 0x00000003 (101 C, 101 C)
cpu12: MSR_PKGC3_IRTL: 0x00000000 (NOTvalid, 0 ns)
cpu12: MSR_PKGC6_IRTL: 0x00000000 (NOTvalid, 0 ns)
cpu12: MSR_PKGC7_IRTL: 0x00000000 (NOTvalid, 0 ns)
Package Core    CPU     Avg_MHz Busy%   Bzy_MHz TSC_MHz IRQ SMI     
C1      C2      C1%     C2%     CPU%c1  CPU%c6  CoreTmp PkgTmp  Pkg%pc2 
Pkg%pc6 PkgWatt RAMWatt PKG_%   RAM_%
-       -       -       433     13.25   3265    2600    3383743 0       
111     1620625 0.09    86.94   26.20   60.55   -4 64      42.78   
0.00    168.80  20.11   0.00    0.00
0       0       0       8       0.78    1029    2600    1650 0       
71      1547    2.25    97.19   12.97   86.25   50 54      85.55   
0.00    60.31   5.64    0.00    0.00
0       0       28      7       0.69    1018    2600    1255 0       
16      1246    1.28    98.26   13.07
0       1       1       7       0.70    1020    2600    1260 0       
0       1257    0.00    99.52   9.29    90.01   53
0       1       29      7       0.66    1018    2600    1255 0       
0       1256    0.00    99.52   9.33
0       2       2       7       0.68    1019    2600    1260 0       
0       1259    0.00    99.51   9.31    90.01   51
0       2       30      7       0.67    1019    2600    1255 0       
0       1256    0.00    99.52   9.32
0       3       3       7       0.68    1019    2600    1260 0       
0       1259    0.00    99.52   9.33    89.99   -4
0       3       31      7       0.68    1018    2600    1255 0       
0       1255    0.00    99.53   9.33
0       4       4       7       0.69    1020    2600    1260 0       
0       1259    0.00    99.50   9.35    89.96   -4
0       4       32      7       0.69    1018    2600    1255 0       
0       1255    0.00    99.51   9.35
0       5       5       7       0.69    1021    2600    1260 0       
0       1259    0.00    99.52   9.31    89.99   53
0       5       33      7       0.70    1021    2600    1255 0       
0       1255    0.00    99.52   9.31
0       6       6       7       0.71    1022    2600    1260 0       
0       1259    0.00    99.52   9.31    89.97   -4
0       6       34      7       0.73    1022    2600    1255 0       
0       1255    0.00    99.52   9.30
0       8       7       7       0.71    1021    2600    1257 0       
4       1253    0.32    99.20   9.52    89.77   54
0       8       35      7       0.67    1018    2600    1255 0       
0       1255    0.00    99.52   9.56
0       9       8       7       0.68    1019    2600    1266 0       
0       1258    0.00    99.51   9.53    89.79   52
0       9       36      7       0.68    1017    2600    1255 0       
4       1250    0.32    99.20   9.53
0       10      9       7       0.67    1020    2600    1257 0       
5       1253    0.24    99.29   9.55    89.78   -4
0       10      37      7       0.68    1018    2600    1255 0       
4       1250    0.32    99.21   9.55
0       11      10      7       0.69    1018    2600    1257 0       
0       1258    0.00    99.51   9.31    89.99   -4
0       11      38      7       0.68    1018    2600    1255 0       
0       1254    0.00    99.52   9.33
0       12      11      7       0.69    1020    2600    1257 0       
0       1257    0.00    99.52   9.31    90.00   -4
0       12      39      7       0.69    1019    2600    1255 0       
0       1254    0.00    99.53   9.31
0       13      12      9       0.77    1182    2600    1252 0       
0       1252    0.00    99.45   9.32    89.91   -4
0       13      40      7       0.71    1021    2600    1255 0       
0       1256    0.00    99.53   9.38
0       14      13      7       0.73    1021    2600    1257 0       
0       1258    0.00    99.51   9.30    89.97   -4
0       14      41      7       0.73    1019    2600    1255 0       
0       1254    0.00    99.52   9.30
1       0       14      10      0.30    3301    2600    1264 0       
4       1262    0.24    99.56   26.54   73.16   52 64      0.00    
0.00    108.49  14.47   0.00    0.00
1       0       42      9       0.28    3301    2600    1255 0       
0       1254    0.00    99.80   26.56
1       1       15      9       0.29    3300    2600    1257 0       
0       1258    0.00    99.81   26.34   73.37   56
1       1       43      9       0.27    3301    2600    1255 0       
0       1254    0.00    99.81   26.36
1       2       16      9       0.28    3301    2600    1257 0       
0       1256    0.00    99.81   26.34   73.39   52
1       2       44      9       0.28    3301    2600    1255 0       
0       1254    0.00    99.81   26.34
1       3       17      9       0.29    3301    2600    1257 0       
0       1256    0.00    99.81   26.36   73.35   50
1       3       45      9       0.27    3301    2600    1255 0       
0       1254    0.00    99.81   26.37
1       4       18      8       0.25    3301    2600    1257 0       
0       1256    0.00    99.83   26.32   73.43   54
1       4       46      9       0.26    3301    2600    1255 0       
0       1254    0.00    99.82   26.31
1       5       19      9       0.26    3301    2600    1257 0       
0       1256    0.00    99.83   26.36   73.38   53
1       5       47      9       0.28    3301    2600    1255 0       
0       1255    0.00    99.82   26.35
1       6       20      4       0.10    3400    2600    1257 0       
3       1254    0.00    99.92   99.90   0.00    64
1       6       48      3038    90.07   3373    2600    398503 0       
0       187917  0.00    10.98   9.93
1       8       21      4       0.11    3399    2600    1257 0       
0       1257    0.00    99.90   99.89   0.00    64
1       8       49      2999    88.90   3373    2600    432524 0       
0       207412  0.00    12.21   11.10
1       9       22      4       0.10    3400    2600    1257 0       
0       1257    0.00    99.91   99.90   0.00    61
1       9       50      2972    88.12   3373    2600    458194 0       
0       221818  0.00    13.24   11.88
1       10      23      4       0.11    3399    2600    1257 0       
0       1257    0.00    99.91   99.89   0.00    63
1       10      51      3008    89.19   3373    2600    426511 0       
0       203832  0.00    11.97   10.81
1       11      24      4       0.10    3399    2600    1257 0       
0       1257    0.00    99.91   99.90   0.00    62
1       11      52      2989    88.62   3373    2600    496267 0       
0       226496  0.00    12.71   11.38
1       12      25      4       0.11    3297    2600    1257 0       
0       1257    0.00    99.91   99.89   0.00    62
1       12      53      2930    91.90   3189    2600    348610 0       
0       157897  0.00    8.76    8.10
1       13      26      4       0.14    3237    2600    1258 0       
0       1260    0.00    99.88   99.86   0.00    59
1       13      54      2923    91.67   3189    2600    356448 0       
0       162567  0.00    9.03    8.33
1       14      27      4       0.11    3399    2600    1257 0       
0       1257    0.00    99.91   99.89   0.00    62
1       14      55      3033    89.92   3373    2600    405967 0       
0       192122  0.00    11.05   10.08



And perf top

    PerfTop:   55080 irqs/sec  kernel:99.8%  exact:  0.0% [4000Hz 
cycles],  (all, 56 CPUs)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

     21.93%  [kernel]       [k] do_raw_spin_lock
      7.22%  [kernel]       [k] fib_table_lookup
      6.79%  [kernel]       [k] acpi_processor_ffh_cstate_enter
      5.46%  [kernel]       [k] ixgbe_poll
      4.98%  [kernel]       [k] netif_receive_skb_internal
      2.90%  [kernel]       [k] __build_skb
      2.82%  [kernel]       [k] ipt_do_table
      2.44%  [kernel]       [k] ixgbe_xmit_frame_ring
      2.42%  [kernel]       [k] ip_rcv
      2.31%  [kernel]       [k] get_rps_cpu
      1.98%  [kernel]       [k] ip_finish_output2
      1.87%  [kernel]       [k] __dev_queue_xmit
      1.82%  [kernel]       [k] __netif_receive_skb_core
      1.57%  [kernel]       [k] ip_route_input_noref
      1.39%  [kernel]       [k] kmem_cache_alloc
      1.29%  [kernel]       [k] ip_forward
      1.27%  [kernel]       [k] irq_entries_start
      1.27%  [kernel]       [k] skb_release_data
      1.15%  [kernel]       [k] netif_skb_features
      1.14%  [kernel]       [k] sch_direct_xmit
      1.12%  [kernel]       [k] page_frag_free
      0.99%  [kernel]       [k] __local_bh_enable_ip
      0.78%  [kernel]       [k] dev_gro_receive
      0.77%  [kernel]       [k] fib_validate_source
      0.71%  [kernel]       [k] ip_rcv_finish
      0.71%  [kernel]       [k] get_dma_ops
      0.70%  [kernel]       [k] __netdev_pick_tx
      0.68%  [kernel]       [k] dev_hard_start_xmit
      0.66%  [kernel]       [k] deliver_ptype_list_skb
      0.52%  [kernel]       [k] ixgbe_alloc_rx_buffers
      0.51%  [kernel]       [k] netdev_pick_tx
      0.48%  [kernel]       [k] cpuidle_enter_state
      0.48%  [kernel]       [k] eth_type_trans
      0.47%  [kernel]       [k] nf_hook_slow
      0.46%  [kernel]       [k] build_skb
      0.44%  [kernel]       [k] is_swiotlb_buffer






And now I will enable simple 10Gbit queue on TX device:

RX NIC:

7: enp216s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state 
UP mode DEFAULT group default qlen 8192
     link/ether 0c:c4:7a:ea:21:44 brd ff:ff:ff:ff:ff:ff

TX NIC

8: enp216s0f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state 
UP mode DEFAULT group default qlen 8192
     link/ether 0c:c4:7a:ea:21:45 brd ff:ff:ff:ff:ff:ff


tc qdisc del dev enp216s0f1 root
tc qdisc add dev enp216s0f1 handle 1: root hfsc default 100
tc class add dev enp216s0f1 parent 1: classid 1:100 hfsc ls m2 20000Mbit 
ul m2 20000Mbit


bwm-ng v0.6.1 (probing every 0.500s), press 'h' for help
   input: /proc/net/dev type: rate
   \         iface                   Rx Tx                Total
==============================================================================
         enp24s0f3:           58.00 P/s             2.00 P/s            
60.00 P/s
                lo:            0.00 P/s             0.00 P/s             
0.00 P/s
        enp216s0f0:      1119744.00 P/s             0.00 P/s 1119744.00 P/s
        enp216s0f1:            0.00 P/s       1090710.00 P/s 1090710.00 P/s
------------------------------------------------------------------------------
             total:      1119802.00 P/s       1090712.00 P/s 2210514.00 P/s

Performance drops by almost 90%

from almost 10Mpps to only 1Mpps


perf top

    PerfTop:   51808 irqs/sec  kernel:99.7%  exact:  0.0% [4000Hz 
cycles],  (all, 56 CPUs)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

     69.02%  [kernel]       [k] queued_spin_lock_slowpath
      5.41%  [kernel]       [k] do_raw_spin_lock
      2.06%  [kernel]       [k] acpi_processor_ffh_cstate_enter
      1.73%  [kernel]       [k] qdisc_dequeue_head
      1.66%  [kernel]       [k] ip_finish_output2
      1.53%  [kernel]       [k] hfsc_enqueue
      1.21%  [kernel]       [k] __dev_queue_xmit
      1.05%  [kernel]       [k] ixgbe_poll
      1.03%  [kernel]       [k] netif_skb_features
      0.84%  [kernel]       [k] hfsc_dequeue
      0.79%  [kernel]       [k] fib_table_lookup
      0.76%  [kernel]       [k] hfsc_find_class
      0.70%  [kernel]       [k] pfifo_enqueue
      0.63%  [kernel]       [k] sch_direct_xmit
      0.53%  [kernel]       [k] rb_first
      0.51%  [kernel]       [k] skb_release_data
      0.48%  [kernel]       [k] __page_frag_cache_drain
      0.44%  [kernel]       [k] ixgbe_xmit_frame_ring
      0.43%  [kernel]       [k] napi_consume_skb
      0.42%  [kernel]       [k] bstats_update
      0.37%  [kernel]       [k] __qdisc_run
      0.33%  [kernel]       [k] ipt_do_table
      0.32%  [kernel]       [k] __build_skb
      0.31%  [kernel]       [k] __rmqueue_smallest
      0.29%  [kernel]       [k] __free_one_page
      0.25%  [kernel]       [k] ip_rcv
      0.25%  [kernel]       [k] page_frag_free
      0.23%  [kernel]       [k] get_page_from_freelist
      0.21%  [kernel]       [k] __netif_receive_skb_core
      0.19%  [kernel]       [k] read_tsc
      0.17%  [kernel]       [k] kmem_cache_alloc
      0.15%  [kernel]       [k] ip_route_input_noref
      0.14%  [kernel]       [k] get_rps_cpu
      0.14%  [kernel]       [k] ip_forward
      0.13%  [kernel]       [k] update_vf.isra.10
      0.10%  [kernel]       [k] __slab_free



Other settings:

  ethtool -x enp216s0f1
RX flow hash indirection table for enp216s0f1 with 8 RX ring(s):
     0:      0     1     2     3     4     5     6     7
     8:      0     1     2     3     4     5     6     7
    16:      0     1     2     3     4     5     6     7
    24:      0     1     2     3     4     5     6     7
    32:      0     1     2     3     4     5     6     7
    40:      0     1     2     3     4     5     6     7
    48:      0     1     2     3     4     5     6     7
    56:      0     1     2     3     4     5     6     7
    64:      0     1     2     3     4     5     6     7
    72:      0     1     2     3     4     5     6     7
    80:      0     1     2     3     4     5     6     7
    88:      0     1     2     3     4     5     6     7
    96:      0     1     2     3     4     5     6     7
   104:      0     1     2     3     4     5     6     7
   112:      0     1     2     3     4     5     6     7
   120:      0     1     2     3     4     5     6     7
RSS hash key:
a6:f7:7c:d5:65:99:96:e3:8e:6c:eb:7c:68:1a:3b:02:40:b4:18:27:25:82:25:ba:fb:ba:ee:71:26:a3:f0:20:e4:db:6c:db:af:7e:c5:ee
RSS hash function:
     toeplitz: on
     xor: off
     crc32: off

ethtool -x enp216s0f0
RX flow hash indirection table for enp216s0f0 with 8 RX ring(s):
     0:      0     1     2     3     4     5     6     7
     8:      0     1     2     3     4     5     6     7
    16:      0     1     2     3     4     5     6     7
    24:      0     1     2     3     4     5     6     7
    32:      0     1     2     3     4     5     6     7
    40:      0     1     2     3     4     5     6     7
    48:      0     1     2     3     4     5     6     7
    56:      0     1     2     3     4     5     6     7
    64:      0     1     2     3     4     5     6     7
    72:      0     1     2     3     4     5     6     7
    80:      0     1     2     3     4     5     6     7
    88:      0     1     2     3     4     5     6     7
    96:      0     1     2     3     4     5     6     7
   104:      0     1     2     3     4     5     6     7
   112:      0     1     2     3     4     5     6     7
   120:      0     1     2     3     4     5     6     7
RSS hash key:
a6:f7:7c:d5:65:99:96:e3:8e:6c:eb:7c:68:1a:3b:02:40:b4:18:27:25:82:25:ba:fb:ba:ee:71:26:a3:f0:20:e4:db:6c:db:af:7e:c5:ee
RSS hash function:
     toeplitz: on
     xor: off
     crc32: off

for both NIC;s settings:

ifc='enp216s0f0 enp216s0f1'
for i in $ifc
         do
         ip link set up dev $i
         ethtool -A $i autoneg off rx off tx off
         ethtool -G $i rx 1024 tx 1024
         ip link set $i txqueuelen 8192
         ethtool -C $i rx-usecs 10
         ethtool -L $i combined 8
         ethtool -N $i rx-flow-hash udp4 sdfn
         ethtool -K $i ntuple on

         done

Some affinity + RPS

./set_irq_affinity.sh -x 48-55 enp216s0f0
./set_irq_affinity.sh -x 48-55 enp216s0f1


So the counters are really bad if queueing is enabled :)





Thanks

Paweł Staszewski
