From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: regression due to "flush SAD/SPD generate false events"
Date: Wed, 17 Feb 2010 21:17:19 +0200
Message-ID: <20100217191718.GA5256@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:14888 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754090Ab0BQTRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 14:17:30 -0500
Received: by qw-out-2122.google.com with SMTP id 3so91764qwe.37
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2010 11:17:28 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 19f4c7133fc1b94001b997c4843d0a9192ee63e5
xfrm: Flushing empty SAD generates false events

commit 0dca3a843632c2fbb6e358734fb08fc23e800f50
xfrm: Flushing empty SPD generates false events

setkey now takes several seconds to run this simple script
and it spits "recv: Resource temporarily unavailable" messages.

#!/usr/sbin/setkey -f
flush;
spdflush;

add A B ipcomp 44 -m tunnel -C deflate;
add B A ipcomp 45 -m tunnel -C deflate;

spdadd A B any -P in ipsec
        ipcomp/tunnel/192.168.1.2-192.168.1.3/use;
spdadd B A any -P out ipsec
        ipcomp/tunnel/192.168.1.3-192.168.1.2/use;


4909  execve("/root/ipcomp-tunnel.setkey", ["/root/ipcomp-tunnel.setkey"], [/* 22 vars */]) = 0
4909  brk(0)                            = 0x16d0000
4909  mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa171c83000
4909  mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa171c82000
4909  access("/etc/ld.so.preload", R_OK) = -1 ENOENT (No such file or directory)
4909  open("/etc/ld.so.cache", O_RDONLY) = 3
4909  fstat(3, {st_mode=S_IFREG|0644, st_size=40409, ...}) = 0
4909  mmap(NULL, 40409, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7fa171c78000
4909  close(3)                          = 0
4909  open("/lib/libutil.so.1", O_RDONLY) = 3
4909  read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0 \16\0\0\0\0\0\0"..., 832) = 832
4909  fstat(3, {st_mode=S_IFREG|0755, st_size=28959, ...}) = 0
4909  mmap(NULL, 2105608, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fa171865000
4909  mprotect(0x7fa171867000, 2093056, PROT_NONE) = 0
4909  mmap(0x7fa171a66000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1000) = 0x7fa171a66000
4909  close(3)                          = 0
4909  open("/usr/lib/libcrypto.so.0.9.8", O_RDONLY) = 3
4909  read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\0\221\6\0\0\0\0\0"..., 832) = 832
4909  fstat(3, {st_mode=S_IFREG|0555, st_size=5981705, ...}) = 0
4909  mmap(NULL, 3707672, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fa1714db000
4909  mprotect(0x7fa17163c000, 2093056, PROT_NONE) = 0
4909  mmap(0x7fa17183b000, 155648, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x160000) = 0x7fa17183b000
4909  mmap(0x7fa171861000, 13080, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fa171861000
4909  close(3)                          = 0
4909  open("/lib/libresolv.so.2", O_RDONLY) = 3
4909  read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\3208\0\0\0\0\0\0"..., 832) = 832
4909  fstat(3, {st_mode=S_IFREG|0755, st_size=328639, ...}) = 0
4909  mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa171c77000
4909  mmap(NULL, 2189960, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fa1712c4000
4909  mprotect(0x7fa1712d7000, 2097152, PROT_NONE) = 0
4909  mmap(0x7fa1714d7000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x13000) = 0x7fa1714d7000
4909  mmap(0x7fa1714d9000, 6792, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fa1714d9000
4909  close(3)                          = 0
4909  open("/lib/libreadline.so.6", O_RDONLY) = 3
4909  read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\240g\1\0\0\0\0\0"..., 832) = 832
4909  fstat(3, {st_mode=S_IFREG|0555, st_size=731087, ...}) = 0
4909  mmap(NULL, 2372136, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fa171080000
4909  mprotect(0x7fa1710bb000, 2093056, PROT_NONE) = 0
4909  mmap(0x7fa1712ba000, 32768, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x3a000) = 0x7fa1712ba000
4909  mmap(0x7fa1712c2000, 4648, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fa1712c2000
4909  close(3)                          = 0
4909  open("/lib/libcrypt.so.1", O_RDONLY) = 3
4909  read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0`\n\0\0\0\0\0\0"..., 832) = 832
4909  fstat(3, {st_mode=S_IFREG|0755, st_size=125022, ...}) = 0
4909  mmap(NULL, 2322880, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fa170e48000
4909  mprotect(0x7fa170e50000, 2097152, PROT_NONE) = 0
4909  mmap(0x7fa171050000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x8000) = 0x7fa171050000
4909  mmap(0x7fa171052000, 184768, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fa171052000
4909  close(3)                          = 0
4909  open("/lib/libc.so.6", O_RDONLY)  = 3
4909  read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0@\353\1\0\0\0\0\0"..., 832) = 832
4909  fstat(3, {st_mode=S_IFREG|0755, st_size=8673692, ...}) = 0
4909  mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa171c76000
4909  mmap(NULL, 3508264, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fa170aef000
4909  mprotect(0x7fa170c3e000, 2097152, PROT_NONE) = 0
4909  mmap(0x7fa170e3e000, 20480, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x14f000) = 0x7fa170e3e000
4909  mmap(0x7fa170e43000, 18472, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fa170e43000
4909  close(3)                          = 0
4909  open("/lib/libdl.so.2", O_RDONLY) = 3
4909  read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\360\r\0\0\0\0\0\0"..., 832) = 832
4909  fstat(3, {st_mode=S_IFREG|0755, st_size=103353, ...}) = 0
4909  mmap(NULL, 2109696, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fa1708eb000
4909  mprotect(0x7fa1708ed000, 2097152, PROT_NONE) = 0
4909  mmap(0x7fa170aed000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x2000) = 0x7fa170aed000
4909  close(3)                          = 0
4909  open("/lib/libz.so.1", O_RDONLY)  = 3
4909  read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0@ \0\0\0\0\0\0"..., 832) = 832
4909  fstat(3, {st_mode=S_IFREG|0755, st_size=217286, ...}) = 0
4909  mmap(NULL, 2183664, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fa1706d5000
4909  mprotect(0x7fa1706ea000, 2093056, PROT_NONE) = 0
4909  mmap(0x7fa1708e9000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x14000) = 0x7fa1708e9000
4909  close(3)                          = 0
4909  open("/lib/libncurses.so.5", O_RDONLY) = 3
4909  read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\240M\1\0\0\0\0\0"..., 832) = 832
4909  fstat(3, {st_mode=S_IFREG|0755, st_size=1433703, ...}) = 0
4909  mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa171c75000
4909  mmap(NULL, 2426760, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fa170484000
4909  mprotect(0x7fa1704d0000, 2093056, PROT_NONE) = 0
4909  mmap(0x7fa1706cf000, 20480, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x4b000) = 0x7fa1706cf000
4909  mmap(0x7fa1706d4000, 1928, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7fa1706d4000
4909  close(3)                          = 0
4909  mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa171c74000
4909  mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa171c73000
4909  arch_prctl(ARCH_SET_FS, 0x7fa171c736f0) = 0
4909  mprotect(0x7fa1706cf000, 16384, PROT_READ) = 0
4909  mprotect(0x7fa1708e9000, 4096, PROT_READ) = 0
4909  mprotect(0x7fa170aed000, 4096, PROT_READ) = 0
4909  mprotect(0x7fa170e3e000, 16384, PROT_READ) = 0
4909  mprotect(0x7fa171050000, 4096, PROT_READ) = 0
4909  mprotect(0x7fa1712ba000, 8192, PROT_READ) = 0
4909  mprotect(0x7fa1714d7000, 4096, PROT_READ) = 0
4909  mprotect(0x7fa17183b000, 57344, PROT_READ) = 0
4909  mprotect(0x7fa171a66000, 4096, PROT_READ) = 0
4909  mprotect(0x616000, 4096, PROT_READ) = 0
4909  mprotect(0x7fa171c84000, 4096, PROT_READ) = 0
4909  munmap(0x7fa171c78000, 40409)     = 0
4909  brk(0)                            = 0x16d0000
4909  brk(0x16f1000)                    = 0x16f1000
4909  open("/etc/localtime", O_RDONLY)  = 3
4909  fstat(3, {st_mode=S_IFREG|0644, st_size=2067, ...}) = 0
4909  fstat(3, {st_mode=S_IFREG|0644, st_size=2067, ...}) = 0
4909  mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa171c81000
4909  read(3, "TZif2\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\v\0\0\0\v\0\0\0\0"..., 4096) = 2067
4909  lseek(3, -1300, SEEK_CUR)         = 767
4909  read(3, "TZif2\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\f\0\0\0\f\0\0\0\0"..., 4096) = 1300
4909  close(3)                          = 0
4909  munmap(0x7fa171c81000, 4096)      = 0
4909  stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=2067, ...}) = 0
4909  open("/root/ipcomp-tunnel.setkey", O_RDONLY) = 3
4909  socket(PF_KEY, SOCK_RAW, 2)       = 4
4909  setsockopt(4, SOL_SOCKET, SO_SNDBUF, [131072], 4) = 0
4909  setsockopt(4, SOL_SOCKET, SO_RCVBUF, [131072], 4) = 0
4909  setsockopt(4, SOL_SOCKET, SO_RCVBUF, [262144], 4) = 0
4909  setsockopt(4, SOL_SOCKET, SO_RCVBUF, [524288], 4) = 0
4909  setsockopt(4, SOL_SOCKET, SO_RCVBUF, [1048576], 4) = 0
4909  getpid()                          = 4909
4909  sendto(4, "\2\7\0\0\2\0\0\0\0\0\0\0-\23\0\0", 16, 0, NULL, 0) = 16
4909  recvfrom(4, "\2\7\0\0\v\0\0\0\0\0\0\0-\23\0\0", 16, MSG_PEEK, NULL, NULL) = 16
4909  recvfrom(4, "\2\7\0\0\v\0\0\0\0\0\0\0-\23\0\0\3\0\16\0kkkk\373\0\0\0\0\0\0\0"..., 88, 0, NULL, NULL) = 88
4909  ioctl(3, SNDCTL_TMR_TIMEBASE or TCGETS, 0x7fffa5d10d90) = -1 ENOTTY (Inappropriate ioctl for device)
4909  fstat(3, {st_mode=S_IFREG|0755, st_size=599, ...}) = 0
4909  mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa171c81000
4909  read(3, "#!/usr/sbin/setkey -f\nflush;\nspd"..., 8192) = 599
4909  read(3, "", 4096)                 = 0
4909  setsockopt(4, SOL_SOCKET, SO_RCVTIMEO, "\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0", 16) = 0
4909  sendto(4, "\2\t\0\0\2\0\0\0\0\0\0\0-\23\0\0", 16, 0, NULL, 0) = 16
4909  recvfrom(4, 0x7fffa5d08e80, 32768, 0, 0, 0) = -1 EAGAIN (Resource temporarily unavailable)
4909  dup(2)                            = 5
4909  fcntl(5, F_GETFL)                 = 0x8002 (flags O_RDWR|O_LARGEFILE)
4909  fstat(5, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 1), ...}) = 0
4909  mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa171c80000
4909  lseek(5, 0, SEEK_CUR)             = -1 ESPIPE (Illegal seek)
4909  write(5, "recv: Resource temporarily unava"..., 39) = 39
4909  close(5)                          = 0
4909  munmap(0x7fa171c80000, 4096)      = 0
4909  setsockopt(4, SOL_SOCKET, SO_RCVTIMEO, "\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0", 16) = 0
4909  sendto(4, "\2\23\0\0\2\0\0\0\0\0\0\0-\23\0\0", 16, 0, NULL, 0) = 16
4909  recvfrom(4, 0x7fffa5d08e80, 32768, 0, 0, 0) = -1 EAGAIN (Resource temporarily unavailable)
4909  dup(2)                            = 5
4909  fcntl(5, F_GETFL)                 = 0x8002 (flags O_RDWR|O_LARGEFILE)
4909  fstat(5, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 1), ...}) = 0
4909  mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa171c80000
4909  lseek(5, 0, SEEK_CUR)             = -1 ESPIPE (Illegal seek)
4909  write(5, "recv: Resource temporarily unava"..., 39) = 39
4909  close(5)                          = 0
4909  munmap(0x7fa171c80000, 4096)      = 0
4909  socket(PF_NETLINK, SOCK_RAW, 0)   = 5
4909  bind(5, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
4909  getsockname(5, {sa_family=AF_NETLINK, pid=4909, groups=00000000}, [12]) = 0
4909  sendto(5, "\24\0\0\0\26\0\1\3#7|K\0\0\0\0\0\0\0\0", 20, 0, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 20
4909  recvmsg(5, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"8\0\0\0\24\0\2\0#7|K-\23\0\0\2\10\200\376\1\0\0\0\10\0\1\0\177\0\0\1"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 116
4909  recvmsg(5, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\24\0\0\0\3\0\2\0#7|K-\23\0\0\0\0\0\0\1\0\0\0\10\0\1\0\177\0\0\1"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 20
4909  close(5)                          = 0
4909  socket(PF_FILE, SOCK_STREAM|SOCK_CLOEXEC|SOCK_NONBLOCK, 0) = 5
4909  connect(5, {sa_family=AF_FILE, path="/var/run/nscd/socket"}, 110) = -1 ENOENT (No such file or directory)
4909  close(5)                          = 0
4909  socket(PF_FILE, SOCK_STREAM|SOCK_CLOEXEC|SOCK_NONBLOCK, 0) = 5
4909  connect(5, {sa_family=AF_FILE, path="/var/run/nscd/socket"}, 110) = -1 ENOENT (No such file or directory)
4909  close(5)                          = 0
4909  open("/etc/nsswitch.conf", O_RDONLY) = 5
4909  fstat(5, {st_mode=S_IFREG|0644, st_size=508, ...}) = 0
4909  mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa171c80000
4909  read(5, "# /etc/nsswitch.conf:\n# $Header:"..., 4096) = 508
4909  read(5, "", 4096)                 = 0
4909  close(5)                          = 0
4909  munmap(0x7fa171c80000, 4096)      = 0
4909  open("/etc/host.conf", O_RDONLY)  = 5
4909  fstat(5, {st_mode=S_IFREG|0644, st_size=936, ...}) = 0
4909  mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa171c80000
4909  read(5, "# /etc/host.conf:\n# $Header: /va"..., 4096) = 936
4909  read(5, "", 4096)                 = 0
4909  close(5)                          = 0
4909  munmap(0x7fa171c80000, 4096)      = 0
4909  open("/etc/resolv.conf", O_RDONLY) = 5
4909  fstat(5, {st_mode=S_IFREG|0644, st_size=23, ...}) = 0
4909  mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa171c80000
4909  read(5, "nameserver 192.168.1.1\n", 4096) = 23
4909  read(5, "", 4096)                 = 0
4909  close(5)                          = 0
4909  munmap(0x7fa171c80000, 4096)      = 0
4909  uname({sys="Linux", node="B", ...}) = 0
4909  open("/etc/ld.so.cache", O_RDONLY) = 5
4909  fstat(5, {st_mode=S_IFREG|0644, st_size=40409, ...}) = 0
4909  mmap(NULL, 40409, PROT_READ, MAP_PRIVATE, 5, 0) = 0x7fa171c69000
4909  close(5)                          = 0
4909  open("/lib/libnss_files.so.2", O_RDONLY) = 5
4909  read(5, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0p!\0\0\0\0\0\0"..., 832) = 832
4909  fstat(5, {st_mode=S_IFREG|0755, st_size=218643, ...}) = 0
4909  mmap(NULL, 2143632, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 5, 0) = 0x7fa170278000
4909  mprotect(0x7fa170283000, 2093056, PROT_NONE) = 0
4909  mmap(0x7fa170482000, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 5, 0xa000) = 0x7fa170482000
4909  close(5)                          = 0
4909  mprotect(0x7fa170482000, 4096, PROT_READ) = 0
4909  munmap(0x7fa171c69000, 40409)     = 0
4909  open("/etc/hosts", O_RDONLY|O_CLOEXEC) = 5
4909  fcntl(5, F_GETFD)                 = 0x1 (flags FD_CLOEXEC)
4909  fstat(5, {st_mode=S_IFREG|0644, st_size=131, ...}) = 0
4909  mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa171c80000
4909  read(5, "127.0.0.1\tlocalhost\n192.168.1.2\t"..., 4096) = 131
4909  close(5)                          = 0
4909  munmap(0x7fa171c80000, 4096)      = 0
4909  socket(PF_NETLINK, SOCK_RAW, 0)   = 5
4909  bind(5, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
4909  getsockname(5, {sa_family=AF_NETLINK, pid=4909, groups=00000000}, [12]) = 0
4909  sendto(5, "\24\0\0\0\26\0\1\3#7|K\0\0\0\0\0\0\0\0", 20, 0, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 20
4909  recvmsg(5, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"8\0\0\0\24\0\2\0#7|K-\23\0\0\2\10\200\376\1\0\0\0\10\0\1\0\177\0\0\1"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 116
4909  recvmsg(5, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\24\0\0\0\3\0\2\0#7|K-\23\0\0\0\0\0\0\1\0\0\0\10\0\1\0\177\0\0\1"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 20
4909  close(5)                          = 0
4909  stat("/etc/resolv.conf", {st_mode=S_IFREG|0644, st_size=23, ...}) = 0
4909  open("/etc/resolv.conf", O_RDONLY) = 5
4909  fstat(5, {st_mode=S_IFREG|0644, st_size=23, ...}) = 0
4909  mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa171c80000
4909  read(5, "nameserver 192.168.1.1\n", 4096) = 23
4909  read(5, "", 4096)                 = 0
4909  close(5)                          = 0
4909  munmap(0x7fa171c80000, 4096)      = 0
4909  uname({sys="Linux", node="B", ...}) = 0
4909  open("/etc/hosts", O_RDONLY|O_CLOEXEC) = 5
4909  fstat(5, {st_mode=S_IFREG|0644, st_size=131, ...}) = 0
4909  mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa171c80000
4909  read(5, "127.0.0.1\tlocalhost\n192.168.1.2\t"..., 4096) = 131
4909  close(5)                          = 0
4909  munmap(0x7fa171c80000, 4096)      = 0
4909  setsockopt(4, SOL_SOCKET, SO_RCVTIMEO, "\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0", 16) = 0
4909  sendto(4, "\2\3\0\t\f\0\0\0\0\0\0\0-\23\0\0\2\0\1\0\0\0\0,\0\0\0\2@\0\0\0"..., 96, 0, NULL, 0) = 96
4909  recvfrom(4, "\2\3\0\t\33\0\0\0\0\0\0\0-\23\0\0\2\0\1\0\0\0\0,\0\1\0\2\0\0\0\0"..., 32768, 0, NULL, NULL) = 216
4909  socket(PF_NETLINK, SOCK_RAW, 0)   = 5
4909  bind(5, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
4909  getsockname(5, {sa_family=AF_NETLINK, pid=4909, groups=00000000}, [12]) = 0
4909  sendto(5, "\24\0\0\0\26\0\1\3#7|K\0\0\0\0\0\0\0\0", 20, 0, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 20
4909  recvmsg(5, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"8\0\0\0\24\0\2\0#7|K-\23\0\0\2\10\200\376\1\0\0\0\10\0\1\0\177\0\0\1"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 116
4909  recvmsg(5, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\24\0\0\0\3\0\2\0#7|K-\23\0\0\0\0\0\0\1\0\0\0\10\0\1\0\177\0\0\1"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 20
4909  close(5)                          = 0
4909  open("/etc/hosts", O_RDONLY|O_CLOEXEC) = 5
4909  fstat(5, {st_mode=S_IFREG|0644, st_size=131, ...}) = 0
4909  mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa171c80000
4909  read(5, "127.0.0.1\tlocalhost\n192.168.1.2\t"..., 4096) = 131
4909  close(5)                          = 0
4909  munmap(0x7fa171c80000, 4096)      = 0
4909  socket(PF_NETLINK, SOCK_RAW, 0)   = 5
4909  bind(5, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
4909  getsockname(5, {sa_family=AF_NETLINK, pid=4909, groups=00000000}, [12]) = 0
4909  sendto(5, "\24\0\0\0\26\0\1\3#7|K\0\0\0\0\0\0\0\0", 20, 0, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 20
4909  recvmsg(5, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"8\0\0\0\24\0\2\0#7|K-\23\0\0\2\10\200\376\1\0\0\0\10\0\1\0\177\0\0\1"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 116
4909  recvmsg(5, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\24\0\0\0\3\0\2\0#7|K-\23\0\0\0\0\0\0\1\0\0\0\10\0\1\0\177\0\0\1"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 20
4909  close(5)                          = 0
4909  open("/etc/hosts", O_RDONLY|O_CLOEXEC) = 5
4909  fstat(5, {st_mode=S_IFREG|0644, st_size=131, ...}) = 0
4909  mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa171c80000
4909  read(5, "127.0.0.1\tlocalhost\n192.168.1.2\t"..., 4096) = 131
4909  close(5)                          = 0
4909  munmap(0x7fa171c80000, 4096)      = 0
4909  setsockopt(4, SOL_SOCKET, SO_RCVTIMEO, "\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0", 16) = 0
4909  sendto(4, "\2\3\0\t\f\0\0\0\0\0\0\0-\23\0\0\2\0\1\0\0\0\0-\0\0\0\2@\0\0\0"..., 96, 0, NULL, 0) = 96
4909  recvfrom(4, "\2\3\0\t\33\0\0\0\0\0\0\0-\23\0\0\2\0\1\0\0\0\0-\0\1\0\2\0\0\0\0"..., 32768, 0, NULL, NULL) = 216
4909  socket(PF_NETLINK, SOCK_RAW, 0)   = 5
4909  bind(5, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
4909  getsockname(5, {sa_family=AF_NETLINK, pid=4909, groups=00000000}, [12]) = 0
4909  sendto(5, "\24\0\0\0\26\0\1\3#7|K\0\0\0\0\0\0\0\0", 20, 0, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 20
4909  recvmsg(5, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"8\0\0\0\24\0\2\0#7|K-\23\0\0\2\10\200\376\1\0\0\0\10\0\1\0\177\0\0\1"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 116
4909  recvmsg(5, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\24\0\0\0\3\0\2\0#7|K-\23\0\0\0\0\0\0\1\0\0\0\10\0\1\0\177\0\0\1"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 20
4909  close(5)                          = 0
4909  socket(PF_NETLINK, SOCK_RAW, 0)   = 5
4909  bind(5, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
4909  getsockname(5, {sa_family=AF_NETLINK, pid=4909, groups=00000000}, [12]) = 0
4909  sendto(5, "\24\0\0\0\26\0\1\3#7|K\0\0\0\0\0\0\0\0", 20, 0, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 20
4909  recvmsg(5, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"8\0\0\0\24\0\2\0#7|K-\23\0\0\2\10\200\376\1\0\0\0\10\0\1\0\177\0\0\1"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 116
4909  recvmsg(5, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\24\0\0\0\3\0\2\0#7|K-\23\0\0\0\0\0\0\1\0\0\0\10\0\1\0\177\0\0\1"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 20
4909  close(5)                          = 0
4909  socket(PF_NETLINK, SOCK_RAW, 0)   = 5
4909  bind(5, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
4909  getsockname(5, {sa_family=AF_NETLINK, pid=4909, groups=00000000}, [12]) = 0
4909  sendto(5, "\24\0\0\0\26\0\1\3#7|K\0\0\0\0\0\0\0\0", 20, 0, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 20
4909  recvmsg(5, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"8\0\0\0\24\0\2\0#7|K-\23\0\0\2\10\200\376\1\0\0\0\10\0\1\0\177\0\0\1"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 116
4909  recvmsg(5, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\24\0\0\0\3\0\2\0#7|K-\23\0\0\0\0\0\0\1\0\0\0\10\0\1\0\177\0\0\1"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 20
4909  close(5)                          = 0
4909  open("/etc/hosts", O_RDONLY|O_CLOEXEC) = 5
4909  fstat(5, {st_mode=S_IFREG|0644, st_size=131, ...}) = 0
4909  mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa171c80000
4909  read(5, "127.0.0.1\tlocalhost\n192.168.1.2\t"..., 4096) = 131
4909  close(5)                          = 0
4909  munmap(0x7fa171c80000, 4096)      = 0
4909  socket(PF_NETLINK, SOCK_RAW, 0)   = 5
4909  bind(5, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
4909  getsockname(5, {sa_family=AF_NETLINK, pid=4909, groups=00000000}, [12]) = 0
4909  sendto(5, "\24\0\0\0\26\0\1\3#7|K\0\0\0\0\0\0\0\0", 20, 0, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 20
4909  recvmsg(5, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"8\0\0\0\24\0\2\0#7|K-\23\0\0\2\10\200\376\1\0\0\0\10\0\1\0\177\0\0\1"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 116
4909  recvmsg(5, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\24\0\0\0\3\0\2\0#7|K-\23\0\0\0\0\0\0\1\0\0\0\10\0\1\0\177\0\0\1"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 20
4909  close(5)                          = 0
4909  open("/etc/hosts", O_RDONLY|O_CLOEXEC) = 5
4909  fstat(5, {st_mode=S_IFREG|0644, st_size=131, ...}) = 0
4909  mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa171c80000
4909  read(5, "127.0.0.1\tlocalhost\n192.168.1.2\t"..., 4096) = 131
4909  close(5)                          = 0
4909  munmap(0x7fa171c80000, 4096)      = 0
4909  setsockopt(4, SOL_SOCKET, SO_RCVTIMEO, "\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0", 16) = 0
4909  sendto(4, "\2\16\0\0\20\0\0\0\0\0\0\0-\23\0\0\10\0\22\0\2\0\1\0\0\0\0\0\0\0\0\200"..., 128, 0, NULL, 0) = 128
4909  recvfrom(4, "\2\16\0\0\34\0\3\0\0\0\0\0-\23\0\0\3\0\5\0\377 \0\0\2\0\0\0\300\250\1\2"..., 32768, 0, NULL, NULL) = 224
4909  setsockopt(4, SOL_SOCKET, SO_RCVTIMEO, "\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0", 16) = 0
4909  sendto(4, "\2\16\0\0\20\0\0\0\0\0\0\0-\23\0\0\10\0\22\0\2\0\3\0\0\0\0\0\0\0\0\200"..., 128, 0, NULL, 0) = 128
4909  recvfrom(4, "\2\16\0\0\34\0\3\0\0\0\0\0-\23\0\0\3\0\5\0\377 \0\0\2\0\0\0\300\250\1\2"..., 32768, 0, NULL, NULL) = 224
4909  socket(PF_NETLINK, SOCK_RAW, 0)   = 5
4909  bind(5, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
4909  getsockname(5, {sa_family=AF_NETLINK, pid=4909, groups=00000000}, [12]) = 0
4909  sendto(5, "\24\0\0\0\26\0\1\3#7|K\0\0\0\0\0\0\0\0", 20, 0, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 20
4909  recvmsg(5, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"8\0\0\0\24\0\2\0#7|K-\23\0\0\2\10\200\376\1\0\0\0\10\0\1\0\177\0\0\1"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 116
4909  recvmsg(5, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\24\0\0\0\3\0\2\0#7|K-\23\0\0\0\0\0\0\1\0\0\0\10\0\1\0\177\0\0\1"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 20
4909  close(5)                          = 0
4909  socket(PF_NETLINK, SOCK_RAW, 0)   = 5
4909  bind(5, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
4909  getsockname(5, {sa_family=AF_NETLINK, pid=4909, groups=00000000}, [12]) = 0
4909  sendto(5, "\24\0\0\0\26\0\1\3#7|K\0\0\0\0\0\0\0\0", 20, 0, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 20
4909  recvmsg(5, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"8\0\0\0\24\0\2\0#7|K-\23\0\0\2\10\200\376\1\0\0\0\10\0\1\0\177\0\0\1"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 116
4909  recvmsg(5, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\24\0\0\0\3\0\2\0#7|K-\23\0\0\0\0\0\0\1\0\0\0\10\0\1\0\177\0\0\1"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 20
4909  close(5)                          = 0
4909  socket(PF_NETLINK, SOCK_RAW, 0)   = 5
4909  bind(5, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
4909  getsockname(5, {sa_family=AF_NETLINK, pid=4909, groups=00000000}, [12]) = 0
4909  sendto(5, "\24\0\0\0\26\0\1\3#7|K\0\0\0\0\0\0\0\0", 20, 0, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 20
4909  recvmsg(5, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"8\0\0\0\24\0\2\0#7|K-\23\0\0\2\10\200\376\1\0\0\0\10\0\1\0\177\0\0\1"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 116
4909  recvmsg(5, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\24\0\0\0\3\0\2\0#7|K-\23\0\0\0\0\0\0\1\0\0\0\10\0\1\0\177\0\0\1"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 20
4909  close(5)                          = 0
4909  open("/etc/hosts", O_RDONLY|O_CLOEXEC) = 5
4909  fstat(5, {st_mode=S_IFREG|0644, st_size=131, ...}) = 0
4909  mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa171c80000
4909  read(5, "127.0.0.1\tlocalhost\n192.168.1.2\t"..., 4096) = 131
4909  close(5)                          = 0
4909  munmap(0x7fa171c80000, 4096)      = 0
4909  socket(PF_NETLINK, SOCK_RAW, 0)   = 5
4909  bind(5, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
4909  getsockname(5, {sa_family=AF_NETLINK, pid=4909, groups=00000000}, [12]) = 0
4909  sendto(5, "\24\0\0\0\26\0\1\3#7|K\0\0\0\0\0\0\0\0", 20, 0, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 20
4909  recvmsg(5, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"8\0\0\0\24\0\2\0#7|K-\23\0\0\2\10\200\376\1\0\0\0\10\0\1\0\177\0\0\1"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 116
4909  recvmsg(5, {msg_name(12)={sa_family=AF_NETLINK, pid=0, groups=00000000}, msg_iov(1)=[{"\24\0\0\0\3\0\2\0#7|K-\23\0\0\0\0\0\0\1\0\0\0\10\0\1\0\177\0\0\1"..., 4096}], msg_controllen=0, msg_flags=0}, 0) = 20
4909  close(5)                          = 0
4909  open("/etc/hosts", O_RDONLY|O_CLOEXEC) = 5
4909  fstat(5, {st_mode=S_IFREG|0644, st_size=131, ...}) = 0
4909  mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fa171c80000
4909  read(5, "127.0.0.1\tlocalhost\n192.168.1.2\t"..., 4096) = 131
4909  close(5)                          = 0
4909  munmap(0x7fa171c80000, 4096)      = 0
4909  setsockopt(4, SOL_SOCKET, SO_RCVTIMEO, "\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0", 16) = 0
4909  sendto(4, "\2\16\0\0\20\0\0\0\0\0\0\0-\23\0\0\10\0\22\0\2\0\2\0\0\0\0\0\0\0\0\200"..., 128, 0, NULL, 0) = 128
4909  recvfrom(4, "\2\16\0\0\34\0\3\0\0\0\0\0-\23\0\0\3\0\5\0\377 \0\0\2\0\0\0\300\250\1\3"..., 32768, 0, NULL, NULL) = 224
4909  read(3, "", 8192)                 = 0
4909  ioctl(3, SNDCTL_TMR_TIMEBASE or TCGETS, 0x7fffa5d10d90) = -1 ENOTTY (Inappropriate ioctl for device)
4909  exit_group(0)                     = ?
