From: Anand Raj Manickam <anandrm@gmail.com>
Subject: Re: Kernel Panic on OOM with 10 HTB rules
Date: Wed, 8 Sep 2010 19:39:58 +0530
Message-ID: <AANLkTimDW-tuTJagnpkFq3TX4t+c_-9UUyG8z-bwPuJ1@mail.gmail.com>
References: <AANLkTinQbuN4Y6yUgHhjhOkLGe3GPk9aN5z1gasvQ-zW@mail.gmail.com>
	<1283949778.2748.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	shemminger@vyatta.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1283949778.2748.5.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please find the info below  ... its a long list though

On Wed, Sep 8, 2010 at 6:12 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le mercredi 08 septembre 2010 =E0 16:22 +0530, Anand Raj Manickam a
> =E9crit :
>> Hi,
>>
>> I m struck with
>> Kernel Panic - Out of Memory Issue =A0when =A0traffic =A0is more tha=
n 100k
>> pps =A0and have =A0around 10 tc rules.
>>
>> There is NO kernel panic with 1 tc rule .
>>
>> I using a 2.6.34.6 ( latest stable kernel) with SMP enabled
>>
>> The rules are simple -
>> 10 iptable rules :
>> iptables -t mangle -I FORWARD -s x.x.x.x =A0-j CLASSIFY --set-class =
0xz:0xy
>>
>> 10 tc rules :
>> tc =A0class add dev imq0 parent 1:z classid 1:y htb rate 2kbit ceil =
32768kbps
>>
>> I m using =A0Intel Xeon Quad core x5570, 12GB RAM , with 8 e1000e , =
irq
>> affined ( 1 pair per core)
>>
>> There is NO issue / CRASH with multiple iptable rules marking to the
>> same tc rule/HTB class , i can sucessfully pass more than 200k pps /
>> 800Mbps traffic .
>>
>> But when each iptable rule is marking to seprate tc rule/HTB class a=
nd
>> when the traffic exceeds 100K pps / 20000 connections per second , w=
e
>> hit this Out of Memory - Kernel panic condition .
>> Any help is appreciated . Do let me know if any more further
>> information is need.
>
> Hi Anand
>
> Could you give :
>
> 1) A complete stack trace / panic report

Sorry there was no stack trace :-(


e5570#Out of memory: kill process 10240 (apache2) score 58700 or a chil=
d
Killed process 10240 (apache2) vsz:234800kB, anon-rss:1576kB, file-rss:=
1212kB
Out of memory: kill process 10241 (apache2) score 58700 or a child
Killed process 10241 (apache2) vsz:234800kB, anon-rss:1576kB, file-rss:=
1232kB
Out of memory: kill process 16120 (java) score 19383 or a child
Killed process 16120 (java) vsz:1240516kB, anon-rss:161428kB, file-rss:=
7516kB
Out of memory: kill process 2185 (mysqld) score 16377 or a child
Killed process 2185 (mysqld) vsz:131020kB, anon-rss:15392kB, file-rss:5=
144kB
Out of memory: kill process 10238 (apache2) score 3630 or a child
Killed process 21304 (tcstat_total.cg) vsz:2848kB, anon-rss:192kB,
file-rss:1016kB
Out of memory: kill process 10238 (apache2) score 3273 or a child
Killed process 10238 (apache2) vsz:13092kB, anon-rss:1408kB, file-rss:6=
24kB
Out of memory: kill process 21315 (tcstat_total.cg) score 712 or a chil=
d
Killed process 21315 (tcstat_total.cg) vsz:2848kB, anon-rss:192kB,
file-rss:196kB
Out of memory: kill process 1983 (rsyslogd) score 449 or a child
Killed process 1983 (rsyslogd) vsz:28744kB, anon-rss:784kB, file-rss:91=
2kB
Out of memory: kill process 10236 (apache2) score 208 or a child
Killed process 10236 (apache2) vsz:13320kB, anon-rss:1412kB, file-rss:1=
332kB
Out of memory: kill process 4051 (login) score 77 or a child
Killed process 4831 (bash) vsz:4556kB, anon-rss:396kB, file-rss:1336kB
Out of memory: kill process 2728 (cron) score 58 or a child
Killed process 2728 (cron) vsz:3716kB, anon-rss:156kB, file-rss:628kB
Out of memory: kill process 2068 (mysqld_safe) score 45 or a child
Killed process 2068 (mysqld_safe) vsz:2904kB, anon-rss:248kB, file-rss:=
1084kB
Out of memory: kill process 4051 (login) score 41 or a child
Killed process 4051 (login) vsz:2680kB, anon-rss:252kB, file-rss:948kB
Out of memory: kill process 2313 (inetd) score 31 or a child
Killed process 2313 (inetd) vsz:2004kB, anon-rss:92kB, file-rss:496kB
Out of memory: kill process 4045 (getty) score 28 or a child
Killed process 4045 (getty) vsz:1816kB, anon-rss:68kB, file-rss:400kB
Out of memory: kill process 4046 (getty) score 28 or a child
Killed process 4046 (getty) vsz:1816kB, anon-rss:72kB, file-rss:400kB
Out of memory: kill process 4047 (getty) score 28 or a child
Killed process 4047 (getty) vsz:1816kB, anon-rss:72kB, file-rss:400kB
Out of memory: kill process 4048 (getty) score 28 or a child
Killed process 4048 (getty) vsz:1816kB, anon-rss:72kB, file-rss:400kB
Out of memory: kill process 4049 (getty) score 28 or a child
Killed process 4049 (getty) vsz:1816kB, anon-rss:68kB, file-rss:400kB
Out of memory: kill process 4050 (getty) score 28 or a child
Killed process 4050 (getty) vsz:1816kB, anon-rss:68kB, file-rss:400kB
Kernel panic - not syncing: Out of memory and no killable processes...


> 2) cat /proc/interrupts

           CPU0       CPU1       CPU2       CPU3
  0:        250          0          0          0   IO-APIC-edge      ti=
