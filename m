From: "R. Parameswaran" <parameswaran.r7@gmail.com>
Subject: [PATCH net-next v4 0/2] L2TP:Adjust intf MTU, add underlay L3, L2
 hdrs.
Date: Wed, 22 Mar 2017 16:08:27 -0700 (PDT)
Message-ID: <alpine.DEB.2.11.1703221604390.9002@vera100.eng.brocade.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kleptog@svana.org, jchapman@katalix.com, davem@redhat.com,
        nprachan@brocade.com, rshearma@brocade.com,
        stephen@networkplumber.org, sdietric@brocade.com,
        ciwillia@brocade.com, lboccass@brocade.com, dfawcus@brocade.com,
        bhong@brocade.com, jblunck@brocade.com,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


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
    
Signed-off-by: R. Parameswaran <rparames@brocade.com>

R. Parameswaran (2):
  New kernel function to get IP overhead on a socket.
  L2TP:Adjust intf MTU, add underlay L3, L2 hdrs.

 include/linux/net.h |  3 +++
 net/l2tp/l2tp_eth.c | 55 +++++++++++++++++++++++++++++++++++++++++++++++++----
 net/socket.c        | 44 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 98 insertions(+), 4 deletions(-)

-- 
2.1.4
