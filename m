From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH iproute2 net-next v1 7/7] tipc: update man
	page for link monitor
Date: Mon, 12 Sep 2016 17:17:21 +0200
Message-ID: <1473693441-14254-8-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1473693441-14254-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1473693441-14254-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Add description for the new link monitor commands.

Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 man/man8/tipc-link.8 | 104 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 104 insertions(+)

diff --git a/man/man8/tipc-link.8 b/man/man8/tipc-link.8
index 2ee03a0bd96e..fee283e5cfff 100644
--- a/man/man8/tipc-link.8
+++ b/man/man8/tipc-link.8
@@ -39,6 +39,29 @@ tipc-link \- show links or modify link properties
 .B tipc link list
 .br
 
+.ti -8
+.B tipc link monitor set
+.RB "{ " "threshold" " } "
+
+.ti -8
+.B tipc link monitor get
+.RB "{ " "threshold" " } "
+
+.ti -8
+.B tipc link monitor summary
+.br
+
+.ti -8
+.B tipc link monitor list
+.br
+.RB "[ " "media " " { " eth " | " ib " } " device
+.IR "DEVICE" " ]"
+.RB "|"
+.br
+.RB "[ " "media udp name"
+.IR NAME " ]"
+.br
+
 .SH OPTIONS
 Options (flags) that can be passed anywhere in the command chain.
 .TP
@@ -204,6 +227,87 @@ The link window controls how many unacknowledged messages a link endpoint can
 have in its transmit queue before TIPC's congestion control mechanism is
 activated.
 
+.SS Monitor properties
+
+.TP
+.B threshold
+.br
+The threshold specifies the cluster size exceeding which the link monitoring
+algorithm will switch from "full-mesh" to "overlapping-ring".
+If set of 0 the overlapping-ring monitoring is always on and if set to a
+value larger than anticipated cluster size the overlapping-ring is disabled.
+The default value is 32.
+
+.SS Monitor information
+
+.TP
+.B table_generation
+.br
+Represents the event count in a node's local monitoring list. It steps every
+time something changes in the local monitor list, including changes in the
+local domain.
+
+.TP
+.B cluster_size
+.br
+Represents the current count of cluster members.
+
+.TP
+.B algorithm
+.br
+The current supervision algorithm used for neighbour monitoring for the bearer.
+Possible values are full-mesh or overlapping-ring.
+
+.TP
+.B status
+.br
+The node status derived by the local node.
+Possible status are up or down.
+
+.TP
+.B monitored
+.br
+Represent the type of monitoring chosen by the local node.
+Possible values are direct or indirect.
+
+.TP
+.B generation
+.br
+Represents the domain generation which is the event count in a node's local
+domain. Every time something changes (peer add/remove/up/down) the domain
+generation is stepped and a new version of node record is sent to inform
+the neighbors about this change. The domain generation helps the receiver
+of a domain record to know if it should ignore or process the record.
+
+.TP
+.B applied_node_status
+.br
+The node status reported by the peer node for the succeeding peers in
+the node list. The Node list is a circular list of ascending addresses
+starting with the local node.
+Possible status are: U or D. The status U implies up and D down.
+
+.TP
+.B [non_applied_node:status]
+.br
+Represents the nodes and their status as reported by the peer node.
+These nodes were not applied to the monitoring list for this peer node.
+They are usually transient and occur during the cluster startup phase
+or network reconfiguration.
+Possible status are: U or D. The status U implies up and D down.
+
+.SH EXAMPLES
+.PP
+tipc link monitor list
+.RS 4
+Shows the link monitoring information for cluster members on device data0.
+.RE
+.PP
+tipc link monitor summary
+.RS 4
+The monitor summary command prints the basic attributes.
+.RE
+
 .SH EXIT STATUS
 Exit status is 0 if command was successful or a positive integer upon failure.
 
-- 
2.1.4


------------------------------------------------------------------------------