mer
  1:          0          0          0          2   IO-APIC-edge      i8=
042
  2:          0          0          0          0    XT-PIC-XT        ca=
scade
  4:          0          0          0        226   IO-APIC-edge      se=
rial
  8:          0          0          0          2   IO-APIC-edge      rt=
c0
 12:          0          0          0          3   IO-APIC-edge      i8=
042
 19:          0      10673          0          0   IO-APIC-fasteoi   at=
a_piix
 33:          0          0          0          0   PCI-MSI-edge      pc=
iehp
 34:          0          0          0          0   PCI-MSI-edge      pc=
iehp
 35:          0          0          0          1   PCI-MSI-edge      pc=
iehp
 36:          1          0          0          0   PCI-MSI-edge      pc=
iehp
 37:          1          0          0          0   PCI-MSI-edge      pc=
iehp
 38:          0          1          0          0   PCI-MSI-edge      pc=
iehp
 39:         94          0          0          0   PCI-MSI-edge      et=
h0
 40:         88          6          0          0   PCI-MSI-edge      et=
h1
 41:          0         88          6          0   PCI-MSI-edge      et=
h2
 42:          0         88          6          0   PCI-MSI-edge      et=
h3
 43:          0          0         92          0   PCI-MSI-edge      et=
h4-rx-0
 44:          0          0          0          0   PCI-MSI-edge      et=
h4-tx-0
 45:          3          0          0          0   PCI-MSI-edge      et=
h4
 46:          0          4         88          0   PCI-MSI-edge      et=
h5-rx-0
 47:          0          0          0          0   PCI-MSI-edge      et=
h5-tx-0
 48:          0          0          3          0   PCI-MSI-edge      et=
h5
 49:          0          0          4         88   PCI-MSI-edge      et=
h6-rx-0
 50:          0          0          0          0   PCI-MSI-edge      et=
h6-tx-0
 51:          0          0          0          3   PCI-MSI-edge      et=
h6
 52:          4          0          0         88   PCI-MSI-edge      et=
h7-rx-0
 53:          0          0          0          0   PCI-MSI-edge      et=
h7-tx-0
 54:          0          3          0          0   PCI-MSI-edge      et=
h7
NMI:          0          0          0          0   Non-maskable interru=
pts
LOC:     196962     205933     209322     208530   Local timer interrup=
ts
SPU:          0          0          0          0   Spurious interrupts
PMI:          0          0          0          0   Performance
monitoring interrupts
PND:          0          0          0          0   Performance pending =
work
RES:       4866        761        416        467   Rescheduling interru=
pts
CAL:         39        102        107        109   Function call interr=
upts
TLB:       6019       5481       4678       6759   TLB shootdowns
TRM:          0          0          0          0   Thermal event interr=
upts
THR:          0          0          0          0   Threshold APIC inter=
rupts
MCE:          0          0          0          0   Machine check except=
ions
MCP:          2          2          2          2   Machine check polls
ERR:          3
MIS:          0



> 3) ifconfig -a
br0       Link encap:Ethernet  HWaddr 00:90:0b:14:ac:38
          inet addr:192.168.164.222  Bcast:192.168.167.255  Mask:255.25=
5.252.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:50 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:2300 (2.2 KiB)  TX bytes:0 (0.0 B)

eth0      Link encap:Ethernet  HWaddr 00:90:0b:14:ac:38
          UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
          RX packets:10119 errors:0 dropped:0 overruns:0 frame:0
          TX packets:20075 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:6654384 (6.3 MiB)  TX bytes:1427890 (1.3 MiB)
          Memory:fb580000-fb5a0000

eth1      Link encap:Ethernet  HWaddr 00:90:0b:14:ac:39
          UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
          RX packets:20039 errors:0 dropped:0 overruns:0 frame:0
          TX packets:10155 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1495356 (1.4 MiB)  TX bytes:6646438 (6.3 MiB)
          Memory:fb5e0000-fb600000

