From: "David S. Miller" <davem@redhat.com>
Subject: Big set of networking updates
Date: Wed, 18 Aug 2004 17:37:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040818173736.7ad8e58a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


A lot of things are accumulating for 2.6.9-preX while Linus
is away.  So I figured best to post what I have in my tree
so we can begin to weed the problems out.

Detailed changelong is attached, and the changes are available
in two forms:

BK:	bk://kernel.bkbits.net/davem/net-2.6
PATCH:	ftp://ftp.kernel.org/pub/linux/kernel/people/davem/net-2.6.9.diff.gz

Harald, all of your netfilter updates are in here.  I had to fixup
a bunch of things to get the build and module symbol exports clean.
In particular have a look at changesets:

1.1862: [NETFILTER]: Convert SCTP conntrack over to ip_ct_refresh_acct(). 
1.1863: [NETFILTER]: Export ip_conntrack_count for ip_conntrack_standalone.
1.1864: [NETFILTER]: Need to export ip_ct_log_invalid to modules.

And I put the skb_header_pointer() bits in here too.

Enjoy.

ChangeSet@1.1807.17.1, 2004-07-24 22:41:57-07:00, laforge@netfilter.org
  [NETFILTER]: ip_nat_snmp call skb_make_writable()
  
  The snmp helper needs an explicit call to skb_ip_make_writable.
  Please apply.
  
  Signed-off-by: James Morris <jmorris@redhat.com>
  Signed-off-by: Harald Welte <laforge@netfilter.org>
  Signed-off-by: David S. Miller <davem@redhat.com>

 net/ipv4/netfilter/ip_nat_snmp_basic.c |    3 +++
 1 files changed, 3 insertions(+)


ChangeSet@1.1807.17.2, 2004-07-24 22:42:44-07:00, laforge@netfilter.org
  [NETFILTER]: ipt_ULOG fix for last packet delay
  
  The ULOG target used to delay the last packet until another one was received.
  This patch fixes the issue.
  
  Signed-off-by: Ruby Joker <ruby.joker@op.pl>
  Signed-off-by: Harald Welte <laforge@netfilter.org>
  Signed-off-by: David S. Miller <davem@redhat.com>

 net/ipv4/netfilter/ipt_ULOG.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)


ChangeSet@1.1807.17.3, 2004-07-24 22:43:32-07:00, laforge@netfilter.org
  [NETFILTER]: Use new module_param() api
  
  This patch makes all of ipv4/ipv6 netfilter use the 'new' module_param
  API.
  
  Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
  Signed-off-by: Harald Welte <laforge@netfilter.org>
  Signed-off-by: David S. Miller <davem@redhat.com>

 net/ipv4/netfilter/ip_conntrack_amanda.c |    3 ++-
 net/ipv4/netfilter/ip_conntrack_core.c   |    6 +++---
 net/ipv4/netfilter/ip_conntrack_ftp.c    |   12 ++++++------
 net/ipv4/netfilter/ip_conntrack_irc.c    |   14 +++++++-------
 net/ipv4/netfilter/ip_conntrack_tftp.c   |   10 +++++-----
 net/ipv4/netfilter/ip_nat_ftp.c          |   10 +++++-----
 net/ipv4/netfilter/ip_nat_irc.c          |   11 +++++------
 net/ipv4/netfilter/ip_nat_snmp_basic.c   |    3 ++-
 net/ipv4/netfilter/ip_nat_tftp.c         |   10 +++++-----
 net/ipv4/netfilter/ipt_LOG.c             |    2 +-
 net/ipv4/netfilter/ipt_ULOG.c            |   17 +++++++++--------
 net/ipv4/netfilter/ipt_recent.c          |   11 ++++++-----
 net/ipv4/netfilter/iptable_filter.c      |    3 ++-
 net/ipv6/netfilter/ip6t_LOG.c            |    3 ++-
 net/ipv6/netfilter/ip6table_filter.c     |    3 ++-
 15 files changed, 62 insertions(+), 56 deletions(-)


