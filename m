From: Christian Daniel <cd@cdaniel.de>
Subject: "dst cache overflow"
Date: Mon, 20 Sep 2004 19:07:43 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409201907.43317.cd@cdaniel.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello everybody,

I'm running Linux 2.6.8.1+pom20040621+imq+... as a firewall and router on=
 a=20
2MBit/s leased line to our ISP. After about 24 hours I get loads of "dst=20
cache overflow" messages and extreme packet loss occurs on all routed=20
connections - bridges continue to work.

Sep 20 15:23:05 sylvaner kernel: printk: 717 messages suppressed.
Sep 20 15:23:05 sylvaner kernel: dst cache overflow
Sep 20 15:23:10 sylvaner kernel: printk: 720 messages suppressed.
Sep 20 15:23:10 sylvaner kernel: dst cache overflow
Sep 20 15:23:15 sylvaner kernel: printk: 767 messages suppressed.
Sep 20 15:23:15 sylvaner kernel: dst cache overflow

rtstat over several hours:
 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot  =
   mc=20
GC:tot ignore gmiss dstof HLS:in    out
10501       593     339     0     0     0     0     0       250      24  =
    0
   362    360     2     0    229     48
10483       541     337     0     0     0     0     0       247      27  =
    0   =20
   363    361     2     0    183     72
10491       639     400     0     0     1     0     0       275      39  =
    0   =20
   437    435     2     0    245     81
10529       649     385     0     0     0     0     0       276      28  =
    0   =20
   413    411     2     0    264     71
10515       619     417     0     0     1     0     0       256      20  =
    0   =20
   335    333     2     0    257     93
10496       474     293     0     0     0     0     0       194      20  =
    0   =20
   311    309     2     0    193     60
[... after about four hours]
15032       729     441     0     0     0     0     0       365      31  =
    0   =20
   471    469     2     0    268    102
15034       804     439     0     0     0     0     0       400      11  =
    0   =20
   448    446     2     0    247    128
15054       593     411     0     0     0     0     0       321      25  =
    0   =20
   434    432     2     0    213     95
15016       826     361     0     0     0     0     0       393      12  =
    0   =20
   371    369     2     0    235     84
15068      1011     498     0     0     0     0     0       444      13  =
    0   =20
   429    427     2     0    293    110

(I modified rtstat to display garbage-collection statistics as well - pat=
ch is=20
submitted to iproute2 maintainer)

Latest Slabinfo looks like this:
slabinfo - version: 2.0
# name            <active_objs> <num_objs> <objsize> <objperslab>=20
<pagesperslab> : tunables <batchcount> <limit> <sharedfactor> : slabdata=20
<active_slabs> <num_slabs> <sharedavail>
ip_conntrack_expect      7     62    128   31    1 : tunables  120   60  =
  0 :=20
