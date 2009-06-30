From: Jiri Olsa <jolsa@redhat.com>
Subject: [PATCHv2 0/2] net: fix race in the receive/select
Date: Tue, 30 Jun 2009 12:36:42 +0200
Message-ID: <20090630103642.GB9657@jolsa.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, fbl@redhat.com, nhorman@redhat.com,
	davem@redhat.com, htejun@gmail.com, jarkao2@gmail.com,
	oleg@redhat.com, davidel@xmailserver.org, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756015AbZF3Kgx@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset fixies the race within the poll_wait call and the receive callbacks,
by adding memory barrier.

- 1/2 includes the actual fix
- 2/2 includes optimization for the x86 arch

It is discussed and described in the following discussions:

http://lkml.org/lkml/2009/6/18/124
http://lkml.org/lkml/2009/6/25/188
http://lkml.org/lkml/2009/6/29/216

Patchset is made on top of Linus'es tree 5a4f13fad1ab5bd08dea78fc55321e429d83cddf .

Booted on x86_64.

wbr,
jirka


---
 arch/x86/include/asm/spinlock.h |    3 ++
 include/linux/spinlock.h        |    5 ++++
 include/net/sock.h              |   40 +++++++++++++++++++++++++++++++++++++++
 net/atm/common.c                |    6 ++--
 net/core/datagram.c             |    2 +-
 net/core/sock.c                 |    8 +++---
 net/dccp/output.c               |    2 +-
 net/dccp/proto.c                |    2 +-
 net/ipv4/tcp.c                  |    2 +-
 net/iucv/af_iucv.c              |    4 +-
 net/rxrpc/af_rxrpc.c            |    4 +-
 net/unix/af_unix.c              |    8 +++---
 12 files changed, 67 insertions(+), 19 deletions(-)