ChangeSet@1.1807.17.4, 2004-07-24 22:44:17-07:00, laforge@netfilter.org
  [NETFILTER]: Fix mutex declaration
  
  On Sun, Jun 20, 2004 at 01:23:28PM +0200, Christoph Hellwig wrote:
  > okay, the gunk we had in arp_tables is in ip6_tables and ip6_tables,
  > too.  
  
  Signed-off-by: Christoph Hellwig <hch@lst.de>
  Signed-off-by: Harald Welte <laforge@netfilter.org>
  Signed-off-by: David S. Miller <davem@redhat.com>

 include/linux/netfilter_ipv4/ip_tables.h  |    1 -
 include/linux/netfilter_ipv6/ip6_tables.h |    4 ----
 net/ipv4/netfilter/ip_tables.c            |    2 ++
 net/ipv6/netfilter/ip6_tables.c           |    1 +
 4 files changed, 3 insertions(+), 5 deletions(-)


ChangeSet@1.1807.17.5, 2004-07-24 22:45:11-07:00, laforge@netfilter.org
  [NETFILTER]: Use slab cache for ip_conntrack_expect
  
  This patch adds a new slab cache (ip_conntrack_expect) for expectations.
  
  Signed-off-by: Pablo Neira <pablo@eurodev.net>
  Signed-off-by: Harald Welte <laforge@netfilter.org>
  Signed-off-by: David S. Miller <davem@redhat.com>

 net/ipv4/netfilter/ip_conntrack_core.c |   31 ++++++++++++++++++++++---------
 1 files changed, 22 insertions(+), 9 deletions(-)


ChangeSet@1.1807.17.6, 2004-07-24 22:45:50-07:00, laforge@netfilter.org
  [NETFILTER]: Connection based accounting
  
  This patch adds a config option to enable per-flow packet and byte
  accounting to ip_conntrack. 
  
  Signed-off-by: Harald Welte <laforge@netfilter.org>
  Signed-off-by: David S. Miller <davem@redhat.com>

 include/linux/netfilter_ipv4/ip_conntrack.h     |   17 +++++++++++++--
 net/ipv4/netfilter/Kconfig                      |    4 +++
 net/ipv4/netfilter/ip_conntrack_amanda.c        |    2 -
 net/ipv4/netfilter/ip_conntrack_core.c          |   26 ++++++++++++++++++++----
 net/ipv4/netfilter/ip_conntrack_proto_generic.c |    4 +--
 net/ipv4/netfilter/ip_conntrack_proto_icmp.c    |    2 -
 net/ipv4/netfilter/ip_conntrack_proto_tcp.c     |    2 -
 net/ipv4/netfilter/ip_conntrack_proto_udp.c     |    7 +++---
 net/ipv4/netfilter/ip_conntrack_standalone.c    |   17 ++++++++++++++-
 9 files changed, 66 insertions(+), 15 deletions(-)


ChangeSet@1.1807.17.7, 2004-07-24 23:00:49-07:00, laforge@netfilter.org
  [NETFILTER]: Move /proc/net/ip_conntrack to seq_file
  
  This patch makes ip_conntrack use the seq_file API
  
  Signed-off-by: Harald Welte <laforge@netfilter.org>
  Signed-off-by: David S. Miller <davem@redhat.com>

 include/linux/netfilter_ipv4/ip_conntrack_protocol.h |    5 
 net/ipv4/netfilter/ip_conntrack_standalone.c         |  297 ++++++++++++-------
 2 files changed, 198 insertions(+), 104 deletions(-)


ChangeSet@1.1807.17.8, 2004-07-24 23:03:50-07:00, laforge@netfilter.org
  [NETFILTER]: New ip_sctp match
  
  This patch adds ipt_sctp, enabling iptables to match on sctp ports and
  chunktypes.
  
  Signed-off-by: Kiran Kumar Immidi <immidi_kiran@yahoo.com>
  Signed-off-by: Harald Welte <laforge@netfilter.org>
  Signed-off-by: David S. Miller <davem@redhat.com>

 include/linux/netfilter_ipv4/ipt_sctp.h |  107 +++++++++++++++++
 net/ipv4/netfilter/Kconfig              |    4 
 net/ipv4/netfilter/Makefile             |    1 
 net/ipv4/netfilter/ipt_sctp.c           |  201 ++++++++++++++++++++++++++++++++
 4 files changed, 313 insertions(+)


