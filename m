From: Cedric Gavage <cedric.gavage@unixtech.be>
Subject: Re: [Fwd: kernel 2.4.21]
Date: Wed, 23 Jul 2003 11:44:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F1E58EE.5010109@unixtech.be>
References: <1058634345.22000.2.camel@dhcp22.swansea.linux.org.uk>	<20030719191723.0821227f.davem@redhat.com>	<3F1E53F7.5000803@unixtech.be> <20030723023528.76b0f69c.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030723023528.76b0f69c.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Wed, 23 Jul 2003 11:23:03 +0200
> Cedric Gavage <cedric.gavage@unixtech.be> wrote:
> 
> 
>>Still this with 2.4.21 kernel: (intel internet card, driver eepro100)
>>
>>Jul 23 07:25:58 fazer kernel: recvmsg bug: copied 7CB284C0 seq 7CB288AE
>>Jul 23 07:25:58 fazer kernel: KERNEL: assertion (flags&MSG_PEEK) failed at tcp.c(1563)
> 
> 
> What interesting programs are you running on this system?
> 
> Are you running and old version of vsftpd?
> 

Thanks for your help...

This server is efnet.skynet.be, ircd server connected on EFnet with 
ircd-hybrid-6.4...

System is a Debian stable 3.0 aka woody (standard).

Here is the "cat /proc/version" output
Linux version 2.4.21-dell.poweredge.ppro.nosmp (root@localhost) (gcc 
version 2.95.4 20011002 (Debian prerelease)) #1 Sat Jul 19 16:13:28 CEST 
2003

Here is the "cat /proc/cpu" output:
fazer:/root# cat /proc/cpuinfo
processor       : 0
vendor_id       : GenuineIntel
cpu family      : 6
model           : 8
model name      : Pentium III (Coppermine)
stepping        : 6
cpu MHz         : 993.399
cache size      : 256 KB
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 2
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge 
mca cmov pat pse36 mmx fxsr sse
bogomips        : 1979.18


Here is the "cat /proc/meminfo" output:
fazer:/root# cat /proc/meminfo
         total:    used:    free:  shared: buffers:  cached:
Mem:  262762496 214491136 48271360        0  6619136 83787776
Swap: 995250176  1622016 993628160
MemTotal:       256604 kB
MemFree:         47140 kB
MemShared:           0 kB
Buffers:          6464 kB
Cached:          80888 kB
SwapCached:        936 kB
Active:          61152 kB
Inactive:       122056 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:       256604 kB
LowFree:         47140 kB
SwapTotal:      971924 kB
SwapFree:       970340 kB

Here is the "cat /proc/modules" output.
fazer:/root# cat /proc/modules
serial                 44160   0 (autoclean)
eepro100               18060   2
mii                     2480   0 [eepro100]



Here is the running process list.
fazer:/root# ps aux
USER       PID %CPU %MEM   VSZ  RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.1  1272  436 ?        S    Jul22   0:06 init [2]
root         2  0.0  0.0     0    0 ?        SW   Jul22   0:00 [keventd]
root         3  0.0  0.0     0    0 ?        SWN  Jul22   0:00 
[ksoftirqd_CPU0]
root         4  0.0  0.0     0    0 ?        SW   Jul22   0:00 [kswapd]
root         5  0.0  0.0     0    0 ?        SW   Jul22   0:00 [bdflush]
root         6  0.0  0.0     0    0 ?        SW   Jul22   0:00 [kupdated]
root         7  0.0  0.0     0    0 ?        SW   Jul22   0:00 [scsi_eh_0]
root         8  0.0  0.0     0    0 ?        SW   Jul22   0:00 [scsi_eh_1]
root       164  0.0  0.2  1340  556 ?        S    Jul22   1:39 /sbin/syslogd
root       167  0.0  0.4  2012 1188 ?        S    Jul22   0:00 /sbin/klogd
root       170  0.1  1.5  5340 4088 ?        S    Jul22   2:43 
/usr/sbin/named
root       187  0.0  0.1  1248  420 ?        S    Jul22   0:00 
/usr/sbin/inetd
root       190  0.0  0.3  5692  788 ?        S    Jul22   0:00 
/usr/sbin/ippl
root       192  0.0  0.3  5692  788 ?        S    Jul22   0:00 
/usr/sbin/ippl
nobody     193  0.0  0.3  5692  788 ?        S    Jul22   0:01 
/usr/sbin/ippl
nobody     194  1.3  0.3  5692  788 ?        R    Jul22  22:43 
/usr/sbin/ippl
ircd       197  0.6 33.8 111524 86980 ?      S    Jul22  10:53 
/usr/local/ircd-hybrid/ircd
smmsp      224  0.0  0.6  4988 1668 ?        S    Jul22   0:00 sendmail: 
MSP: Queue runner@00:10:0
root       228  0.0  0.8  3140 2100 ?        S    Jul22   0:15 
/usr/sbin/snmpd -s -l /dev/null
root       230  0.0  0.3  2016  860 ?        S    Jul22   0:00 
/usr/sbin/snmptrapd -s
root       236  0.0  0.3  2784 1016 ?        S    Jul22   0:00 
/usr/sbin/sshd
root       239  0.0  0.7  1976 1968 ?        SL   Jul22   0:00 
/usr/sbin/ntpd
daemon     242  0.0  0.2  1384  556 ?        S    Jul22   0:00 /usr/sbin/atd
root       245  0.0  0.2  1652  680 ?        S    Jul22   0:00 
/usr/sbin/cron
root       248  0.0  0.1  1256  412 tty1     S    Jul22   0:00 
/sbin/getty 38400 tty1
root       249  0.0  0.1  1256  412 tty2     S    Jul22   0:00 
/sbin/getty 38400 tty2
root       250  0.0  0.1  1256  412 tty3     S    Jul22   0:00 
/sbin/getty 38400 tty3
root       251  0.0  0.1  1256  412 tty4     S    Jul22   0:00 
/sbin/getty 38400 tty4
root       252  0.0  0.1  1256  412 tty5     S    Jul22   0:00 
/sbin/getty 38400 tty5
root       253  0.0  0.1  1256  412 tty6     S    Jul22   0:00 
/sbin/getty 38400 tty6
root       254  0.0  1.3  8292 3356 ?        S    Jul22   0:00 
/opt/tivoli/tsm/client/ba/bin/dsmc
root       255  0.0  1.3  8292 3356 ?        S    Jul22   0:00 
/opt/tivoli/tsm/client/ba/bin/dsmc
root       256  0.0  1.3  8292 3356 ?        S    Jul22   0:00 
/opt/tivoli/tsm/client/ba/bin/dsmc
root      3366  0.0  0.6  5732 1708 ?        S    11:37   0:00 
/usr/sbin/sshd
root      3368  0.0  0.5  2464 1332 pts/0    S    11:37   0:00 -bash
root      3394  7.0  0.6  5732 1708 ?        R    11:42   0:00 
/usr/sbin/sshd
root      3396  0.0  0.5  2456 1312 pts/1    S    11:42   0:00 -bash
root      3413  0.0  0.6  3544 1568 pts/1    R    11:42   0:00 ps aux

-- 
  Cedric Gavage <cedric.gavage@unixtech.be>
  http://unixtech.be - http://gavage.com - OpenPGP: 0xED325C64
