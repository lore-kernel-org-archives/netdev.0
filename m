From: Kumiko Ono <kumiko@cs.columbia.edu>
Subject: PROBLEM: What happend when exceeding allocatable memory for TCP socket
 buffers?
Date: Fri, 09 Mar 2007 22:20:51 -0500
Message-ID: <45F22413.50606@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cs.columbia.edu ([128.59.16.20]:40848 "EHLO cs.columbia.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751806AbXCJDUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 22:20:55 -0500
Received: from lion.cs.columbia.edu (IDENT:P+oqENjjfzhad1KSIk/bjUfszld6pLSd@lion.cs.columbia.edu [128.59.16.120])
	by cs.columbia.edu (8.12.10/8.12.10) with ESMTP id l2A3Kpft000955
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 9 Mar 2007 22:20:52 -0500 (EST)
Received: from [128.59.19.154] (irtcluster02.cs.columbia.edu [128.59.19.154])
	by lion.cs.columbia.edu (8.12.9/8.12.9) with ESMTP id l2A3Kpb9024946
	for <netdev@vger.kernel.org>; Fri, 9 Mar 2007 22:20:51 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I tried to find out how many TCP connections a server can establish with 
a simple test program. But when trying 120K connections for receiving 
512 bytes message for each connection sequentially, of which sending 
rate was 15,000 requests/second, the system stops.
I suspect the system was required more amount of memory than auto-tuned 
allocatable memory for TCP socket buffers, since I monitored at 
/proc/net/sockstat.
The system did not hang, since it can respond to ping.
When trying to connect via ssh, ssh can establish a new TCP connection, 
but it cannot exchange auth. info. So, we cannot connect the machine via 
ssh. Even at a console machine, the system does not accept any input 
over 24 hours later.
I expected TCP timeout released socket buffers and the system recovered. 
But it didn't happen.

Could you analyze this problem?

I attached the system information. If more information is needed to 
analyze this problem, let me know.

Thanks a lot,
Kumiko
-----
Kernel version:
Linux 2.6.20 #12 SMP Tue Mar 6 16:55:47 EST 2007 i686 Intel(R) 
Pentium(R) 4 CPU 3.06GHz unknown GNU/Linux

Config:
CONFIG_EDD=y
CONFIG_HIGHMEM4G=y
CONFIG_VMSPLIT_2G=y
CONFIG_PAGE_OFFSET=0x78000000
CONFIG_HIGHMEM=y
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_POPULATES_NODE_MAP=y
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_FLATMEM_MANUAL=y
CONFIG_FLATMEM=y
CONFIG_FLAT_NODE_MEM_MAP=y
CONFIG_SPARSEMEM_STATIC=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_HIGHPTE=y

Software env:
Gnu C                  3.4.3
Gnu make               3.80
binutils               2.15.92.0.2
util-linux             2.12a
mount                  2.12a
module-init-tools      3.0
e2fsprogs              1.36
nfs-utils              1.0.7
Linux C Library        2.3.4
Dynamic linker (ldd)   2.3.4
Procps                 3.2.5
Net-tools              1.60
Console-tools          0.2.3
Sh-utils               5.2.1
udev                   054
Modules Loaded         nfsd exportfs lockd sunrpc ipv6 af_packet floppy 
ide_cd cdrom loop 8250_pci 8250 serial_core ohci_hcd usbcore

Boot log:
  kernel: 1887MB HIGHMEM available.
  kernel: 2048MB LOWMEM available.
  kernel: found SMP MP-table at 000f4fd0
  kernel: Zone PFN ranges:
  kernel:   DMA             0 ->     4096
  kernel:   Normal       4096 ->   524288
  kernel:   HighMem    524288 ->  1007610
  kernel: early_node_map[1] active PFN ranges
  kernel:     0:        0 ->  1007610
  kernel: Dentry cache hash table entries: 262144 (order: 8, 1048576 bytes)
  kernel: Inode-cache hash table entries: 131072 (order: 7, 524288 bytes)
  kernel: Memory: 3993004k/4030440k available (1922k kernel code, 36308k 
reserved, 717k data, 216k init, 1933288k highmem)
  kernel: TCP established hash table entries: 262144 (order: 9, 2097152 
bytes)
  kernel: TCP bind hash table entries: 65536 (order: 7, 524288 bytes)
  kernel: TCP: Hash tables configured (established 262144 bind 65536)


sysctl:
sunrpc.tcp_slot_table_entries = 16
net.ipv4.tcp_allowed_congestion_control = cubic reno
net.ipv4.tcp_available_congestion_control = cubic reno
net.ipv4.tcp_slow_start_after_idle = 1
net.ipv4.tcp_workaround_signed_windows = 0
net.ipv4.tcp_base_mss = 512
net.ipv4.tcp_mtu_probing = 0
net.ipv4.tcp_abc = 0
net.ipv4.tcp_congestion_control = cubic
net.ipv4.tcp_tso_win_divisor = 3
net.ipv4.tcp_moderate_rcvbuf = 1
net.ipv4.tcp_no_metrics_save = 0
net.ipv4.tcp_low_latency = 0
net.ipv4.tcp_frto = 0
net.ipv4.tcp_tw_reuse = 0
net.ipv4.tcp_adv_win_scale = 2
net.ipv4.tcp_app_win = 31
net.ipv4.tcp_rmem = 4096        87380   1048576
net.ipv4.tcp_wmem = 4096        16384   1048576
net.ipv4.tcp_mem = 24576        32768   49152
net.ipv4.tcp_dsack = 1
net.ipv4.tcp_ecn = 0
net.ipv4.tcp_reordering = 3
net.ipv4.tcp_fack = 1
net.ipv4.tcp_orphan_retries = 0
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_rfc1337 = 0
net.ipv4.tcp_stdurg = 0
net.ipv4.tcp_abort_on_overflow = 0
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_syncookies = 0
net.ipv4.tcp_fin_timeout = 60
net.ipv4.tcp_retries2 = 15
net.ipv4.tcp_retries1 = 3
net.ipv4.tcp_keepalive_intvl = 75
net.ipv4.tcp_keepalive_probes = 9
net.ipv4.tcp_keepalive_time = 7200
net.ipv4.tcp_max_tw_buckets = 180000
net.ipv4.tcp_max_orphans = 32768
net.ipv4.tcp_synack_retries = 5
net.ipv4.tcp_syn_retries = 5
net.ipv4.tcp_retrans_collapse = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_timestamps = 1
fs.nfs.nlm_tcpport = 0


Slabtop: (not at load time)
  Active / Total Objects (% used)    : 38515 / 42977 (89.6%)
  Active / Total Slabs (% used)      : 2410 / 2416 (99.8%)
  Active / Total Caches (% used)     : 75 / 120 (62.5%)
  Active / Total Size (% used)       : 9099.07K / 9653.93K (94.3%)
  Minimum / Average / Maximum Object : 0.01K / 0.22K / 128.00K





