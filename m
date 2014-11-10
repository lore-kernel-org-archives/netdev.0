From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH net-next] net: Convert LIMIT_NETDEBUG to net_dbg_ratelimited
Date: Mon, 10 Nov 2014 15:27:15 +0100
Message-ID: <5460CB43.4050008@6wind.com>
References: <1415230929.6634.38.camel@perches.com>	 <20141106.151149.1321164537677873976.davem@davemloft.net>	 <1415307221.21526.0.camel@perches.com>	 <20141108.204202.2273082249078358608.davem@davemloft.net> <1415560642.23530.43.camel@perches.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Remi Denis-Courmont <courmisch@gmail.com>
To: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415560642.23530.43.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 09/11/2014 20:17, Joe Perches a =E9crit :
> Use the more common dynamic_debug capable net_dbg_ratelimited
> and remove the LIMIT_NETDEBUG macro.
>
> This may have some negative impact on messages that were
> emitted at KERN_INFO that are not not enabled at all unless
> DEBUG is defined or dynamic_debug is enabled.  Even so,
> these messages are now _not_ emitted by default.
>
> This eliminates the use of the net_msg_warn sysctl
> "/proc/sys/net/core/warnings".
>
> All messages are still ratelimited.
>
> Some KERN_LEVEL uses are changed to KERN_DEBUG.
>
> Miscellanea:
>
> o Update the sysctl documentation
> o Remove the embedded uses of pr_fmt
> o Coalesce format fragments
> o Realign arguments
>
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>
> Let me know if you want this consolidate patch broken up
> into multiple patches or any of the messages and the
> macro kept.
>
>   Documentation/sysctl/net.txt | 12 ++++++++----
>   include/net/sock.h           |  8 +-------
>   include/net/udplite.h        |  6 +++---
>   net/ipv4/icmp.c              |  8 ++++----
>   net/ipv4/inet_fragment.c     |  2 +-
>   net/ipv4/ip_fragment.c       |  3 +--
>   net/ipv4/tcp_input.c         |  8 ++++----
>   net/ipv4/tcp_timer.c         | 18 ++++++++++--------
>   net/ipv4/udp.c               | 30 +++++++++++++++---------------
>   net/ipv6/addrconf.c          |  6 ++----
>   net/ipv6/ah6.c               |  7 +++----
>   net/ipv6/datagram.c          |  4 ++--
>   net/ipv6/esp6.c              |  4 ++--
>   net/ipv6/exthdrs.c           | 18 +++++++++---------
>   net/ipv6/icmp.c              | 15 +++++++--------
>   net/ipv6/mip6.c              | 11 ++++++-----
>   net/ipv6/netfilter.c         |  2 +-
>   net/ipv6/udp.c               | 31 +++++++++++++------------------
>   net/phonet/af_phonet.c       |  9 +++++----
>   net/phonet/pep-gprs.c        |  3 +--
>   net/phonet/pep.c             | 12 ++++++------
>   21 files changed, 104 insertions(+), 113 deletions(-)
>
> diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.=
txt
> index 04892b8..46cd03d 100644
> --- a/Documentation/sysctl/net.txt
> +++ b/Documentation/sysctl/net.txt
> @@ -120,10 +120,14 @@ seconds.
>   warnings
>   --------
>
> -This controls console messages from the networking stack that can oc=
cur because
> -of problems on the network like duplicate address or bad checksums. =
Normally,
> -this should be enabled, but if the problem persists the messages can=
 be
> -disabled.
> +This sysctl is now unused.
> +
> +This was used to control console messages from the networking stack =
that
> +occur because of problems on the network like duplicate address or b=
ad
> +checksums.
> +
> +These messages are now emitted at KERN_DEBUG and can generally be en=
abled
> +and controlled by the dynamic_debug facility.
>
>   netdev_budget
>   -------------
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 6767d75..db363ad 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -2276,13 +2276,7 @@ bool sk_ns_capable(const struct sock *sk,
>   bool sk_capable(const struct sock *sk, int cap);
>   bool sk_net_capable(const struct sock *sk, int cap);
>
> -/*
> - *	Enable debug/info messages
> - */
> -extern int net_msg_warn;
> -#define LIMIT_NETDEBUG(fmt, args...) \
> -	do { if (net_msg_warn && net_ratelimit()) printk(fmt,##args); } whi=
le(0)
> -
> +extern int net_msg_warn;	/* Unused, but still a sysctl */
Why not removing this variable from this header and from net/core/utils=
=2Ec?
Just declaring a static variable in net/core/sysctl_net_core.c should b=
e enough.
Am I missing something?

Nicolas
