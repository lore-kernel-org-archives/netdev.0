From: "=?UTF-8?q?Bendik=20R=C3=B8nning=20Opstad?=" <bro.devel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH RFC net-next 0/2] tcp: Redundant Data Bundling (RDB)
Date: Fri, 23 Oct 2015 22:50:11 +0200
Message-ID: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Neal Cardwell <ncardwell-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
	Yuchung Cheng <ycheng-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Erik Kline <ek-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
	Alexander Duyck <alexander.h.duyck-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>,
	Daniel Lee <Longinus00-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Marcelo Ricardo Leitner <mleitner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing-djzkFPsfvsizQB+pC5nmwQ@public.gmane.org>,
	linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andreas Petlund <apetlund-S8y2klWGCOFhl2p70BpVqQ@public.gmane.org>,
	Carsten Griwodz <griff-S8y2klWGCOFhl2p70BpVqQ@public.gmane.org>,
	=?UTF-8?q?P=C3=A5l=20Halvorsen?= <paalh-S8y2klWGCOFhl2p70BpVqQ@public.gmane.org>,
	Jonas Markussen <j
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


This is a request for comments.

Redundant Data Bundling (RDB) is a mechanism for TCP aimed at reducing
the latency for applications sending time-dependent data.
Latency-sensitive applications or services, such as online games and
remote desktop, produce traffic with thin-stream characteristics,
characterized by small packets and a relatively high ITT. By bundling
already sent data in packets with new data, RDB alleviates head-of-line
blocking by reducing the need to retransmit data segments when packets
are lost. RDB is a continuation on the work on latency improvements for
TCP in Linux, previously resulting in two thin-stream mechanisms in the
Linux kernel
(https://github.com/torvalds/linux/blob/master/Documentation/networking=
/tcp-thin.txt).

The RDB implementation has been thoroughly tested, and shows
significant latency reductions when packet loss occurs[1]. The tests
show that, by imposing restrictions on the bundling rate, it can be mad=
e
not to negatively affect competing traffic in an unfair manner.

Note: Current patch set depends on a recently submitted patch for
tcp_skb_cb (tcp: refactor struct tcp_skb_cb: http://patchwork.ozlabs.or=
g/patch/510674)

These patches have been tested with as set of packetdrill scripts locat=
ed at
https://github.com/bendikro/packetdrill/tree/master/gtests/net/packetdr=
ill/tests/linux/rdb
(The tests require patching packetdrill with a new socket option:
https://github.com/bendikro/packetdrill/commit/9916b6c53e33dd04329d29b7=
d8baf703b2c2ac1b)

Detailed info about the RDB mechanism can be found at
http://mlab.no/blog/2015/10/redundant-data-bundling-in-tcp, as well as =
in the paper
"Latency and Fairness Trade-Off for Thin Streams using Redundant Data
Bundling in TCP"[2].

[1] http://home.ifi.uio.no/paalh/students/BendikOpstad.pdf
[2] http://home.ifi.uio.no/bendiko/rdb_fairness_tradeoff.pdf


Bendik R=C3=B8nning Opstad (2):
  tcp: Add DPIFL thin stream detection mechanism
  tcp: Add Redundant Data Bundling (RDB)

 Documentation/networking/ip-sysctl.txt |  23 +++
 include/linux/skbuff.h                 |   1 +
 include/linux/tcp.h                    |   9 +-
 include/net/tcp.h                      |  34 ++++
 include/uapi/linux/tcp.h               |   1 +
 net/core/skbuff.c                      |   3 +-
 net/ipv4/Makefile                      |   3 +-
 net/ipv4/sysctl_net_ipv4.c             |  35 ++++
 net/ipv4/tcp.c                         |  19 ++-
 net/ipv4/tcp_input.c                   |   3 +
 net/ipv4/tcp_output.c                  |  11 +-
 net/ipv4/tcp_rdb.c                     | 281 +++++++++++++++++++++++++=
++++++++
 12 files changed, 415 insertions(+), 8 deletions(-)
 create mode 100644 net/ipv4/tcp_rdb.c

--=20
1.9.1
