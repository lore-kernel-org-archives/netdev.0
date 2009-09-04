From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: pull request: SCTP updates for net-next-2.6
Date: Fri, 04 Sep 2009 18:32:58 -0400
Message-ID: <4AA1959A.30400@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Linux SCTP Dev Mailing list <linux-sctp@vger.kernel.org>,
	"lksctp-developers@lists.sourceforge.net"
	<lksctp-developers@lists.sourceforge.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:1948 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934334AbZIDWc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 18:32:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

Here is an accumulated set of SCTP patches for net-next.  It's a collection
of bug fixes and some new features.

Please let me know if there any problems.

Thanks
-vlad

--

The following changes since commit 8a34e2f8ba7d4302977c90e357921994a6c39af9:
  Sachin Sant (1):
        net: Fix a build break because of a typo in drivers/net/3c503.c

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/vxy/lksctp-dev.git net-next

Alexey Dobriyan (1):
      sctp: use proc_create()

Bhaskar Dutta (1):
      sctp: Sysctl configuration for IPv4 Address Scoping

Doug Graham (1):
      sctp: Fix piggybacked ACKs

Rami Rosen (1):
      sctp: remove unused union (sctp_cmsg_data_t) definition

Vlad Yasevich (18):
      sctp: release cached route when the transport goes down.
      sctp: Disallow new connection on a closing socket
      sctp: Fix data segmentation with small frag_size
      sctp: Generate SACKs when actually sending outbound DATA
      sctp: Try to encourage SACK bundling with DATA.
      sctp: Send user messages to the lower layer as one
      sctp: Fix error count increments that were results of HEARTBEATS
      sctp: Clear fast_recovery on the transport when T3 timer expires.
      sctp: drop a_rwnd to 0 when receive buffer overflows.
      sctp: Try not to change a_rwnd when faking a SACK from SHUTDOWN.
      sctp: Nagle delay should be based on path mtu
      sctp: Don't do NAGLE delay on large writes that were fragmented small
      sctp: Fix SCTP_MAXSEG socket option to comply to spec.
      sctp: Failover transmitted list on transport delete
      sctp: Correctly track if AUTH has been bundled.
      sctp: Turn flags in 'sctp_packet' into bit fields
      sctp: Get rid of an extra routing lookup when adding a transport.
      sctp: Catch bogus stream sequence numbers

Wei Yongjun (8):
      sctp: avoid overwrite the return value of sctp_process_asconf_ack()
      sctp: check the unrecognized ASCONF parameter before access it
      sctp: update the route for non-active transports after addresses are added
      sctp: drop SHUTDOWN chunk if the TSN is less than the CTSN
      sctp: fix check the chunk length of received HEARTBEAT-ACK chunk
      sctp: fix to reset packet information after packet transmit
      sctp: turn flags in 'struct sctp_association' into bit fields
      sctp: remove dup code in net/sctp/output.c

 Documentation/networking/ip-sysctl.txt |   10 ++
 include/net/sctp/command.h             |    3 +
 include/net/sctp/constants.h           |    9 ++-
 include/net/sctp/sctp.h                |    7 +-
 include/net/sctp/structs.h             |   63 ++++++-----
 include/net/sctp/user.h                |    6 -
 net/sctp/associola.c                   |   93 ++++++++++++++--
 net/sctp/bind_addr.c                   |   21 ++++-
 net/sctp/chunk.c                       |   62 +++++++++--
 net/sctp/output.c                      |  188 +++++++++++++++++++-------------
 net/sctp/outqueue.c                    |   47 ++++++--
 net/sctp/proc.c                        |    4 +-
 net/sctp/protocol.c                    |   11 +-
 net/sctp/sm_make_chunk.c               |   25 +++--
 net/sctp/sm_sideeffect.c               |   56 ++++++++--
 net/sctp/sm_statefuns.c                |   68 ++++++++++-
 net/sctp/socket.c                      |   38 +++----
 net/sctp/sysctl.c                      |   12 ++
 net/sctp/transport.c                   |    3 +
 19 files changed, 519 insertions(+), 207 deletions(-)

