From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH v2] sctp: Add documentation for sctp sysctl variable
Date: Tue,  8 Jul 2008 16:56:28 -0400
Message-ID: <1215550588-10223-1-git-send-email-vladislav.yasevich@hp.com>
References: <20080708133158.0c39d355.randy.dunlap@oracle.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	randy.dunlap@oracle.com, Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:9729 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932AbYGHU4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 16:56:31 -0400
In-Reply-To: <20080708133158.0c39d355.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 Documentation/networking/ip-sysctl.txt |  168 ++++++++++++++++++++++++++++++++
 1 files changed, 168 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 17a6e46..c56f70e 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1064,6 +1064,174 @@ bridge-nf-filter-pppoe-tagged - BOOLEAN
 	Default: 1
 
 
+proc/sys/net/sctp/* Variables:
+
+addip_enable - BOOLEAN
+	Enable or disable extension of  Dynamic Address Reconfiguration
+	(ADD-IP) functionality specified in RFC5061.  This extension provides
+	the ability to dynamically add and remove new addresses for the SCTP
+	associations.
+
+	1: Enable extension.
+
+        0: Disable extension.
+
+	Default: 0
+
+addip_noauth_enable - BOOLEAN
+	Dynamic Address Reconfiguration (ADD-IP) requires the use of
+	authentication to protect the operations of adding or removing new
+	addresses.  This requirement is mandated so that unauthorized hosts
+	would not be able to hijack associations.  However, older
+	implementations may not have implemented this requirement while
+	allowing the ADD-IP extension.  For reasons of interoperability,
+	we provide this variable to control the enforcement of the
+	authentication requirement.
+
+	1: Allow ADD-IP extension to be used without authentication.  This
+	   should only be set in a closed environment for interoperability
+	   with older implementations.
+
+	0: Enforce the authentication requirement
+
+	Default: 0
+	
+auth_enable - BOOLEAN
+	Enable or disable Authenticated Chunks extension.  This extension
+	provides the ability to send and receive authenticated chunks and is
+	required for secure operation of Dynamic Address Reconfiguration
+	(ADD-IP) extension.
+
+	1: Enable this extension.
+	0: Disable this extension.
+
+	Default: 0
+
+prsctp_enable - BOOLEAN
+	Enable or disable the Partial Reliability extension (RFC3758) which
+	is used to notify peers that a given DATA should no longer be expected.
+
+	1: Enable extension
+	0: Disable
+
+	Default: 1
+
+max_burst - INTEGER
+	The limit of the number of new packets that can be initially sent.  It
+	controls how bursty the generated traffic can be.
+
+	Default: 4
+
+association_max_retrans - INTEGER
+	Set the maximum number for retransmissions that an association can
+	attempt deciding that the remote end is unreachable.  If this value
+	is exceeded, the association is terminated.
+
+	Default: 10
+
+max_init_retransmits - INTEGER
+	The maximum number of retransmissions of INIT and COOKIE-ECHO chunks
+	that an association will attempt before declaring the destination
+	unreachable and terminating.
+
+	Default: 8
+
+path_max_retrans - INTEGER
+	The maximum number of retransmissions that will be attempted on a given
+	path.  Once this threshold is exceeded, the path is considered
+	unreachable, and new traffic will use a different path when the
+	association is multihomed.
+
+	Default: 5
+
+rto_initial - INTEGER
+	The initial round trip timeout value in milliseconds that will be used
+	in calculating round trip times.  This is the initial time interval
+	for retransmissions.
+
+	Default: 3000
+
+rto_max - INTEGER
+	The maximum value (in milliseconds) of the round trip timeout.  This
+	is the largest time interval that can elapse between retransmissions.
+
+	Default: 60000
+
+rto_min - INTEGER
+	The minimum value (in milliseconds) of the round trip timeout.  This
+	is the smallest time interval the can elapse between retransmissions.
+
+	Default: 1000
+
+hb_interval - INTEGER
+	The interval (in milliseconds) between HEARTBEAT chunks.  These chunks
+	are sent at the specified interval on idle paths to probe the state of
+	a given path between 2 associations.
+
+	Default: 30000
+    
+sack_timeout - INTEGER
+	The amount of time (in milliseconds) that the implementation will wait
+	to send a SACK.
+
+	Default: 200
+
+valid_cookie_life - INTEGER
+	The default lifetime of the SCTP cookie (in milliseconds).  The cookie
+	is used during association establishment.
+
+cookie_preserve_enable - BOOLEAN
+	Enable or disable the ability to extend the lifetime of the SCTP cookie
+	that is used during the establishment phase of SCTP association
+
+	1: Enable cookie lifetime extension.
+	0: Disable
+
+	Default: 1
+
+rcvbuf_policy - INTEGER
+	Determines if the receive buffer is attributed to the socket or to
+	association.   SCTP supports the capability to create multiple
+	associations on a single socket.  When using this capability, it is
+	possible that a single stalled association that's buffering a lot
+	of data may block other associations from delivering their data by
+	consuming all of the receive buffer space.  To work around this,
+	the rcvbuf_policy could be set to attribute the receiver buffer space
+	to each association instead of the socket.  This prevents the described
+	blocking.
+
+	1: rcvbuf space is per association
+	0: recbuf space is per socket
+	
+	Default: 0
+	
+sndbuf_policy - INTEGER
+	Similar to rcvbuf_policy above, this applies to send buffer space.
+
+	1: Send buffer is tracked per association
+	0: Send buffer is tracked per socket.
+
+	Default: 0
+
+sctp_mem - vector of 3 INTEGERs: min, pressure, max
+	Number of pages allowed for queueing by all SCTP sockets.
+
+	min: Below this number of pages SCTP is not bothered about its
+	memory appetite. When amount of memory allocated by SCTP exceeds
+	this number, SCTP starts to moderate memory usage.
+
+	pressure: This value was introduced to follow format of tcp_mem.
+
+	max: Number of pages allowed for queueing by all SCTP sockets.
+
+	Default is calculated at boot time from amount of available memory.
+	
+sctp_rmem - vector of 3 INTEGERs: min, default, max
+	See tcp_rmem for a description.
+
+sctp_wmem  - vector of 3 INTEGERs: min, default, max
+	See tcp_wmem for a description.
+
 UNDOCUMENTED:
 
 dev_weight FIXME
-- 
1.5.3.5

