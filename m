From: patrick mcmanus <mcmanus@ducksong.com>
Subject: how to suppress link local addresses
Date: Wed, 27 Apr 2005 14:33:52 -0400
Message-ID: <1114626832.12304.97.camel@mcmanus.datapower.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi All,

I've got a 2.6.12-rc2 kernel with IPv6 compiled in monolithically. I'm
using it on several different boxes and would like them all to run the
same kernel. Most of the boxes have IPv6 connectivity and are working
fine.. however one of them is on an IPv4 only net.

When I bring up an IPv4 interface on that box it also gets an automagic
ipv6 link-local address as a bonus. I would like to prevent that from
happening if possible.. I had thought that the conf/*/autoconf sysctl
should do that for me, but I couldn't get it to work (see my
illustration below). I'm not certain if that's a bug or I just don't
understand what that is supposed to do.

The link-local address isn't a problem most of the time. But every once
in a while a program decides I have IPv6 connectivity because of the
link-local addresses and it will try and use that, and then it just gets
timeouts.. an easy example for you to try is "dig ns example.com
@b.gtld-servers.net." .. that will fail because b.gtld-servers.net has a
AAAA record that dig gives priority to using if I have any ipv6
addresses configured - even though I'm not on a real ipv6 network.
(c.gtld-servers.net passes because it doesn't have any AAAA records).

If I manually delete the link-locals from each address dig works fine..
and I can do this, but I'd rather not have them appear at all. I want
this to be an ipv4-only configured box with an ipv6 capable kernel.

My efforts at using autoconf are illustrated below.. Any thoughts?
Hopefully this is simple. Thanks.

/home/mcmanus>cat /proc/sys/net/ipv6/conf/default/autoconf
0
/home/mcmanus>cat /proc/sys/net/ipv6/conf/all/autoconf
0
/home/mcmanus>cat /proc/sys/net/ipv6/conf/eth1/autoconf
cat: /proc/sys/net/ipv6/conf/eth1/autoconf: No such file or directory

/home/mcmanus>cat /proc/sys/net/ipv6/conf/default/accept_ra
0
/home/mcmanus>cat /proc/sys/net/ipv6/conf/all/accept_ra
0
/home/mcmanus>cat /proc/sys/net/ipv6/conf/eth1/accept_ra
cat: /proc/sys/net/ipv6/conf/eth1/accept_ra: No such file or directory

/home/mcmanus>su
Password: 
root@book:/home/mcmanus # strace ifconfig eth1 192.168.16.49 broadcast 192.168.16.255 netmask 255.255.255.0
execve("/sbin/ifconfig", ["ifconfig", "eth1", "192.168.16.49", "broadcast", "192.168.16.255", "netmask", "255.255.255.0"], [/* 32 vars */]) = 0
uname({sys="Linux", node="book", ...})  = 0
brk(0)                                  = 0x8057000
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
old_mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7fa6000
open("/etc/ld.so.preload", O_RDONLY)    = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY)      = 3
fstat64(3, {st_mode=S_IFREG|0644, st_size=60457, ...}) = 0
old_mmap(NULL, 60457, PROT_READ, MAP_PRIVATE, 3, 0) = 0xb7f97000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/tls/i686/cmov/libc.so.6", O_RDONLY) = 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\215Y\1"..., 512) = 512
fstat64(3, {st_mode=S_IFREG|0644, st_size=1222116, ...}) = 0
old_mmap(NULL, 1232428, PROT_READ|PROT_EXEC, MAP_PRIVATE, 3, 0) = 0xb7e6a000
old_mmap(0xb7f8c000, 36864, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED, 3, 0x121000) = 0xb7f8c000
old_mmap(0xb7f95000, 7724, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0xb7f95000
close(3)                                = 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7e69000
set_thread_area({entry_number:-1 -> 6, base_addr:0xb7e69080, limit:1048575, seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1, seg_not_present:0, useable:1}) = 0
munmap(0xb7f97000, 60457)               = 0
open("/usr/lib/locale/locale-archive", O_RDONLY|O_LARGEFILE) = 3
fstat64(3, {st_mode=S_IFREG|0644, st_size=1384816, ...}) = 0
mmap2(NULL, 1384816, PROT_READ, MAP_PRIVATE, 3, 0) = 0xb7d16000
close(3)                                = 0
brk(0)                                  = 0x8057000
brk(0x8078000)                          = 0x8078000
brk(0)                                  = 0x8078000
uname({sys="Linux", node="book", ...})  = 0
access("/proc/net", R_OK)               = 0
access("/proc/net/unix", R_OK)          = 0
socket(PF_FILE, SOCK_DGRAM, 0)          = 3
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 4
access("/proc/net/if_inet6", R_OK)      = 0
socket(PF_INET6, SOCK_DGRAM, IPPROTO_IP) = 5
access("/proc/net/ax25", R_OK)          = -1 ENOENT (No such file or directory)
access("/proc/net/nr", R_OK)            = -1 ENOENT (No such file or directory)
access("/proc/net/rose", R_OK)          = -1 ENOENT (No such file or directory)
access("/proc/net/ipx", R_OK)           = 0
socket(PF_IPX, SOCK_DGRAM, [PF_UNSPEC]) = 6
access("/proc/net/appletalk", R_OK)     = -1 ENOENT (No such file or directory)
access("/proc/sys/net/econet", R_OK)    = -1 ENOENT (No such file or directory)
access("/proc/sys/net/ash", R_OK)       = -1 ENOENT (No such file or directory)
access("/proc/net/x25", R_OK)           = -1 ENOENT (No such file or directory)
open("/usr/share/locale/locale.alias", O_RDONLY) = 7
fstat64(7, {st_mode=S_IFREG|0644, st_size=2539, ...}) = 0
mmap2(NULL, 131072, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7cf6000
read(7, "# Locale name alias data base.\n#"..., 131072) = 2539
read(7, "", 131072)                     = 0
close(7)                                = 0
munmap(0xb7cf6000, 131072)              = 0
open("/usr/share/locale/en_GB/LC_MESSAGES/net-tools.mo", O_RDONLY) = -1 ENOENT (No such file or directory)
open("/usr/share/locale/en/LC_MESSAGES/net-tools.mo", O_RDONLY) = -1 ENOENT (No such file or directory)
open("/usr/share/locale-langpack/en_GB/LC_MESSAGES/net-tools.mo", O_RDONLY) = -1 ENOENT (No such file or directory)
open("/usr/share/locale-langpack/en/LC_MESSAGES/net-tools.mo", O_RDONLY) = -1 ENOENT (No such file or directory)
open("/usr/share/locale/en_US/LC_MESSAGES/net-tools.mo", O_RDONLY) = -1 ENOENT (No such file or directory)
open("/usr/share/locale-langpack/en_US/LC_MESSAGES/net-tools.mo", O_RDONLY) = -1 ENOENT (No such file or directory)
ioctl(4, SIOCSIFADDR, 0xbfdba7e0)       = 0
ioctl(4, SIOCGIFFLAGS, 0xbfdba700)      = 0
ioctl(4, SIOCSIFFLAGS, 0xbfdba700)      = 0
ioctl(4, SIOCSIFBRDADDR, 0xbfdba7e0)    = 0
ioctl(4, SIOCGIFFLAGS, 0xbfdba700)      = 0
ioctl(4, SIOCSIFFLAGS, 0xbfdba700)      = 0
ioctl(4, SIOCSIFNETMASK, 0xbfdba7e0)    = 0
exit_group(0)                           = ?
root@book:/home/mcmanus # exit
/home/mcmanus>ifconfig eth1
eth1      Link encap:Ethernet  HWaddr 00:0F:EA:18:AD:7D  
          inet addr:192.168.16.49  Bcast:192.168.16.255  Mask:255.255.255.0
          inet6 addr: fe80::20f:eaff:fe18:ad7d/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:5 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 b)  TX bytes:378 (378.0 b)
          Interrupt:177 Base address:0xe800 

/home/mcmanus>uname -a
Linux book 2.6.12-rc2ducksong #2 Sat Apr 9 17:07:02 EDT 2005 i686 GNU/Linux


-Patrick
