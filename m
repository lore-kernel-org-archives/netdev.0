From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [ANNOUNCE] nf-hipac v0.8 released
Date: Fri, 27 Jun 2003 09:06:27 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0306270900260.3068-100000@netcore.fi>
References: <200306252248.44224.nf@hipac.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Bellion and Thomas Heinz <nf@hipac.org>
In-Reply-To: <200306252248.44224.nf@hipac.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Looks interesting.  Is there experience about this in bridging firewall 
scenarios? (With or without external patchset's like 
http://ebtables.sourceforge.net/)

Further, you mention the performance reasons for this approach.  I would 
be very interested to see some figures.

(As it happens, we've done some testing with different iptables rules
ourselves, and noticed significant problems especially when you go down
from IP addresses to UDP/TCP ports, for example.)

On Wed, 25 Jun 2003, Michael Bellion and Thomas Heinz wrote:
> We have released a new version of nf-hipac. We rewrote most of the code
> and added a bunch of new features. The main enhancements are
> user-defined chains, generic support for iptables targets and matches
> and 64 bit atomic counters.
> 
> 
> For all of you who don't know nf-hipac yet, here is a short overview:
> 
> nf-hipac is a drop-in replacement for the iptables packet filtering module.
> It implements a novel framework for packet classification which uses an
> advanced algorithm to reduce the number of memory lookups per packet.
> The module is ideal for environments where large rulesets and/or high
> bandwidth networks are involved. Its userspace tool, which is also called 
> 'nf-hipac', is designed to be as compatible as possible to 'iptables -t 
> filter'.
> 
> The official project web page is:    http://www.hipac.org
> The releases can be downloaded from: http://sourceforge.net/projects/nf-hipac
> 
> Features:
>      - optimized for high performance packet classification with moderate
>        memory usage
>      - completely dynamic: data structure isn't rebuild from scratch when
>        inserting or deleting rules, so fast updates are possible
>      - very short locking times during rule updates: packet matching is
>        not blocked
>      - support for 64 bit architectures
>      - optimized kernel-user protocol (netlink): improved rule listing
>        speed
>      - libnfhipac: netlink library for kernel-user communication
>      - native match support for:
>          + source/destination ip
>          + in/out interface
>          + protocol (udp, tcp, icmp)
>          + fragments
>          + source/destination ports (udp, tcp)
>          + tcp flags
>          + icmp type
>          + connection state
>          + ttl
>      - match negation (!)
>      - iptables compatibility: syntax and semantics of the userspace tool
>        are very similar to iptables
>      - coexistence of nf-hipac and iptables: both facilities can be used
>        at the same time
>      - generic support for iptables targets and matches (binary
>        compatibility)
>      - integration into the netfilter connection tracking facility
>      - user-defined chains support
>      - 64 bit atomic counters
>      - kernel module autoloading
>      - /proc/net/nf-hipac/info:
>            + dynamically limit the maximum memory usage
>            + change invokation order of nf-hipac and iptables
>      - extended statistics via /proc/net/nf-hipac/statistics/*
> 
> 
> We are currently working on extending the hipac algorithm to do classification 
> with several stages. The hipac algorithm will then be capable of combining 
> several classification problems in one data structure, e.g. it will be 
> possible to solve routing and firewalling with one hipac lookup. The idea is 
> to shorten the packet forwarding path by combining fib_lookup and iptables 
> filter lookup into one hipac query. To further improve the performance in 
> this scenario the upcoming flow cache could be used to cache recent hipac 
> results.
> 
> 
> 
> Enjoy,
> 
> +-----------------------+----------------------+
> |   Michael Bellion     |     Thomas Heinz     |
> | <mbellion@hipac.org>  |  <creatix@hipac.org> |
> +-----------------------+----------------------+
> 
> 

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
