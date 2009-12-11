From: Kevin Constantine <kevin.constantine@gmail.com>
Subject: Re: Kernel Panics in the network stack
Date: Fri, 11 Dec 2009 14:16:45 -0800
Message-ID: <4B22C4CD.8010402@gmail.com>
References: <4B22B4F2.8080605@gmail.com> <4B22BC1F.607@gmail.com> <4B22BEAB.1080407@gmail.com> <4B22C075.2020902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f212.google.com ([209.85.217.212]:59540 "EHLO
	mail-gx0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758471AbZLKWQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 17:16:41 -0500
Received: by gxk4 with SMTP id 4so1585372gxk.8
        for <netdev@vger.kernel.org>; Fri, 11 Dec 2009 14:16:47 -0800 (PST)
In-Reply-To: <4B22C075.2020902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/11/2009 01:58 PM, Eric Dumazet wrote:
> Le 11/12/2009 22:50, Kevin Constantine a =E9crit :
>> On 12/11/2009 01:39 PM, Eric Dumazet wrote:
>>> Le 11/12/2009 22:09, Kevin Constantine a =E9crit :
>>>> Hey Everyone-
>>>>
>>>> I've been playing with an ARM based linuxstamp
>>>> http://opencircuits.com/Linuxstamp, and I've been seeing kernel pa=
nics
>>>> with both 2.6.28.3, and 2.6.30 within an hour or so of turning the
>>>> linuxstamp on.  The stack traces always seem to point at functions
>>>> related to networking.  I've pasted a couple of the crash outputs =
below.
>>>>    The linuxstamp isn't typically doing anything when the crashes =
occur,
>>>> in fact it'll crash even if I haven't logged in.
>>>>
>>>> If I ifconfig the interface down, the linuxstamp stays up indefini=
tely.
>>>>    Any pointers in one direction or another would be much apprecia=
ted.
>>>>
>>>> I'm not sure if this is the right audience to help out or if the a=
rm
>>>> lists might be better.  But in any event, any help would be really
>>>> appreciated.
>>>>
>>>>
>>>> linuxstamp login: Unable to handle kernel paging request at virtua=
l
>>>> address 183cb7b0
>>>> pgd =3D c0004000
>>>> [183cb7b0] *pgd=3D00000000
>>>> Internal error: Oops: 0 [#1] PREEMPT
>>>> Modules linked in:
>>>> CPU: 0    Not tainted  (2.6.30-00002-g0148992 #13)
>>>> PC is at 0x183cb7b0
>>>> LR is at __udp4_lib_rcv+0x43c/0x72c
>>>
>>> Could you disassemble your vmlinux file, __udp4_lib_rcv function
>>> around LR
>>> <c024ff4c>, to see which function was called ? This function then c=
alled
>>> a wrong pointer (0x183cb7b0 not a kernel pointer)
>>>
>>> Maybe a kernel stack corruption, or bad ram, ...
>>
>> The vmlinux file I'm using has probably changed a number of times si=
nce
>> then.  I'll get a fresh stack trace and disassemble that one.
>>
>> I've has this type of problem with several linuxstamps.  I'm only ab=
le
>> to trigger this panic when the linuxstamp is plugged into a cisco
>> catalyst gigabit switch.  Plugging it in at home into a consumer gra=
de
>> 10/100 switch, the linuxstamp stays up indefinitely.
>>
>> Also worth noting, I'm seeing the error counts in ifconfig increase
>> steadily.
>
> Could be an error in NIC driver error path, this is a good point.
>
>>
>> eth0      Link encap:Ethernet  HWaddr ac:de:48:00:00:01
>>            inet addr:172.30.194.255  Bcast:172.30.207.255 Mask:255.2=
55.240.0
>>            UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>>            RX packets:42492 errors:1442 dropped:0 overruns:6 frame:7=
84
>>            TX packets:1169 errors:0 dropped:0 overruns:0 carrier:0
>>            collisions:0 txqueuelen:1000
>>            RX bytes:3804651 (3.6 MiB)  TX bytes:106728 (104.2 KiB)
>>            Interrupt:24 Base address:0xc000
>>
>>
>
> Please give us more information, since this platform is not well know=
n :)
>
> lsmod
> cat /proc/meminfo

debian:~# cat /proc/meminfo
MemTotal:          28732 kB
MemFree:           10260 kB
Buffers:            2304 kB
Cached:             9220 kB
SwapCached:            0 kB
Active:             8964 kB
Inactive:           4796 kB
Active(anon):       2292 kB
Inactive(anon):        0 kB
Active(file):       6672 kB
Inactive(file):     4796 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:             0 kB
SwapFree:              0 kB
Dirty:                16 kB
Writeback:             0 kB
AnonPages:          2256 kB
Mapped:             3308 kB
Slab:               3876 kB
SReclaimable:       1508 kB
SUnreclaim:         2368 kB
PageTables:          156 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:       14364 kB
Committed_AS:      32372 kB
VmallocTotal:     989184 kB
VmallocUsed:        1136 kB
VmallocChunk:     986108 kB


> cat /proc/cpuinfo

debian:~# cat /proc/cpuinfo
Processor       : ARM920T rev 0 (v4l)
BogoMIPS        : 89.53
=46eatures        : swp half thumb
CPU implementer : 0x41
CPU architecture: 4T
CPU variant     : 0x1
CPU part        : 0x920
CPU revision    : 0

Hardware        : emQbit's ECB_AT91
Revision        : 0000
Serial          : 0000000000000000


> cat /proc/slabinfo  (after more than 2000 error count in ifconfig eth=
0)
debian:~# cat /proc/slabinfo=20

slabinfo - version: 2.1=20

# name            <active_objs> <num_objs> <objsize> <objperslab>=20
<pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdat=
a=20
<active_slabs> <num_slabs> <sharedavail>
rpc_buffers            8      8   2048    2    1 : tunables   24   12=20
  0 : slabdata      4      4      0=20

rpc_tasks              8     24    160   24    1 : tunables  120   60=20
  0 : slabdata      1      1      0=20

rpc_inode_cache        0      0    416    9    1 : tunables   54   27=20
  0 : slabdata      0      0      0=20

flow_cache             0      0     80   48    1 : tunables  120   60=20
  0 : slabdata      0      0      0=20

nfs_direct_cache       0      0     68   56    1 : tunables  120   60=20
  0 : slabdata      0      0      0=20

nfs_write_data        36     36    416    9    1 : tunables   54   27=20
  0 : slabdata      4      4      0=20

nfs_read_data         32     36    416    9    1 : tunables   54   27=20
  0 : slabdata      4      4      0=20

nfs_inode_cache        0      0    584    7    1 : tunables   54   27=20
  0 : slabdata      0      0      0=20

nfs_page               0      0     64   59    1 : tunables  120   60=20
  0 : slabdata      0      0      0=20

journal_handle         0      0     20  169    1 : tunables  120   60=20
  0 : slabdata      0      0      0=20

journal_head          14    126     60   63    1 : tunables  120   60=20
  0 : slabdata      2      2      0=20

revoke_table           2    254     12  254    1 : tunables  120   60=20
  0 : slabdata      1      1      0=20

revoke_record          0      0     16  203    1 : tunables  120   60=20
  0 : slabdata      0      0      0=20

ext2_inode_cache       0      0    416    9    1 : tunables   54   27=20
  0 : slabdata      0      0      0=20

ext3_inode_cache     443    450    432    9    1 : tunables   54   27=20
  0 : slabdata     50     50      0=20

ext3_xattr             0      0     44   84    1 : tunables  120   60=20
  0 : slabdata      0      0      0=20

reiser_inode_cache      0      0    368   10    1 : tunables   54   27=20
   0 : slabdata      0      0      0=20

configfs_dir_cache      0      0     52   72    1 : tunables  120   60=20
   0 : slabdata      0      0      0=20

kioctx                 0      0    160   24    1 : tunables  120   60=20
  0 : slabdata      0      0      0=20

kiocb                  0      0    160   24    1 : tunables  120   60=20
  0 : slabdata      0      0      0=20

inotify_event_cache      0      0     28  127    1 : tunables  120   60=
=20
    0 : slabdata      0      0      0=20

inotify_watch_cache      2     92     40   92    1 : tunables  120   60=
=20
    0 : slabdata      1      1      0=20

dnotify_cache          0      0     20  169    1 : tunables  120   60=20
  0 : slabdata      0      0      0=20

fasync_cache           0      0     16  203    1 : tunables  120   60=20
  0 : slabdata      0      0      0=20

shmem_inode_cache   2497   2500    392   10    1 : tunables   54   27=20
  0 : slabdata    250    250      0=20

nsproxy                0      0     24  145    1 : tunables  120   60=20
  0 : slabdata      0      0      0=20

posix_timers_cache      0      0    112   35    1 : tunables  120   60=20
   0 : slabdata      0      0      0=20

uid_cache              0      0     64   59    1 : tunables  120   60=20
  0 : slabdata      0      0      0=20

UNIX                   5     10    384   10    1 : tunables   54   27=20
  0 : slabdata      1      1      0=20

UDP-Lite               0      0    480    8    1 : tunables   54   27=20
  0 : slabdata      0      0      0=20

tcp_bind_bucket        1    113     32  113    1 : tunables  120   60=20
  0 : slabdata      1      1      0=20

inet_peer_cache        0      0     64   59    1 : tunables  120   60=20
  0 : slabdata      0      0      0=20

secpath_cache          0      0     32  113    1 : tunables  120   60=20
  0 : slabdata      0      0      0=20

xfrm_dst_cache         0      0    288   13    1 : tunables   54   27=20
  0 : slabdata      0      0      0=20

ip_fib_alias           0      0     16  203    1 : tunables  120   60=20
  0 : slabdata      0      0      0=20

ip_fib_hash            9    101     36  101    1 : tunables  120   60=20
  0 : slabdata      1      1      0=20

ip_dst_cache         388    435    256   15    1 : tunables  120   60=20
  0 : slabdata     29     29      0=20

arp_cache              1     30    128   30    1 : tunables  120   60=20
  0 : slabdata      1      1      0=20

RAW                    2      9    448    9    1 : tunables   54   27=20
  0 : slabdata      1      1      0=20

UDP                    1      8    480    8    1 : tunables   54   27=20
  0 : slabdata      1      1      0=20

tw_sock_TCP            0      0     96   40    1 : tunables  120   60=20
  0 : slabdata      0      0      0=20

request_sock_TCP       0      0     96   40    1 : tunables  120   60=20
  0 : slabdata      0      0      0=20

TCP                    2      3   1056    3    1 : tunables   24   12=20
  0 : slabdata      1      1      0=20

eventpoll_pwq          0      0     36  101    1 : tunables  120   60=20
  0 : slabdata      0      0      0=20

eventpoll_epi          0      0     96   40    1 : tunables  120   60=20
  0 : slabdata      0      0      0=20

sgpool-128             2      2   2048    2    1 : tunables   24   12=20
  0 : slabdata      1      1      0=20

sgpool-64              2      4   1024    4    1 : tunables   54   27=20
  0 : slabdata      1      1      0=20

sgpool-32              2      8    512    8    1 : tunables   54   27=20
  0 : slabdata      1      1      0=20

sgpool-16              2     15    256   15    1 : tunables  120   60=20
  0 : slabdata      1      1      0=20

sgpool-8               2     30    128   30    1 : tunables  120   60=20
  0 : slabdata      1      1      0
scsi_data_buffer       0      0     20  169    1 : tunables  120   60=20
  0 : slabdata      0      0      0
blkdev_queue          10     12   1216    3    1 : tunables   24   12=20
  0 : slabdata      4      4      0
blkdev_requests        8     18    216   18    1 : tunables  120   60=20
  0 : slabdata      1      1      0
blkdev_ioc            10     84     44   84    1 : tunables  120   60=20
  0 : slabdata      1      1      0
bio-0                  2     30    128   30    1 : tunables  120   60=20
  0 : slabdata      1      1      0
biovec-256             2      2   3072    1    1 : tunables   24   12=20
  0 : slabdata      2      2      0
biovec-128             0      0   1536    2    1 : tunables   24   12=20
  0 : slabdata      0      0      0
biovec-64              0      0    768    5    1 : tunables   54   27=20
  0 : slabdata      0      0      0
biovec-16              0      0    192   20    1 : tunables  120   60=20
  0 : slabdata      0      0      0
sock_inode_cache      18     22    352   11    1 : tunables   54   27=20
  0 : slabdata      2      2      0
skbuff_fclone_cache     11     11    352   11    1 : tunables   54   27=
=20
    0 : slabdata      1      1      0
skbuff_head_cache    100    180    192   20    1 : tunables  120   60=20
  0 : slabdata      9      9      0
file_lock_cache        1     40     96   40    1 : tunables  120   60=20
  0 : slabdata      1      1      0
proc_inode_cache     132    132    320   12    1 : tunables   54   27=20
  0 : slabdata     11     11      0
sigqueue               1     27    144   27    1 : tunables  120   60=20
  0 : slabdata      1      1      0
radix_tree_node      289    299    288   13    1 : tunables   54   27=20
  0 : slabdata     23     23      0
bdev_cache             3      9    416    9    1 : tunables   54   27=20
  0 : slabdata      1      1      0
sysfs_dir_cache     3902   3948     44   84    1 : tunables  120   60=20
  0 : slabdata     47     47      0
mnt_cache             20     30    128   30    1 : tunables  120   60=20
  0 : slabdata      1      1      0
filp                 210    210    128   30    1 : tunables  120   60=20
  0 : slabdata      7      7      0
inode_cache         1560   1560    296   13    1 : tunables   54   27=20
  0 : slabdata    120    120      0
dentry              4829   4830    128   30    1 : tunables  120   60=20
  0 : slabdata    161    161      0
names_cache            1      1   4096    1    1 : tunables   24   12=20
  0 : slabdata      1      1      0
buffer_head          614    648     52   72    1 : tunables  120   60=20
  0 : slabdata      9      9      0
vm_area_struct       631    644     84   46    1 : tunables  120   60=20
  0 : slabdata     14     14      0
mm_struct             20     20    384   10    1 : tunables   54   27=20
  0 : slabdata      2      2      0
fs_cache              10    113     32  113    1 : tunables  120   60=20
  0 : slabdata      1      1      0
files_cache           11     40    192   20    1 : tunables  120   60=20
  0 : slabdata      2      2      0
signal_cache          45     45    448    9    1 : tunables   54   27=20
  0 : slabdata      5      5      0
sighand_cache         36     36   1312    3    1 : tunables   24   12=20
  0 : slabdata     12     12      0
task_struct           40     40    768    5    1 : tunables   54   27=20
  0 : slabdata      8      8      0
cred_jar              56    120     96   40    1 : tunables  120   60=20
  0 : slabdata      3      3      0
anon_vma             265    339      8  339    1 : tunables  120   60=20
  0 : slabdata      1      1      0
pid                   35     59     64   59    1 : tunables  120   60=20
  0 : slabdata      1      1      0
idr_layer_cache      127    130    148   26    1 : tunables  120   60=20
  0 : slabdata      5      5      0
size-4194304           0      0 4194304    1 1024 : tunables    1    1=20
   0 : slabdata      0      0      0
size-2097152           0      0 2097152    1  512 : tunables    1    1=20
   0 : slabdata      0      0      0
size-1048576           0      0 1048576    1  256 : tunables    1    1=20
   0 : slabdata      0      0      0
size-524288            0      0 524288    1  128 : tunables    1    1=20
  0 : slabdata      0      0      0
size-262144            0      0 262144    1   64 : tunables    1    1=20
  0 : slabdata      0      0      0
size-131072            0      0 131072    1   32 : tunables    8    4=20
  0 : slabdata      0      0      0
size-65536             0      0  65536    1   16 : tunables    8    4=20
  0 : slabdata      0      0      0
size-32768             0      0  32768    1    8 : tunables    8    4=20
  0 : slabdata      0      0      0
size-16384             0      0  16384    1    4 : tunables    8    4=20
  0 : slabdata      0      0      0
size-8192              0      0   8192    1    2 : tunables    8    4=20
  0 : slabdata      0      0      0
size-4096              4      4   4096    1    1 : tunables   24   12=20
  0 : slabdata      4      4      0
size-2048             14     14   2048    2    1 : tunables   24   12=20
  0 : slabdata      7      7      0
size-1024             40     40   1024    4    1 : tunables   54   27=20
  0 : slabdata     10     10      0
size-512             173    200    512    8    1 : tunables   54   27=20
  0 : slabdata     25     25      0
size-256              75     75    256   15    1 : tunables  120   60=20
  0 : slabdata      5      5      0
size-192             669    680    192   20    1 : tunables  120   60=20
  0 : slabdata     34     34      0
size-128             240    240    128   30    1 : tunables  120   60=20
  0 : slabdata      8      8      0
size-96              919    920     96   40    1 : tunables  120   60=20
  0 : slabdata     23     23      0
size-64              590    590     64   59    1 : tunables  120   60=20
  0 : slabdata     10     10      0
size-32             3374   3390     32  113    1 : tunables  120   60=20
  0 : slabdata     30     30      0
kmem_cache           105    120     96   40    1 : tunables  120   60=20
  0 : slabdata      3      3      0
> ...
debian:~# dmesg=20
=20

Linux version 2.6.30-00002-g0148992 (kconstan@debian) (gcc version 4.3.=
2=20
(Debian 4.3.2-1.1) ) #16 PREEMPT Fri Dec 11 13:48:45 PST 2009=20

CPU: ARM920T [41129200] revision 0 (ARMv4T), cr=3Dc0007177=20
=20

CPU: VIVT data cache, VIVT instruction cache=20
=20

Machine: emQbit's ECB_AT91=20
=20

Memory policy: ECC disabled, Data cache writeback=20
=20

On node 0 totalpages: 8192=20
=20

free_area_init_node: node 0, pgdat c03a3340, node_mem_map c03c3000=20
=20

   Normal zone: 64 pages used for memmap=20
=20

   Normal zone: 0 pages reserved=20
=20

   Normal zone: 8128 pages, LIFO batch:0=20
=20

Clocks: CPU 179 MHz, master 59 MHz, main 18.432 MHz=20
=20

Built 1 zonelists in Zone order, mobility grouping on.  Total pages:=20
8128=20

Kernel command line: mem=3D32M root=3D/dev/mmcblk0p1 ip=3D192.168.0.51=20
console=3DttyS0,115200n8 rootdelay=3D4=20

NR_IRQS:192=20
=20

AT91: 96 gpio irqs in 3 banks
=2E..
eth0: Link now 100-FullDuplex
eth0: AT91 ethernet at 0xfefbc000 int=3D24 100-FullDuplex (00:00:00:00:=
00:5b)
eth0: Micrel KS8721 PHY
ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver

-kevin