ChangeSet@1.1807.17.9, 2004-07-24 23:04:41-07:00, laforge@netfilter.org
  [NETFILTER]: Make 'helper' list of ip_nat_core static
  
  This patch makes the 'helper' symbol static to not pollute the namespace
  
  Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
  Signed-off-by: Harald Welte <laforge@netfilter.org>
  Signed-off-by: David S. Miller <davem@redhat.com>

 include/linux/netfilter_ipv4/ip_nat_helper.h |    5 +++--
 net/ipv4/netfilter/ip_nat_core.c             |   11 +----------
 net/ipv4/netfilter/ip_nat_helper.c           |   13 +++++++++++++
 3 files changed, 17 insertions(+), 12 deletions(-)


ChangeSet@1.1807.17.10, 2004-07-24 23:05:28-07:00, laforge@netfilter.org
  [NETFILTER]: init_conntrack() optimization
  
  This patch optimizes the code path during init_conntrack()
  
  Signed-off-by: Pablo Neira <pablo@eurodev.net>
  Signed-off-by: Harald Welte <laforge@netfilter.org>
  Signed-off-by: David S. Miller <davem@redhat.com>

 net/ipv4/netfilter/ip_conntrack_core.c |   51 ++++++++++++++++++---------------
 1 files changed, 29 insertions(+), 22 deletions(-)


ChangeSet@1.1807.17.11, 2004-07-24 23:06:12-07:00, laforge@netfilter.org
  [NETFILTER]: Move error tracking into conntrack protocol helper
  
  This patch moves icmp_error_track out of the generic conntrack core and
  into the icmp helper, where it really belongs.  It also adds some
  generic infrastructure for logging packets that are 'out of spec'.
  
  Signed-off-by: Pablo Neira <pablo@eurodev.net>
  Signed-off-by: Harald Welte <laforge@netfilter.org>
  Signed-off-by: David S. Miller <davem@redhat.com>

 include/linux/netfilter_ipv4/ip_conntrack_core.h     |   20 +-
 include/linux/netfilter_ipv4/ip_conntrack_protocol.h |   16 +
 net/ipv4/netfilter/ip_conntrack_core.c               |  113 ++------------
 net/ipv4/netfilter/ip_conntrack_proto_generic.c      |   16 +
 net/ipv4/netfilter/ip_conntrack_proto_icmp.c         |  153 ++++++++++++++++++-
 net/ipv4/netfilter/ip_conntrack_proto_tcp.c          |   16 +
 net/ipv4/netfilter/ip_conntrack_proto_udp.c          |   63 +++++++
 net/ipv4/netfilter/ip_conntrack_standalone.c         |   16 +
 net/ipv4/netfilter/ip_fw_compat_masq.c               |    7 
 9 files changed, 299 insertions(+), 121 deletions(-)


ChangeSet@1.1807.17.12, 2004-07-24 23:06:51-07:00, laforge@netfilter.org
  [NETFILTER]: Add conntrack runtime statistics
  
  This patch adds some runtime-statistics to the connection tracking core,
  pretty similar to what 'rtstat' does for the routing cache.
  
  This was the last patch in this incremental set.  The only thing I still
  have pending at this time is the tcp window tracking code.  
  
  Signed-off-by: Martin Josefsson <gandalf@wlug.westbo.se>
  Signed-off-by: Harald Welte <laforge@netfilter.org>
  Signed-off-by: David S. Miller <davem@redhat.com>

 include/linux/netfilter_ipv4/ip_conntrack.h  |   20 +++++
 net/ipv4/netfilter/ip_conntrack_core.c       |   55 ++++++++++++---
 net/ipv4/netfilter/ip_conntrack_standalone.c |   96 ++++++++++++++++++++++++++-
 3 files changed, 158 insertions(+), 13 deletions(-)


