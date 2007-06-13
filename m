From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [GIT PATCHES] SCTP bugfixes
Date: Wed, 13 Jun 2007 17:23:03 -0400
Message-ID: <11817697833709-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:50795 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752487AbXFMVXH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 17:23:07 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David

Please pull the following SCTP patches from
  master.kernel.org:/pub/scm/linux/kernel/git/vxy/lksctp-dev.git

Thanks
-vlad

The following changes since commit 66e1e3b20cbbf99da63e6c1af0fc6d39c2ed099a:
  David S. Miller (1):
        [TCP]: Set initial_ssthresh default to zero in Cubic and BIC.

are found in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/vxy/lksctp-dev.git

Vlad Yasevich (6):
      [SCTP]: Correctly set daddr for IPv6 sockets during peeloff
      [SCTP]: Allow unspecified port in sctp_bindx()
      [SCTP] Fix leak in sctp_getsockopt_local_addrs when copy_to_user fails
      [SCTP] Update pmtu handling to be similar to tcp
      [SCTP] Flag a pmtu change request
      [SCTP] Don't disable PMTU discovery when mtu is small

 include/net/sctp/sctp.h    |    7 +++++++
 include/net/sctp/structs.h |    7 +++++++
 net/sctp/associola.c       |    4 ++++
 net/sctp/input.c           |   24 +++++++++---------------
 net/sctp/socket.c          |   31 ++++++++++++++++++++++---------
 net/sctp/transport.c       |   39 +++++++++++++++++++++++++++++++++++++++
 6 files changed, 88 insertions(+), 24 deletions(-)

commit 06ad391919b2078ec2e012f0593014b88e7a6c4e
Author: Vlad Yasevich <vladislav.yasevich@hp.com>
Date:   Tue Jun 12 15:26:22 2007 -0400

    [SCTP] Don't disable PMTU discovery when mtu is small
    
    Right now, when we receive a mtu estimate smaller then minim
    threshold in the ICMP message, we disable the path mtu discovery
    on the transport.  This leads to the never increasing sctp fragmentation
    point even when the real path mtu has increased.
    
    Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

commit 8a4794914f9cf2681235ec2311e189fe307c28c7
Author: Vlad Yasevich <vladislav.yasevich@hp.com>
Date:   Thu Jun 7 14:21:05 2007 -0400

    [SCTP] Flag a pmtu change request
    
    Currently, if the socket is owned by the user, we drop the ICMP
    message.  As a result SCTP forgets that path MTU changed and
    never adjusting it's estimate.  This causes all subsequent
    packets to be fragmented.  With this patch, we'll flag the association
    that it needs to udpate it's estimate based on the already updated
    routing information.
    
    Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
    Acked-by: Sridhar Samudrala <sri@us.ibm.com>

commit c910b47e1811b3f8b184108c48de3d7af3e2999b
Author: Vlad Yasevich <vladislav.yasevich@hp.com>
Date:   Thu Jun 7 13:47:03 2007 -0400

    [SCTP] Update pmtu handling to be similar to tcp
    
    Introduce new function sctp_transport_update_pmtu that updates
    the transports and destination caches view of the path mtu.
    
    Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
    Acked-by: Sridhar Samudrala <sri@us.ibm.com>

commit fe979ac169970b3d12facd6565766735862395c5
Author: Vlad Yasevich <vladislav.yasevich@hp.com>
Date:   Wed May 23 11:11:37 2007 -0400

    [SCTP] Fix leak in sctp_getsockopt_local_addrs when copy_to_user fails
    
    If the copy_to_user or copy_user calls fail in sctp_getsockopt_local_addrs(),
    the function should free locally allocated storage before returning error.
    Spotted by Coverity.
    
    Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
    Acked-by: Sridhar Samudrala <sri@us.ibm.com>

commit 8b35805693e1915829355723537f99f1b8bc9cc0
Author: Vlad Yasevich <vladislav.yasevich@hp.com>
Date:   Tue May 15 17:14:58 2007 -0400

    [SCTP]: Allow unspecified port in sctp_bindx()
    
    Allow sctp_bindx() to accept multiple address with
    unspecified port.  In this case, all addresses inherit
    the first bound port.  We still catch full mis-matches.
    
    Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
    Acked-by: Sridhar Samudrala <sri@us.ibm.com>

commit d570ee490fb18220262cfe41284d7aede797ed4f
Author: Vlad Yasevich <vladislav.yasevich@hp.com>
Date:   Tue May 15 16:32:39 2007 -0400

    [SCTP]: Correctly set daddr for IPv6 sockets during peeloff
    
    During peeloff of AF_INET6 socket, the inet6_sk(sk)->daddr
    wasn't set correctly since the code was assuming IPv4 only.
    Now we use a correct call to set the destination address.
    
    Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
    Acked-by: Sridhar Samudrala <sri@us.ibm.com>
