From: Stephane Chazelas <stephane.chazelas@gmail.com>
Subject: Re: network interfaces called "all", "default" or "config"
Date: Thu, 14 Aug 2014 10:41:39 +0100
Message-ID: <CACsCDOP8DOnB0zZtT_WLhiBXjxXh1aH1eGF9_h0dRN1i9YDU-A@mail.gmail.com>
References: <20140723113314.GA7798@chaz.gmail.com>
	<53CFCD26.1020409@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53CFCD26.1020409@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

By the way, this is related:

$ ip link add link eth0 eth0:123 type vlan id 123
$ ip link del link eth0 eth0:123
RTNETLINK answers: Operation not supported

vconfig rem eth0:123

using a different API, is OK.

ip link del:

bind(3, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
getsockname(3, {sa_family=AF_NETLINK, pid=22135, groups=00000000}, [12]) = 0
sendto(3, " \0\0\0\20\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0",
32, 0, NULL, 0) = 32
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0,
groups=00000000},
msg_iov(1)=[{"4\0\0\0\2\0\0\0\0\0\0\0wV\0\0\355\377\377\377
\0\0\0\20\0\5\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0",
8192}], msg_controllen=0, msg_flags=0}, 0) = 52
access("/proc/net", R_OK)               = 0
access("/proc/net/unix", R_OK)          = 0
socket(PF_LOCAL, SOCK_DGRAM|SOCK_CLOEXEC, 0) = 4
ioctl(4, SIOCGIFINDEX, {ifr_name="eth0:123", ifr_index=2}) = 0
close(4)                                = 0
sendmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0,
groups=00000000}, msg_iov(1)=[{"
\0\0\0\21\0\5\0\305\202\354S\0\0\0\0\0\0\0\0\2\0\0\0\0\0\0\0\0\0\0\0",
32}], msg_controllen=0, msg_flags=0}, 0) = 32
recvmsg(3, {msg_name(12)={sa_family=AF_NETLINK, pid=0,
groups=00000000},
msg_iov(1)=[{"4\0\0\0\2\0\0\0\305\202\354SwV\0\0\241\377\377\377
\0\0\0\21\0\5\0\305\202\354S\0\0\0\0\0\0\0\0\2\0\0\0\0\0\0\0\0\0\0\0",
16384}], msg_controllen=0, msg_flags=0}, 0) = 52
write(2, "RTNETLINK answers: Operation not supported\n", 43) = 43
exit_group(2)                           = ?

vconfig rem:

socket(PF_INET, SOCK_STREAM, IPPROTO_IP) = 3
ioctl(3, SIOCSIFVLAN, 0x7fff67a00110)   = 0


Cheers,
Stephane


On 23 July 2014 15:56, Randy Dunlap <rdunlap@infradead.org> wrote:
>
> [adding netdev]
>
> On 07/23/2014 04:33 AM, Stephane Chazelas wrote:
> > Hiya,
> >
> > you may want to forbid the creation of interfaces whose name is
> > one of the special files in /proc/net and /proc/sys.
> >
> > I can see some characters (like space, tab, newline, slash,
> > dot...) are alread forbidden in interface names (EINVAL), but
> > one can do for instance:
> >
> > sudo ip link add link eth0 all type vlan id 2
> > sudo ip link add link eth0 default type vlan id 3
> > sudo ip link add link eth0 config type vlan id 4
> >
> > Interestingly, after you add a "all" or "default", the
> > corresponding /proc/sys/net/ipv[46]/conf/(all|default) become
> > empty, and remain so even after you've removed the interface.
> >
> > Adding an interface called "config" masks /proc/net/vlan/config
> >
> > (tested with 3.14-1-amd64 on debian)
> >
>
>
> --
> ~Randy