ChangeSet@1.1807.17.13, 2004-07-24 23:08:32-07:00, laforge@netfilter.org
  [NETFILTER]: Add tcp window tracking
  
  This is the tcp window tracking patch, incremental to all previous
  changes.  It is now by default enabled (i.e. in 'conservative' mode).
  If you think it's better to leave it disabled ('liberal' mode), you can
  change ip_conntrack_tcp_be_liberal to a different default value.
  
  Cheers,
  
  Signed-off-by: Jozsef Kadlecski <kadlec@blackhole.kfki.hu>
  Signed-off-by: Harald Welte <laforge@netfilter.org>
  Signed-off-by: David S. Miller <davem@redhat.com>

 include/linux/netfilter_ipv4/ip_conntrack.h     |    5 
 include/linux/netfilter_ipv4/ip_conntrack_tcp.h |   37 
 net/ipv4/netfilter/ip_conntrack_core.c          |    7 
 net/ipv4/netfilter/ip_conntrack_proto_tcp.c     | 1007 +++++++++++++++++++++---
 net/ipv4/netfilter/ip_conntrack_standalone.c    |   36 
 5 files changed, 976 insertions(+), 116 deletions(-)


ChangeSet@1.1807.17.14, 2004-07-25 16:36:20-07:00, laforge@netfilter.org
  [NETFILTER]: Missing sysctl.h bits from tcp window tracking changes.
  
  Signed-off-by: Harald Welte <laforge@netfilter.org>
  Signed-off-by: David S. Miller <davem@redhat.com>

 include/linux/sysctl.h |    5 +++++
 1 files changed, 5 insertions(+)


ChangeSet@1.1807.17.15, 2004-08-01 19:18:41-07:00, laforge@netfilter.org
  [NETFILTER]: New ip_conntrack_sctp
  
  Incremental to all other patches so far, there is also the new SCTP
  conntrack helper by Kiran Kumar.  Please apply for 2.6.9 ++, thanks.
  
  Signed-off-by: Kiran Kumar Immidi <immidi_kiran@yahoo.com>
  Signed-off-by: Harald Welte <laforge@netfilter.org>
  Signed-off-by: David S. Miller <davem@redhat.com>

 include/linux/netfilter_ipv4/ip_conntrack.h       |    2 
 include/linux/netfilter_ipv4/ip_conntrack_sctp.h  |   25 
 include/linux/netfilter_ipv4/ip_conntrack_tuple.h |    6 
 include/linux/sysctl.h                            |    7 
 net/ipv4/netfilter/Kconfig                        |    4 
 net/ipv4/netfilter/Makefile                       |    3 
 net/ipv4/netfilter/ip_conntrack_proto_sctp.c      |  650 ++++++++++++++++++++++
 7 files changed, 697 insertions(+)


ChangeSet@1.1807.17.16, 2004-08-01 19:27:26-07:00, laforge@netfilter.org
  [NETFILTER]: Fix broken debug assertion
  
  This patch fixes some more broken netfilter assertions in 2.6.x.
  
  Signed-off-by: Patrick McHardy <kaber@trash.net>
  Signed-off-by: Harald Welte <laforge@netfilter.org>
  Signed-off-by: David S. Miller <davem@redhat.com>

 net/ipv4/netfilter/ip_nat_rule.c    |    3 ++-
 net/ipv4/netfilter/ipt_MASQUERADE.c |    4 ++--
 2 files changed, 4 insertions(+), 3 deletions(-)


ChangeSet@1.1838, 2004-08-15 19:06:03-07:00, hch@lst.de
  [ATM]: Missing static in atm.
  
  Signed-off-by: Christoph Hellwig <hch@lst.de>
  Signed-off-by: David S. Miller <davem@redhat.com>

 net/atm/clip.c     |    4 ++--
 net/atm/ipcommon.h |    3 ---
 2 files changed, 2 insertions(+), 5 deletions(-)


ChangeSet@1.1839, 2004-08-15 19:06:49-07:00, hch@lst.de
  [NET]: Add missing struct net_device forward decl to skbuff.h
  
  Signed-off-by: Christoph Hellwig <hch@lst.de>
  Signed-off-by: David S. Miller <davem@redhat.com>

 include/linux/skbuff.h |    2 ++
 1 files changed, 2 insertions(+)


ChangeSet@1.1840, 2004-08-15 19:09:07-07:00, kaber@trash.net
  [RBTREE]: Add rb_last()
  
  Signed-off-by: Patrick McHardy <kaber@trash.net>
  Signed-off-by: David S. Miller <davem@redhat.com>

 include/linux/rbtree.h |    1 +
 lib/rbtree.c           |   13 +++++++++++++
 2 files changed, 14 insertions(+)


