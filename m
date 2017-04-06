From: "R. Parameswaran" <parameswaran.r7@gmail.com>
Subject: [PATCH net-next v5 0/2] L2TP:Adjust intf MTU, add underlay L3, L2
 hdrs.
Date: Wed, 5 Apr 2017 17:05:49 -0700 (PDT)
Message-ID: <alpine.DEB.2.11.1704051701220.19131@vera98.eng.brocade.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jchapman@katalix.com, kleptog@svana.org, nprachan@brocade.com,
        rshearma@brocade.com, stephen@networkplumber.org,
        sdietric@brocade.com, ciwillia@brocade.com, lboccass@brocade.com,
        dfawcus@brocade.com, bhong@brocade.com, jblunck@brocade.com,
        davem@davemloft.net, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33526 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756357AbdDFAFv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 20:05:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Existing L2TP kernel code does not derive the optimal MTU for Ethernet
pseudowires and instead leaves this to a userspace L2TP daemon or
operator. If an MTU is not specified, the existing kernel code chooses
an MTU that does not take account of all tunnel header overheads, which
can lead to unwanted IP fragmentation. When L2TP is used without a
control plane (userspace daemon), we would prefer that the kernel does a
better job of choosing a default pseudowire MTU, taking account of all
tunnel header overheads, including IP header options, if any. This patch
addresses this.

Change-set is organized as a two part patch series, with one patch
introducing a new kernel function to compute the IP overhead on a
socket, and the other patch using this new kernel function to compute
the default L2TP MTU for an Ethernet pseudowire.

Existing code also seems to assume an Ethernet (non-jumbo) underlay. The
change proposed here uses the PMTU mechanism and the dst entry in the
L2TP tunnel socket to directly pull up the underlay MTU (as the baseline
number on top of which the encapsulation headers are factored in).
An default MTU value of 1500 bytes is assumed as a fallback only if
this fails. 

Fixed the kbuild test robot error in the previous posting.

R. Parameswaran (2):
  New kernel function to get IP overhead on a socket.
  L2TP:Adjust intf MTU, add underlay L3, L2 hdrs.

 include/linux/net.h |  3 +++
 net/l2tp/l2tp_eth.c | 55 +++++++++++++++++++++++++++++++++++++++++++++++++----
 net/socket.c        | 46 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 100 insertions(+), 4 deletions(-)

-- 
2.1.4
