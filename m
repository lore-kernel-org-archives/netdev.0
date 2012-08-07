From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 0/7] sctp: network namespace support Part 2: per net tunables
Date: Tue, 07 Aug 2012 10:17:02 -0700
Message-ID: <87ipcud3ld.fsf_-_@xmission.com>
References: <1344115837-6150-1-git-send-email-jan.ariyasu@hp.com>
	<87mx27rig7.fsf@xmission.com> <87zk67q31q.fsf_-_@xmission.com>
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
In-Reply-To: <87zk67q31q.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Mon, 06 Aug 2012 11:38:09 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Since I am motivated to get things done, and since there has been much
grumbling about my patches not implementing tunables, I have added
tunable support on top of my last patchset.

I have performed basic testing on the these patches and nothing
appears amis.

The sm statemachine is a major tease as it has all of these association
and endpoint pointers in the common set of function parameters that turn
out to be NULL at the most inconvinient times.  So I added to the common
parameter list a struct net pointer, that is never NULL. 

 include/net/netns/sctp.h   |   96 +++++++-
 include/net/sctp/sctp.h    |   16 +-
 include/net/sctp/sm.h      |    8 +-
 include/net/sctp/structs.h |  126 +---------
 net/sctp/associola.c       |   18 +-
 net/sctp/auth.c            |   20 ++-
 net/sctp/bind_addr.c       |    6 +-
 net/sctp/endpointola.c     |   13 +-
 net/sctp/input.c           |    6 +-
 net/sctp/primitive.c       |    4 +-
 net/sctp/protocol.c        |  137 +++++-----
 net/sctp/sm_make_chunk.c   |   61 +++--
 net/sctp/sm_sideeffect.c   |   26 ++-
 net/sctp/sm_statefuns.c    |  631 ++++++++++++++++++++++++--------------------
 net/sctp/sm_statetable.c   |   17 +-
 net/sctp/socket.c          |   92 ++++---
 net/sctp/sysctl.c          |  200 ++++++++------
 net/sctp/transport.c       |   23 +-
 18 files changed, 817 insertions(+), 683 deletions(-)

Eric W. Biederman (7):
      sctp: Add infrastructure for per net sysctls
      sctp: Push struct net down to sctp_chunk_event_lookup
      sctp: Push struct net down into sctp_transport_init
      sctp: Push struct net down into sctp_in_scope
      sctp: Push struct net down into all of the state machine functions
      sctp: Push struct net down into sctp_verify_ext_param
      sctp: Making sysctl tunables per net

Eric