ChangeSet@1.1841, 2004-08-15 19:09:51-07:00, kaber@trash.net
  [NET_SCHED]: Replace eligible list by rbtree in HFSC scheduler.
  
  Signed-off-by: Patrick McHardy <kaber@trash.net>
  Signed-off-by: David S. Miller <davem@redhat.com>

 net/sched/sch_hfsc.c |  111 +++++++++++++++++++--------------------------------
 1 files changed, 42 insertions(+), 69 deletions(-)


ChangeSet@1.1842, 2004-08-15 19:10:33-07:00, kaber@trash.net
  [NET_SCHED]: Replace actlist by rbtrees in HFSC scheduler.
  
  Signed-off-by: Patrick McHardy <kaber@trash.net>
  Signed-off-by: David S. Miller <davem@redhat.com>

 net/sched/sch_hfsc.c |  182 +++++++++++++++++++++++++--------------------------
 1 files changed, 92 insertions(+), 90 deletions(-)


ChangeSet@1.1843, 2004-08-15 19:11:12-07:00, kaber@trash.net
  [NET_SCHED]: O(1) children vtoff adjustment in HFSC scheduler
  
  Signed-off-by: Patrick McHardy <kaber@trash.net>
  Signed-off-by: David S. Miller <davem@redhat.com>

 net/sched/sch_hfsc.c |   23 +++++++++++++++--------
 1 files changed, 15 insertions(+), 8 deletions(-)


ChangeSet@1.1844, 2004-08-15 19:30:51-07:00, herbert@gondor.apana.org.au
  [IPV6]: Add missing XFRM select in Kconfig.
  
  Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
  Signed-off-by: David S. Miller <davem@redhat.com>

 net/ipv6/Kconfig |    1 +
 1 files changed, 1 insertion(+)


ChangeSet@1.1845, 2004-08-15 19:33:16-07:00, kaber@trash.net
  [PKT_SCHED]: cacheline-align qdisc data in qdisc_create()
  
  Signed-off-by: Patrick McHardy <kaber@trash.net>
  Signed-off-by: David S. Miller <davem@redhat.com>

 net/sched/sch_api.c |   21 +++++++++++++--------
 1 files changed, 13 insertions(+), 8 deletions(-)


ChangeSet@1.1846, 2004-08-15 19:38:31-07:00, herbert@gondor.apana.org.au
  [XFRM_USER]: Fill in x->props algo fields.
  
  Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
  Signed-off-by: David S. Miller <davem@redhat.com>

 net/xfrm/xfrm_user.c |   23 +++++++++++++++++++----
 1 files changed, 19 insertions(+), 4 deletions(-)


ChangeSet@1.1847, 2004-08-15 19:41:47-07:00, herbert@gondor.apana.org.au
  [IPV6]: Fix aalg check in esp.
  
  Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
  Signed-off-by: David S. Miller <davem@redhat.com>

 net/ipv6/esp6.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)


ChangeSet@1.1849, 2004-08-16 14:09:34-07:00, cp@absolutedigital.net
  [IPV4]: Delete bogus newline in first TcpExt procsfs line.
  
  Signed-off-by: Cal Peake <cp@absolutedigital.net>
  Signed-off-by: David S. Miller <davem@redhat.com>

 net/ipv4/proc.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)


ChangeSet@1.1850, 2004-08-16 14:11:08-07:00, hch@lst.de
  [NET]: Missing header includes and forward declarations.
  
  Signed-off-by: Christoph Hellwig <hch@lst.de>
  Signed-off-by: David S. Miller <davem@redhat.com>

 include/linux/netlink.h |    1 +
 include/net/ip6_fib.h   |    1 +
 include/net/ip6_route.h |    2 ++
 include/net/neighbour.h |    3 +++
 4 files changed, 7 insertions(+)


ChangeSet@1.1851, 2004-08-16 17:03:08-07:00, kaber@trash.net
  [PKT_SCHED]: Resolve race condition with module unload in qdisc_create()
  
  This patch resolves the race condition with module unload
  in qdisc_create by moving try_module_get up to the first
  qdisc_lookup_ops call.
  
  Signed-off-by: Patrick McHardy <kaber@trash.net>
  Signed-off-by: David S. Miller <davem@redhat.com>

 net/sched/sch_api.c |   19 ++++++-------------
 1 files changed, 6 insertions(+), 13 deletions(-)