eth2      Link encap:Ethernet  HWaddr 00:90:0b:14:ac:3a
          UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
          RX packets:19190 errors:0 dropped:0 overruns:0 frame:0
          TX packets:9727 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1432004 (1.3 MiB)  TX bytes:6365028 (6.0 MiB)
          Memory:fb680000-fb6a0000

eth3      Link encap:Ethernet  HWaddr 00:90:0b:14:ac:3b
          UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
          RX packets:9689 errors:0 dropped:0 overruns:0 frame:0
          TX packets:19228 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:6372426 (6.0 MiB)  TX bytes:1367600 (1.3 MiB)
          Memory:fb6e0000-fb700000
eth4      Link encap:Ethernet  HWaddr 00:90:0b:15:79:18
          UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
          RX packets:9252 errors:0 dropped:0 overruns:0 frame:0
          TX packets:18354 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:6085260 (5.8 MiB)  TX bytes:1305576 (1.2 MiB)
          Memory:fb8e0000-fb900000

eth5      Link encap:Ethernet  HWaddr 00:90:0b:15:79:19
          UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
          RX packets:18316 errors:0 dropped:0 overruns:0 frame:0
          TX packets:9290 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1366920 (1.3 MiB)  TX bytes:6078300 (5.7 MiB)
          Memory:fb9e0000-fba00000

eth6      Link encap:Ethernet  HWaddr 00:90:0b:15:79:1a
          UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
          RX packets:18709 errors:0 dropped:0 overruns:0 frame:0
          TX packets:9484 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1396126 (1.3 MiB)  TX bytes:6204656 (5.9 MiB)
          Memory:fbae0000-fbb00000

eth7      Link encap:Ethernet  HWaddr 00:90:0b:15:79:1b
          UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
          RX packets:9446 errors:0 dropped:0 overruns:0 frame:0
          TX packets:18746 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:6211812 (5.9 MiB)  TX bytes:1333280 (1.2 MiB)
          Memory:fbbe0000-fbc00000

imq0      Link encap:UNSPEC  HWaddr
00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
          UP RUNNING NOARP  MTU:16000  Metric:1
          RX packets:129112 errors:0 dropped:0 overruns:0 frame:0
          TX packets:129114 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:11000
          RX bytes:31060964 (29.6 MiB)  TX bytes:31062207 (29.6 MiB)

imq1      Link encap:UNSPEC  HWaddr
00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
          NOARP  MTU:16000  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:11000
 RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

imq2      Link encap:UNSPEC  HWaddr
00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
          NOARP  MTU:16000  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:11000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

imq3      Link encap:UNSPEC  HWaddr
00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
          NOARP  MTU:16000  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:11000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

imq4      Link encap:UNSPEC  HWaddr
00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
          NOARP  MTU:16000  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:11000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

imq5      Link encap:UNSPEC  HWaddr
00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
          NOARP  MTU:16000  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:11000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

imq6      Link encap:UNSPEC  HWaddr
00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
          NOARP  MTU:16000  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:11000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
imq7      Link encap:UNSPEC  HWaddr
00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00
          NOARP  MTU:16000  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:11000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:14454 errors:0 dropped:0 overruns:0 frame:0
          TX packets:14454 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:1962561 (1.8 MiB)  TX bytes:1962561 (1.8 MiB)



> 4) cat /proc/sys/vm/min_free_kbytes
3806

> 5) cat /proc/meminfo

MemTotal:       12462064 kB
MemFree:        12265628 kB
Buffers:           29672 kB
Cached:            64800 kB
SwapCached:            0 kB
Active:            87748 kB
Inactive:          75756 kB
Active(anon):      69040 kB
Inactive(anon):      288 kB
Active(file):      18708 kB
Inactive(file):    75468 kB
Unevictable:           0 kB
Mlocked:               0 kB
HighTotal:      11660872 kB
HighFree:       11515792 kB
LowTotal:         801192 kB
LowFree:          749836 kB
SwapTotal:      27226684 kB
SwapFree:       27226684 kB
Dirty:               120 kB
Writeback:             0 kB
AnonPages:         69032 kB
Mapped:            14508 kB
Shmem:               296 kB
Slab:              15728 kB
SReclaimable:       6044 kB
SUnreclaim:         9684 kB
KernelStack:        1376 kB
PageTables:          996 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:    33457716 kB
Committed_AS:     848336 kB
VmallocTotal:     122880 kB
VmallocUsed:        9468 kB
VmallocChunk:     106708 kB
DirectMap4k:        6136 kB
DirectMap2M:      907264 kB


> for each eth*
> =A0ethtool -g eth*

e5570#ethtool -g eth0 - eth7 ( have the same config)
Ring parameters for eth0:
Pre-set maximums:
RX:             4096
RX Mini:        0
RX Jumbo:       0
TX:             4096
Current hardware settings:
RX:             256
RX Mini:        0
RX Jumbo:       0
TX:             256
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
