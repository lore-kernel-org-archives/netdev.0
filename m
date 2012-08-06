From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 0/9] sctp: Basic support for network namespaces
Date: Mon, 06 Aug 2012 11:38:09 -0700
Message-ID: <87zk67q31q.fsf_-_@xmission.com>
References: <1344115837-6150-1-git-send-email-jan.ariyasu@hp.com>
	<87mx27rig7.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan Ariyasu <jan.ariyasu@hp.com>,
	Jan Ariyasu <jan.ariyasu@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@infradead.org>, Xi Wang <xi.wang@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87mx27rig7.fsf@xmission.com> (Eric W. Biederman's message of
	"Mon, 06 Aug 2012 11:20:08 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The other day I wanted to play around with sctp and did a basic pass to
make sctp per network namespace, so that I could play more conviniently.
Apparently this is an idea who's time has come because Jan Ariyasu also
made a similar set of changes.

I have played around some with these changes and have confirmed that
sctp_test from lksctp-tools works without problems.

Compared to Jan's changes I have per network namespace association and
endpoint hash table lookups, my patch has per network namespace mib
statistics, my changes don't contiain per network namespace tunables
and my patchset only touches about half as many lines as Jan's change.

So for both correctness and simplicity reasons it looks like the
practical way to handle this is to merge my changes and get Jan rebase
his tunable changes on top.

 include/net/net_namespace.h |    4 +
 include/net/netns/sctp.h    |   37 +++++
 include/net/sctp/sctp.h     |   44 +++----
 include/net/sctp/structs.h  |   28 +----
 net/sctp/associola.c        |    9 +-
 net/sctp/bind_addr.c        |   14 +-
 net/sctp/chunk.c            |    2 +-
 net/sctp/endpointola.c      |   12 +-
 net/sctp/input.c            |  109 +++++++++------
 net/sctp/ipv6.c             |   36 +++---
 net/sctp/output.c           |    2 +-
 net/sctp/outqueue.c         |   18 ++-
 net/sctp/proc.c             |   58 +++++---
 net/sctp/protocol.c         |  305 ++++++++++++++++++++++---------------------
 net/sctp/sm_statefuns.c     |  208 ++++++++++++++++++-----------
 net/sctp/socket.c           |   29 +++--
 net/sctp/ulpqueue.c         |   18 ++-
 17 files changed, 533 insertions(+), 400 deletions(-)


Eric W. Biederman (9):
      sctp: Make the port hash table use struct net in it's key.
      sctp: Make the endpoint hashtable handle multiple network namespaces
      sctp: Make the association hashtable handle multiple network namespaces
      sctp: Make the address lists per network namespace
      sctp: Make the ctl_sock per network namespace
      sctp: Move the percpu sockets counter out of sctp_proc_init
      sctp: Make the proc files per network namespace.
      sctp: Enable sctp in all network namespaces
      sctp: Make the mib per network namespace