ChangeSet@1.1852, 2004-08-16 17:10:00-07:00, kaber@trash.net
  [PKT_SCHED]: Remove unnecessary memsets in packet schedulers
  
  This patch removes some more unnecessary memsets in packet
  schedulers. The qdisc's private data is already set to 0
  in qdisc_create/qdisc_create_dflt.
  
  Signed-off-by: Patrick McHardy <kaber@trash.net>
  Signed-off-by: David S. Miller <davem@redhat.com>

 net/sched/sch_atm.c     |    1 -
 net/sched/sch_dsmark.c  |    2 --
 net/sched/sch_hfsc.c    |    1 -
 net/sched/sch_htb.c     |    1 -
 net/sched/sch_ingress.c |    8 --------
 5 files changed, 13 deletions(-)


ChangeSet@1.1837.1.1, 2004-08-18 22:39:42+09:00, yoshfuji@linux-ipv6.org
  [XFRM] Fix selector comparison against icmp{,v6} flows.
  
  Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

 include/net/xfrm.h |   46 ++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 42 insertions(+), 4 deletions(-)


ChangeSet@1.1837.1.2, 2004-08-18 22:42:00+09:00, nakam@linux-ipv6.org
  [IPV6] XFRM: decode icmpv6 session.
  
  Signed-off-by: Masahide Nakamura <nakam@linux-ipv6.org>
  Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

 net/ipv6/xfrm6_policy.c |   10 ++++++++++
 1 files changed, 10 insertions(+)


ChangeSet@1.1837.1.3, 2004-08-18 22:43:52+09:00, nakam@linux-ipv6.org
  [IPV6] XFRM: probe icmpv6 type/code when sending packets via raw socket.
  
  Signed-off-by: Masahide Nakamura <nakam@linux-ipv6.org>
  Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

 net/ipv6/raw.c |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 48 insertions(+)


ChangeSet@1.1837.1.4, 2004-08-18 22:45:29+09:00, nakam@linux-ipv6.org
  [IPV4] XFRM: decode icmp session.
  
  Signed-off-by: Masahide Nakamura <nakam@linux-ipv6.org>
  Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

 net/ipv4/xfrm4_policy.c |    9 +++++++++
 1 files changed, 9 insertions(+)


ChangeSet@1.1837.1.5, 2004-08-18 22:51:21+09:00, nakam@linux-ipv6.org
  [IPV4] XFRM: probe icmp type/code when sending packets via raw socket.
  
  Signed-off-by: Masahide Nakamura <nakam@linux-ipv6.org>
  Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

 net/ipv4/raw.c |   47 +++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 47 insertions(+)


ChangeSet@1.1837.1.6, 2004-08-18 22:56:49+09:00, yoshfuji@linux-ipv6.org
  [IPV4] XFRM: don't probe icmp type/code for hdrincl sockets.
  
  Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

 net/ipv4/raw.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)


ChangeSet@1.1853, 2004-08-18 14:28:05-07:00, davem@nuts.davemloft.net
  [IPV4]: Fix theoretical loop on SMP in ip_evictor().
  
  Snapshot the amount of work to do, and just do it.
  In this way we avoid a theoretical loop whereby
  one cpu sits in ip_evictor() tossing fragments
  while another keeps adding a fragment just as we
  bring ip_frag_mem  down below the low threshold.
  
  Signed-off-by: David S. Miller <davem@redhat.com>

 net/ipv4/ip_fragment.c |   37 ++++++++++++++++++++++---------------
 1 files changed, 22 insertions(+), 15 deletions(-)


ChangeSet@1.1854, 2004-08-18 14:34:14-07:00, davem@nuts.davemloft.net
  [IPV6]: ip6_evictor() has same problem as ip_evictor().
  
  Signed-off-by: David S. Miller <davem@redhat.com>

 net/ipv6/reassembly.c |   37 ++++++++++++++++++++++---------------
 1 files changed, 22 insertions(+), 15 deletions(-)