slabdata      2      2      0
ip_conntrack        6132   9096    320   12    1 : tunables   54   27    =
0 :=20
slabdata    758    758      0
ip_fib_hash          125    226     16  226    1 : tunables  120   60    =
0 :=20
slabdata      1      1      0
bridge_fdb_cache      31     61     64   61    1 : tunables  120   60    =
0 :=20
slabdata      1      1      0
uhci_urb_priv          0      0     44   88    1 : tunables  120   60    =
0 :=20
slabdata      0      0      0
unix_sock            164    200    384   10    1 : tunables   54   27    =
0 :=20
slabdata     20     20      0
tcp_tw_bucket          8     41     96   41    1 : tunables  120   60    =
0 :=20
slabdata      1      1      0
tcp_bind_bucket       10    226     16  226    1 : tunables  120   60    =
0 :=20
slabdata      1      1      0
tcp_open_request       0      0     64   61    1 : tunables  120   60    =
0 :=20
slabdata      0      0      0
inet_peer_cache      214    305     64   61    1 : tunables  120   60    =
0 :=20
slabdata      5      5      0
secpath_cache          0      0    128   31    1 : tunables  120   60    =
0 :=20
slabdata      0      0      0
xfrm_dst_cache         0      0    256   15    1 : tunables  120   60    =
0 :=20
slabdata      0      0      0
ip_dst_cache       15300  15420    256   15    1 : tunables  120   60    =
0 :=20
slabdata   1028   1028      0
arp_cache            294    341    128   31    1 : tunables  120   60    =
0 :=20
slabdata     11     11      0
raw4_sock              0      0    480    8    1 : tunables   54   27    =
0 :=20
slabdata      0      0      0
udp_sock               8      8    480    8    1 : tunables   54   27    =
0 :=20
slabdata      1      1      0
tcp_sock             125    152   1024    4    1 : tunables   54   27    =
0 :=20
slabdata     38     38      0
flow_cache             0      0     96   41    1 : tunables  120   60    =
0 :=20
slabdata      0      0      0
journal_handle        61    135     28  135    1 : tunables  120   60    =
0 :=20
slabdata      1      1      0
journal_head          29    162     48   81    1 : tunables  120   60    =
0 :=20
slabdata      2      2      0
revoke_table           6    290     12  290    1 : tunables  120   60    =
0 :=20
slabdata      1      1      0
revoke_record          0      0     16  226    1 : tunables  120   60    =
0 :=20
slabdata      0      0      0
ext3_inode_cache   47326  49473    448    9    1 : tunables   54   27    =
0 :=20
slabdata   5497   5497      0
ext3_xattr             0      0     44   88    1 : tunables  120   60    =
0 :=20
slabdata      0      0      0
eventpoll_pwq          0      0     36  107    1 : tunables  120   60    =
0 :=20
slabdata      0      0      0
eventpoll_epi          0      0     96   41    1 : tunables  120   60    =
0 :=20
slabdata      0      0      0
kioctx                 0      0    160   25    1 : tunables  120   60    =
0 :=20
slabdata      0      0      0
kiocb                  0      0     96   41    1 : tunables  120   60    =
0 :=20
slabdata      0      0      0
dnotify_cache          0      0     20  185    1 : tunables  120   60    =
0 :=20
slabdata      0      0      0
file_lock_cache       38     86     92   43    1 : tunables  120   60    =
0 :=20
slabdata      2      2      0
fasync_cache           0      0     16  226    1 : tunables  120   60    =
0 :=20
slabdata      0      0      0
shmem_inode_cache      8     20    384   10    1 : tunables   54   27    =
0 :=20
slabdata      2      2      0
posix_timers_cache      0      0     96   41    1 : tunables  120   60   =
 0 :=20
