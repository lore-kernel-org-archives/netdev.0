From: Michael Bellion and Thomas Heinz <nf@hipac.org>
Subject: [ANNOUNCE] nf-hipac v0.8 released
Date: Wed, 25 Jun 2003 22:48:44 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200306252248.44224.nf@hipac.org>
Reply-To: Michael Bellion and Thomas Heinz <nf@hipac.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi

We have released a new version of nf-hipac. We rewrote most of the code
and added a bunch of new features. The main enhancements are
user-defined chains, generic support for iptables targets and matches
and 64 bit atomic counters.


For all of you who don't know nf-hipac yet, here is a short overview:

nf-hipac is a drop-in replacement for the iptables packet filtering module.
It implements a novel framework for packet classification which uses an
advanced algorithm to reduce the number of memory lookups per packet.
The module is ideal for environments where large rulesets and/or high
bandwidth networks are involved. Its userspace tool, which is also called 
'nf-hipac', is designed to be as compatible as possible to 'iptables -t 
filter'.

The official project web page is:    http://www.hipac.org
The releases can be downloaded from: http://sourceforge.net/projects/nf-hipac

Features:
     - optimized for high performance packet classification with moderate
       memory usage
     - completely dynamic: data structure isn't rebuild from scratch when
       inserting or deleting rules, so fast updates are possible
     - very short locking times during rule updates: packet matching is
       not blocked
     - support for 64 bit architectures
     - optimized kernel-user protocol (netlink): improved rule listing
       speed
     - libnfhipac: netlink library for kernel-user communication
     - native match support for:
         + source/destination ip
         + in/out interface
         + protocol (udp, tcp, icmp)
         + fragments
         + source/destination ports (udp, tcp)
         + tcp flags
         + icmp type
         + connection state
         + ttl
     - match negation (!)
     - iptables compatibility: syntax and semantics of the userspace tool
       are very similar to iptables
     - coexistence of nf-hipac and iptables: both facilities can be used
       at the same time
     - generic support for iptables targets and matches (binary
       compatibility)
     - integration into the netfilter connection tracking facility
     - user-defined chains support
     - 64 bit atomic counters
     - kernel module autoloading
     - /proc/net/nf-hipac/info:
           + dynamically limit the maximum memory usage
           + change invokation order of nf-hipac and iptables
     - extended statistics via /proc/net/nf-hipac/statistics/*


We are currently working on extending the hipac algorithm to do classification 
with several stages. The hipac algorithm will then be capable of combining 
several classification problems in one data structure, e.g. it will be 
possible to solve routing and firewalling with one hipac lookup. The idea is 
to shorten the packet forwarding path by combining fib_lookup and iptables 
filter lookup into one hipac query. To further improve the performance in 
this scenario the upcoming flow cache could be used to cache recent hipac 
results.



Enjoy,

+-----------------------+----------------------+
|   Michael Bellion     |     Thomas Heinz     |
| <mbellion@hipac.org>  |  <creatix@hipac.org> |
+-----------------------+----------------------+