ChangeSet@1.1855, 2004-08-18 14:35:21-07:00, shemminger@osdl.org
  [ATALK]: Fix build with SYSCTL=n
  
  Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
  Signed-off-by: David S. Miller <davem@redhat.com>

 include/linux/atalk.h            |   29 ++++++++++++++++++++++++++---
 net/appletalk/Makefile           |    3 ++-
 net/appletalk/atalk_proc.c       |   13 -------------
 net/appletalk/ddp.c              |   10 ----------
 net/appletalk/sysctl_net_atalk.c |   18 ++----------------
 5 files changed, 30 insertions(+), 43 deletions(-)


ChangeSet@1.1856, 2004-08-18 14:36:22-07:00, yoshfuji@linux-ipv6.org
  [DECONET]: Fix build with SYSCTL=n
  
  Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
  Signed-off-by: David S. Miller <davem@redhat.com>

 net/decnet/dn_dev.c |  122 ++++++++++++++++++++++++++--------------------------
 1 files changed, 61 insertions(+), 61 deletions(-)


ChangeSet@1.1857, 2004-08-18 14:39:07-07:00, wli@holomorphy.com
  [RXRPC]: Fix build with SYSCTL=n
  
  Signed-off-by: William Lee Irwin III <wli@holomorphy.com>
  Signed-off-by: David S. Miller <davem@redhat.com>

 include/rxrpc/rxrpc.h |    7 +++++++
 1 files changed, 7 insertions(+)


ChangeSet@1.1858, 2004-08-18 14:43:08-07:00, herbert@gondor.apana.org.au
  [XFRM]: Kill unused flow_hash
  
  This patch removes a left-over from the days when the flow cache lived
  in xfrm_policy.c.
  
  Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
  Signed-off-by: David S. Miller <davem@redhat.com>

 include/net/xfrm.h |   41 -----------------------------------------
 1 files changed, 41 deletions(-)


ChangeSet@1.1859, 2004-08-18 14:51:44-07:00, herbert@gondor.apana.org.au
  [IPSEC]: Call xfrm6_rcv in xfrm6_tunnel_rcv
  
  This patch reuses the code in xfrm6_input.c for receiving xfrm6_tunnel
  packets.  This removes duplicate code as well as fixing the bugs unique
  to xfrm6_tunnel_input.  For example, it didn't move the MAC header down.
  Nor did it do anything with ECN.
  
  Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
  Signed-off-by: David S. Miller <davem@redhat.com>

 include/net/xfrm.h      |    1 
 net/ipv6/xfrm6_input.c  |   15 +++++++++++---
 net/ipv6/xfrm6_tunnel.c |   51 ++----------------------------------------------
 3 files changed, 16 insertions(+), 51 deletions(-)


ChangeSet@1.1860, 2004-08-18 15:13:50-07:00, davem@nuts.davemloft.net
  Merge nuts.davemloft.net:/disk1/BK/xfrm-icmp-2.6
  into nuts.davemloft.net:/disk1/BK/net-2.6

 include/net/xfrm.h |   46 ++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 42 insertions(+), 4 deletions(-)


ChangeSet@1.1861, 2004-08-18 16:08:44-07:00, davem@nuts.davemloft.net
  Merge nuts.davemloft.net:/disk1/BK/nf-2.6.9
  into nuts.davemloft.net:/disk1/BK/net-2.6

 include/linux/sysctl.h                 |   12 ++++++++++++
 net/ipv4/netfilter/ip_nat_snmp_basic.c |    6 +++++-
 2 files changed, 17 insertions(+), 1 deletion(-)


ChangeSet@1.1862, 2004-08-18 17:07:13-07:00, davem@nuts.davemloft.net
  [NETFILTER]: Convert SCTP conntrack over to ip_ct_refresh_acct(). 
  
  Signed-off-by: David S. Miller <davem@redhat.com>

 net/ipv4/netfilter/ip_conntrack_proto_sctp.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)


ChangeSet@1.1863, 2004-08-18 17:09:57-07:00, davem@nuts.davemloft.net
  [NETFILTER]: Export ip_conntrack_count for ip_conntrack_standalone.
  
  Signed-off-by: David S. Miller <davem@redhat.com>

 net/ipv4/netfilter/ip_conntrack_core.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletion(-)


