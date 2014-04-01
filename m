From: Richard Guy Briggs <rgb@redhat.com>
Subject: [PATCH 0/3] netlink: per-protocol bind fixup/enhancement set
Date: Tue,  1 Apr 2014 10:14:55 -0400
Message-ID: <cover.1396317747.git.rgb@redhat.com>
References: <20140324183406.GE28666@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Richard Guy Briggs <rgb@redhat.com>, davem@davemloft.net,
        hadi@mojatatu.com
To: linux-audit@redhat.com, linux-kernel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-audit-bounces@redhat.com>
In-Reply-To: <20140324183406.GE28666@madcap2.tricolour.ca>
List-Unsubscribe: <https://www.redhat.com/mailman/options/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

This set provides a way for per-protocol bind functions to signal an error and
to be able to clean up after themselves.

The first patch has already been accepted, but is included just in case to
avoid a merge error.

The second patch adds the per-protocol bind return code to signal to the
netlink code that no further processing should be done and to undo the work
already done.  This rev has fixed DaveM's last issue and flattened the
intentation as requested by Patrick McHardy by two by reworking the logic.

The third provides a way per protocol to undo actions on DROP.

Thanks for the feedback.

Richard Guy Briggs (3):
  netlink: simplify nfnetlink_bind
  netlink: have netlink per-protocol bind function return an error code.
  netlink: implement unbind to netlink_setsockopt NETLINK_DROP_MEMBERSHIP

 include/linux/netlink.h   |    3 ++-
 net/netfilter/nfnetlink.c |   10 ++++------
 net/netlink/af_netlink.c  |   44 +++++++++++++++++++++++++++++++-------------
 net/netlink/af_netlink.h  |    6 ++++--
 4 files changed, 41 insertions(+), 22 deletions(-)