slabdata      0      0      0
uid_cache              2    119     32  119    1 : tunables  120   60    =
0 :=20
slabdata      1      1      0
cfq_pool              64    119     32  119    1 : tunables  120   60    =
0 :=20
slabdata      1      1      0
crq_pool               0      0     36  107    1 : tunables  120   60    =
0 :=20
slabdata      0      0      0
deadline_drq           0      0     48   81    1 : tunables  120   60    =
0 :=20
slabdata      0      0      0
as_arq                17     65     60   65    1 : tunables  120   60    =
0 :=20
slabdata      1      1      0
blkdev_ioc            22    185     20  185    1 : tunables  120   60    =
0 :=20
slabdata      1      1      0
blkdev_queue           1      9    448    9    1 : tunables   54   27    =
0 :=20
slabdata      1      1      0
blkdev_requests        8     26    152   26    1 : tunables  120   60    =
0 :=20
slabdata      1      1      0
biovec-(256)         256    256   3072    2    2 : tunables   24   12    =
0 :=20
slabdata    128    128      0
biovec-128           256    260   1536    5    2 : tunables   24   12    =
0 :=20
slabdata     52     52      0
biovec-64            256    260    768    5    1 : tunables   54   27    =
0 :=20
slabdata     52     52      0
biovec-16            256    260    192   20    1 : tunables  120   60    =
0 :=20
slabdata     13     13      0
biovec-4             256    305     64   61    1 : tunables  120   60    =
0 :=20
slabdata      5      5      0
biovec-1             260    452     16  226    1 : tunables  120   60    =
0 :=20
slabdata      2      2      0
bio                  272    305     64   61    1 : tunables  120   60    =
0 :=20
slabdata      5      5      0
sock_inode_cache     305    352    352   11    1 : tunables   54   27    =
0 :=20
slabdata     32     32      0
skbuff_head_cache    760   1060    192   20    1 : tunables  120   60    =
0 :=20
slabdata     53     53      0
sock                   6     12    320   12    1 : tunables   54   27    =
0 :=20
slabdata      1      1      0
proc_inode_cache     889   1008    320   12    1 : tunables   54   27    =
0 :=20
slabdata     84     84      0
sigqueue               3     27    148   27    1 : tunables  120   60    =
0 :=20
slabdata      1      1      0
radix_tree_node     2361   5152    276   14    1 : tunables   54   27    =
0 :=20
slabdata    368    368      0
bdev_cache             6      9    416    9    1 : tunables   54   27    =
0 :=20
slabdata      1      1      0
mnt_cache             20     41     96   41    1 : tunables  120   60    =
0 :=20
slabdata      1      1      0
inode_cache         4306   4466    288   14    1 : tunables   54   27    =
0 :=20
slabdata    319    319      0
dentry_cache       47234  54376    140   28    1 : tunables  120   60    =
0 :=20
slabdata   1942   1942      0
filp                1382   1625    160   25    1 : tunables  120   60    =
0 :=20
slabdata     65     65      0
names_cache            1      1   4096    1    1 : tunables   24   12    =
0 :=20
slabdata      1      1      0
idr_layer_cache      112    145    136   29    1 : tunables  120   60    =
0 :=20
slabdata      5      5      0
buffer_head        17913  21141     48   81    1 : tunables  120   60    =
0 :=20
slabdata    261    261      0
mm_struct            133    133    512    7    1 : tunables   54   27    =
0 :=20
slabdata     19     19      0
vm_area_struct      2386   2914     84   47    1 : tunables  120   60    =
0 :=20
slabdata     62     62      0
fs_cache             107    238     32  119    1 : tunables  120   60    =
0 :=20
slabdata      2      2      0
files_cache          108    126    416    9    1 : tunables   54   27    =
0 :=20
slabdata     14     14      0
signal_cache         123    164     96   41    1 : tunables  120   60    =
0 :=20
slabdata      4      4      0
sighand_cache        120    129   1312    3    1 : tunables   24   12    =
0 :=20
slabdata     43     43      0
task_struct          124    145   1424    5    2 : tunables   24   12    =
0 :=20
slabdata     29     29      0
anon_vma            1286   1628      8  407    1 : tunables  120   60    =
0 :=20
slabdata      4      4      0
pgd                  109    109   4096    1    1 : tunables   24   12    =
0 :=20
slabdata    109    109      0
size-131072(DMA)       0      0 131072    1   32 : tunables    8    4    =
0 :=20
slabdata      0      0      0
size-131072            0      0 131072    1   32 : tunables    8    4    =
0 :=20
slabdata      0      0      0
size-65536(DMA)        0      0  65536    1   16 : tunables    8    4    =
0 :=20
slabdata      0      0      0
size-65536             0      0  65536    1   16 : tunables    8    4    =
0 :=20
slabdata      0      0      0
size-32768(DMA)        0      0  32768    1    8 : tunables    8    4    =
0 :=20
slabdata      0      0      0
size-32768             0      0  32768    1    8 : tunables    8    4    =
0 :=20
slabdata      0      0      0
size-16384(DMA)        0      0  16384    1    4 : tunables    8    4    =
0 :=20
slabdata      0      0      0
size-16384             0      0  16384    1    4 : tunables    8    4    =
0 :=20
slabdata      0      0      0
size-8192(DMA)         0      0   8192    1    2 : tunables    8    4    =
0 :=20
slabdata      0      0      0
size-8192            124    124   8192    1    2 : tunables    8    4    =
0 :=20
slabdata    124    124      0
size-4096(DMA)         0      0   4096    1    1 : tunables   24   12    =
0 :=20
slabdata      0      0      0
size-4096            115    115   4096    1    1 : tunables   24   12    =
0 :=20
slabdata    115    115      0
size-2048(DMA)         0      0   2048    2    1 : tunables   24   12    =
0 :=20
slabdata      0      0      0
size-2048            206    214   2048    2    1 : tunables   24   12    =
0 :=20
slabdata    107    107      0
size-1024(DMA)         0      0   1024    4    1 : tunables   54   27    =
0 :=20
slabdata      0      0      0
size-1024            136    136   1024    4    1 : tunables   54   27    =
0 :=20
slabdata     34     34      0
size-512(DMA)          0      0    512    8    1 : tunables   54   27    =
0 :=20
slabdata      0      0      0
size-512             308    552    512    8    1 : tunables   54   27    =
0 :=20
slabdata     69     69      0
size-256(DMA)          0      0    256   15    1 : tunables  120   60    =
0 :=20
slabdata      0      0      0
size-256             765    900    256   15    1 : tunables  120   60    =
0 :=20
slabdata     60     60      0
size-192(DMA)          0      0    192   20    1 : tunables  120   60    =
0 :=20
slabdata      0      0      0
size-192             200    200    192   20    1 : tunables  120   60    =
0 :=20
slabdata     10     10      0
size-128(DMA)          0      0    128   31    1 : tunables  120   60    =
0 :=20
slabdata      0      0      0
size-128             399    465    128   31    1 : tunables  120   60    =
0 :=20
slabdata     15     15      0
size-96(DMA)           0      0     96   41    1 : tunables  120   60    =
0 :=20
slabdata      0      0      0
size-96             2138   2378     96   41    1 : tunables  120   60    =
0 :=20
slabdata     58     58      0
size-64(DMA)           0      0     64   61    1 : tunables  120   60    =
0 :=20
slabdata      0      0      0
size-64             1221   1342     64   61    1 : tunables  120   60    =
0 :=20
slabdata     22     22      0
size-32(DMA)           0      0     32  119    1 : tunables  120   60    =
0 :=20
slabdata      0      0      0
size-32             1487   1666     32  119    1 : tunables  120   60    =
0 :=20
slabdata     14     14      0
kmem_cache           124    124    128   31    1 : tunables  120   60    =
0 :=20
slabdata      4      4      0