ChangeSet@1.1864, 2004-08-18 17:11:57-07:00, davem@nuts.davemloft.net
  [NETFILTER]: Need to export ip_ct_log_invalid to modules.

 net/ipv4/netfilter/ip_conntrack_standalone.c |    1 +
 1 files changed, 1 insertion(+)


ChangeSet@1.1865, 2004-08-18 17:15:29-07:00, davem@nuts.davemloft.net
  [NET]: Add skb_header_pointer, and use it where possible.
  
  This greatly improves netfilter performance where
  the wanted header area is in the linear SKB data
  area, therefore no copy into the temporary buffer
  is needed.
  
  Signed-off-by: David S. Miller <davem@redhat.com>

 include/linux/skbuff.h                       |   14 ++
 net/bridge/netfilter/ebt_among.c             |   49 ++++---
 net/bridge/netfilter/ebt_arp.c               |   51 ++++----
 net/bridge/netfilter/ebt_arpreply.c          |   32 +++--
 net/bridge/netfilter/ebt_ip.c                |   31 ++--
 net/bridge/netfilter/ebt_log.c               |   54 +++++---
 net/bridge/netfilter/ebt_stp.c               |   22 ++-
 net/bridge/netfilter/ebt_vlan.c              |    9 -
 net/core/filter.c                            |   21 +--
 net/core/netfilter.c                         |    9 -
 net/ipv4/icmp.c                              |   29 ++--
 net/ipv4/ipvs/ip_vs_core.c                   |  104 +++++++++-------
 net/ipv4/ipvs/ip_vs_proto.c                  |   42 +++---
 net/ipv4/ipvs/ip_vs_proto_ah.c               |    9 -
 net/ipv4/ipvs/ip_vs_proto_esp.c              |    9 -
 net/ipv4/ipvs/ip_vs_proto_icmp.c             |   33 +++--
 net/ipv4/ipvs/ip_vs_proto_tcp.c              |   44 ++++---
 net/ipv4/ipvs/ip_vs_proto_udp.c              |   42 +++---
 net/ipv4/ipvs/ip_vs_xmit.c                   |    9 -
 net/ipv4/netfilter/ip_conntrack_amanda.c     |   12 +
 net/ipv4/netfilter/ip_conntrack_ftp.c        |   31 ++--
 net/ipv4/netfilter/ip_conntrack_irc.c        |   26 ++--
 net/ipv4/netfilter/ip_conntrack_proto_icmp.c |   11 -
 net/ipv4/netfilter/ip_conntrack_proto_tcp.c  |  115 +++++++++---------
 net/ipv4/netfilter/ip_conntrack_proto_udp.c  |    9 -
 net/ipv4/netfilter/ip_conntrack_tftp.c       |   10 -
 net/ipv4/netfilter/ip_nat_standalone.c       |   10 -
 net/ipv4/netfilter/ip_nat_tftp.c             |   25 ++--
 net/ipv4/netfilter/ip_tables.c               |   53 +++++---
 net/ipv4/netfilter/ipchains_core.c           |   42 +++---
 net/ipv4/netfilter/ipfwadm_core.c            |   42 +++---
 net/ipv4/netfilter/ipt_ECN.c                 |   29 ++--
 net/ipv4/netfilter/ipt_LOG.c                 |  168 ++++++++++++++-------------
 net/ipv4/netfilter/ipt_REJECT.c              |   15 +-
 net/ipv4/netfilter/ipt_ah.c                  |   11 +
 net/ipv4/netfilter/ipt_ecn.c                 |   17 +-
 net/ipv4/netfilter/ipt_esp.c                 |   11 +
 net/ipv4/netfilter/ipt_multiport.c           |   19 +--
 net/ipv4/netfilter/ipt_tcpmss.c              |   30 +++-
 net/ipv6/exthdrs_core.c                      |   27 ++--
 net/ipv6/icmp.c                              |   17 +-
 net/rxrpc/call.c                             |   57 ++++-----
 net/sunrpc/xprt.c                            |    8 -
 security/selinux/hooks.c                     |   72 ++++++-----
 44 files changed, 842 insertions(+), 638 deletions(-)