/proc/sys/net/ipv4/route/max_size is 16384

By increasing that value I can delay the moment the machine starts to dro=
p=20
packets - but it will happen anyways.

One thing that astonishes me is that "ip route ls cache" shows only about=
 350=20
entries. Shouldn't that be more like 15000 as rtstat tells?

The rest of the mail shows the excact setup of the machine - I bet it is =
one=20
of the more complex firewalls around :-)

- Machine has four ethernet  devices
- Several ppp devices for PPTP tunnels
- one PPP device for DSL (second ISP connection, used to route P2P-Traffi=
c via=20
MASQ, Packets are marked via fwmark 0x10)
- several tun devices for OpenVPN tunnels
- several tap devices...

sylvaner:~# brctl show
bridge name     bridge id               STP enabled     interfaces
br50            8000.0060972ce1d2       no              eth0
                                                        eth2
                                                        eth3
br51            8000.000000000000       no              <- bridge without=
 dev
brwave          8000.00a0243878ed       no              eth1
                                                        tap0

Routing is done between br50, brwave, ppp-dsl and the different pptp tunn=
el=20
ends.

sylvaner:~# ip route show
62.134.51.225 dev ppp8  proto kernel  scope link  src 62.134.51.254
62.134.51.230 dev ppp18  proto kernel  scope link  src 62.134.51.254
62.134.51.201 via 10.254.1.10 dev tun0
62.134.51.203 dev ppp14  proto kernel  scope link  src 62.134.51.254
62.134.51.202 dev ppp15  proto kernel  scope link  src 62.134.51.254
62.134.51.207 dev tun2  proto kernel  scope link  src 62.134.51.254
62.134.51.206 dev ppp11  proto kernel  scope link  src 62.134.51.254
62.134.51.221 dev ppp29  proto kernel  scope link  src 62.134.51.254
62.134.51.208 dev ppp24  proto kernel  scope link  src 62.134.51.254
62.134.51.210 via 10.254.1.14 dev tun5
62.134.51.212 dev ppp16  proto kernel  scope link  src 62.134.51.254
194.94.249.251 via 217.5.98.56 dev ppp3
217.5.98.56 dev ppp3  proto kernel  scope link  src 80.133.233.158
62.134.51.43 dev ppp34  proto kernel  scope link  src 62.134.51.254
62.134.51.40 dev ppp22  proto kernel  scope link  src 62.134.51.254
62.134.51.41 dev ppp40  proto kernel  scope link  src 62.134.51.254
62.134.51.38 dev ppp36  proto kernel  scope link  src 62.134.51.254
62.134.51.39 dev ppp35  proto kernel  scope link  src 62.134.51.254
62.134.51.36 dev ppp38  proto kernel  scope link  src 62.134.51.254
62.134.51.37 dev ppp33  proto kernel  scope link  src 62.134.51.254
62.134.51.35 dev ppp37  proto kernel  scope link  src 62.134.51.254
62.134.51.32 dev ppp32  proto kernel  scope link  src 62.134.51.254
62.134.51.33 dev ppp1  proto kernel  scope link  src 62.134.51.254
10.254.1.14 dev tun5  proto kernel  scope link  src 10.254.1.13
10.254.1.12 dev tun4  proto kernel  scope link  src 10.254.1.11
10.254.1.10 dev tun0  proto kernel  scope link  src 10.254.1.9
10.254.1.4 dev tun3  proto kernel  scope link  src 10.254.1.3
10.254.1.2 dev tun1  proto kernel  scope link  src 10.254.1.1
62.134.51.15 dev ppp12  proto kernel  scope link  src 62.134.51.254
62.134.51.14 dev ppp30  proto kernel  scope link  src 62.134.51.254
62.134.51.12 dev ppp19  proto kernel  scope link  src 62.134.51.254
62.134.51.10 dev ppp17  proto kernel  scope link  src 62.134.51.254
62.134.51.9 dev ppp10  proto kernel  scope link  src 62.134.51.254
62.134.51.8 dev ppp23  proto kernel  scope link  src 62.134.51.254
62.134.51.6 dev ppp5  proto kernel  scope link  src 62.134.51.254
62.134.51.5 dev ppp2  proto kernel  scope link  src 62.134.51.254
62.134.51.4 dev ppp7  proto kernel  scope link  src 62.134.51.254
62.134.51.3 dev ppp31  proto kernel  scope link  src 62.134.51.254
62.134.51.2 dev ppp6  proto kernel  scope link  src 62.134.51.254
62.134.51.31 dev ppp39  proto kernel  scope link  src 62.134.51.254
62.134.51.30 dev ppp20  proto kernel  scope link  src 62.134.51.254
62.134.51.29 dev ppp25  proto kernel  scope link  src 62.134.51.254
62.134.51.28 dev ppp9  proto kernel  scope link  src 62.134.51.254
62.134.51.27 dev ppp27  proto kernel  scope link  src 62.134.51.254
62.134.51.26 dev ppp42  proto kernel  scope link  src 62.134.51.254
62.134.51.25 dev ppp41  proto kernel  scope link  src 62.134.51.254
62.134.51.24 dev ppp0  proto kernel  scope link  src 62.134.51.254
62.134.51.23 dev ppp21  proto kernel  scope link  src 62.134.51.254
62.134.51.21 dev ppp28  proto kernel  scope link  src 62.134.51.254
62.134.51.18 dev ppp13  proto kernel  scope link  src 62.134.51.254
62.134.51.17 dev ppp26  proto kernel  scope link  src 62.134.51.254
10.1.12.0/24 via 10.1.1.241 dev brwave
10.1.13.0/24 via 10.1.1.241 dev brwave
10.1.14.0/24 via 10.1.1.241 dev brwave
10.1.8.0/24 via 10.1.1.241 dev brwave
10.1.9.0/24 via 10.1.1.241 dev brwave
10.1.10.0/24 via 10.1.1.241 dev brwave
10.1.11.0/24 via 10.1.1.241 dev brwave
10.254.2.0/24 via 10.254.1.4 dev tun3
10.1.4.0/24 via 10.1.1.241 dev brwave
blackhole 10.1.5.0/24
10.1.6.0/24 via 10.1.1.241 dev brwave
10.1.7.0/24 via 10.1.1.241 dev brwave
62.134.50.0/24 dev br50  proto kernel  scope link  src 62.134.50.253
10.1.1.0/24 dev brwave  proto kernel  scope link  src 10.1.1.254
62.134.51.0/24 dev br51  proto kernel  scope link  src 62.134.51.254
10.1.2.0/24 via 10.1.1.240 dev brwave
10.1.3.0/24 via 10.1.1.240 dev brwave
10.2.0.0/16 via 10.1.1.241 dev brwave
blackhole 10.3.0.0/16
10.4.0.0/16 via 10.1.1.241 dev brwave
10.5.0.0/16 via 10.1.1.241 dev brwave
default via 62.134.50.254 dev br50

sylvaner:~# ip rule show
0:      from all lookup local
32765:  from all fwmark       10 lookup 200
32766:  from all lookup main
32767:  from all lookup default

sylvaner:~# ip route show table 200
default via 217.5.98.56 dev ppp3

Perhaps somebody knows what's wrong? Kernel bug or PEBKAC? I'm eager to=20
deliver more info when asked to :-)

Thanks,
Christian

--=20
+-------------------------------------------------------+
| Christian Daniel                                      |
| Drechselblick 5        Mariannhillstra=DFe 6 / App. 220 |
| D-97816 Lohr am Main   D-97074 W=FCrzburg               |
+-----------------------+---------------+---------------+
| http://www.cdaniel.de | cd@cdaniel.de | ICQ: 95896119 |
+-----------------------+---------------+---------------+
