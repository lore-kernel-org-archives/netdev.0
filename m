From: <richard.alpe@ericsson.com>
Subject: [PATCH iproute2] tipc: add man pages
Date: Fri, 2 Oct 2015 10:15:21 +0200
Message-ID: <1443773721-12755-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Richard Alpe <richard.alpe@ericsson.com>

This patch adds man pages for the TIPC tool. There is one main page
and one page for each top level sub-command. These pages mainly aims
to help a user of the tipc tool. In addition to this they describe
a bit about what TIPC is and some of its features as a protocol.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 man/man8/tipc-bearer.8    | 230 ++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/tipc-link.8      | 225 +++++++++++++++++++++++++++++++++++++++++++++
 man/man8/tipc-media.8     |  86 +++++++++++++++++
 man/man8/tipc-nametable.8 |  99 ++++++++++++++++++++
 man/man8/tipc-node.8      |  71 ++++++++++++++
 man/man8/tipc-socket.8    |  59 ++++++++++++
 man/man8/tipc.8           |  99 ++++++++++++++++++++
 7 files changed, 869 insertions(+)
 create mode 100644 man/man8/tipc-bearer.8
 create mode 100644 man/man8/tipc-link.8
 create mode 100644 man/man8/tipc-media.8
 create mode 100644 man/man8/tipc-nametable.8
 create mode 100644 man/man8/tipc-node.8
 create mode 100644 man/man8/tipc-socket.8
 create mode 100644 man/man8/tipc.8

diff --git a/man/man8/tipc-bearer.8 b/man/man8/tipc-bearer.8
new file mode 100644
index 0000000..f59c39d
--- /dev/null
+++ b/man/man8/tipc-bearer.8
@@ -0,0 +1,230 @@
+.TH TIPC-BEARER 8 "02 Jun 2015" "iproute2" "Linux"
+
+./ For consistency, please keep padding right aligned.
+./ For example '.B "foo " bar' and not '.B foo " bar"'
+
+.SH NAME
+tipc-bearer \- show or modify TIPC bearers
+
+.SH SYNOPSIS
+.ad l
+.in +8
+
+.ti -8
+.B tipc bearer enable
+.RB "[ " domain
+.IR DOMAIN " ]"
+.RB "[ " priority
+.IR PRIORITY " ]"
+.BR media
+.br
+.RB "{ { " eth " | " ib " } " device
+.IR "DEVICE" " }"
+.RB "|"
+.br
+.RB	"{ " udp
+.B name
+.IR NAME
+.B localip
+.IR LOCALIP
+.RB "[ " localport
+.IR LOCALPORT " ]"
+.RB "[ " remoteip
+.IR REMOTEIP " ]"
+.RB "[ " remoteport
+.IR REMOTEPORT " ] }"
+.br
+
+.ti -8
+.B tipc bearer disable media
+.br
+.RB "{ { " eth " | " ib " } " device
+.IR DEVICE
+.RB "|"
+.br
+.RB "{ " udp
+.B name
+.IR NAME
+.B localip
+.IR LOCALIP " } }"
+.br
+
+.ti -8
+.B tipc bearer set
+.RB "{ " "priority "
+.IR PRIORITY
+.RB "| " tolerance
+.IR TOLERANCE
+.RB "| " window
+.IR WINDOW
+.RB "} " media
+.br
+.RB "{ { " eth " | " ib " } " device
+.IR "DEVICE" " }"
+.RB "|"
+.br
+.RB "{ " udp
+.B name
+.IR NAME
+.B localip
+.IR LOCALIP " } }"
+.br
+
+.ti -8
+.B tipc bearer get
+.RB "{ " "priority" " | " tolerance " | " window " } " media
+.br
+.RB "{ { " eth " | " ib " } " device
+.IR "DEVICE" " }"
+.RB "|"
+.br
+.RB "{ " udp
+.B name
+.IR NAME
+.B localip
+.IR LOCALIP " } }"
+.br
+
+.ti -8
+.B tipc bearer list
+.br
+
+.SH OPTIONS
+Options (flags) that can be passed anywhere in the command chain.
+.TP
+.BR "\-h" , " --help"
+Show help about last valid command. For example
+.B tipc bearer --help
+will show bearer help and
+.B tipc --help
+will show general help. The position of the option in the string is irrelevant.
+.SH DESCRIPTION
+
+.SS Bearer identification
+.TP
+.BI "media " MEDIA
+.br
+Specifies the TIPC media type for a particular bearer to operate on.
+Different media types have different ways of identifying a unique bearer.
+For example,
+.BR "ib " "and " eth
+identify a bearer with a
+.I DEVICE
+while
+.B udp
+identify a bearer with a
+.IR "LOCALIP " "and a " NAME
+
+.B ib
+- Infiniband
+.sp
+.B eth
+- Ethernet
+.sp
+.B udp
+- User Datagram Protocol (UDP)
+.sp
+
+.TP
+.BI "name " NAME
+.br
+Logical bearer identifier valid for bearers on
+.B udp
+media.
+
+.TP
+.BI "device " DEVICE
+.br
+Physical bearer device valid for bearers on
+.B eth
+and
+.B ib
+media.
+
+.SS Bearer properties
+
+.TP
+.B domain
+.br
+The addressing domain (region) in which a bearer will establish links and accept
+link establish requests.
+
+.TP
+.B priority
+.br
+Default link priority inherited by all links subsequently established over a
+bearer. A single bearer can only host one link to a particular node. This means
+the default link priority for a bearer typically affects which bearer to use
+when communicating with a particular node in an multi bearer setup. For more
+info about link priority see
+.BR tipc-link (8)
+
+.TP
+.B tolerance
+.br
+Default link tolerance inherited by all links subsequently established over a
+bearer. For more info about link tolerance see
+.BR tipc-link (8)
+
+.TP
+.B window
+.br
+Default link window inherited by all links subsequently established over a
+bearer. For more info about the link window size see
+.BR tipc-link (8)
+
+.SS UDP bearer options
+
+.TP
+.BI "localip " LOCALIP
+.br
+Specify a local IP v4/v6 address for a
+.B udp
+bearer.
+
+.TP
+.BI "localport " LOCALPORT
+.br
+Specify the local port for a
+.B udp
+bearer. The default port 6118 is used if no port is specified.
+
+.TP
+.BI "remoteip " REMOTEIP
+.br
+Specify a remote IP for a
+.B udp
+bearer. If no remote IP is specified a
+.B udp
+bearer runs in multicast mode and tries to auto-discover its neighbours.
+The multicast IP address is generated based on the TIPC network ID. If a remote
+IP is specified the
+.B udp
+bearer runs in point-to-point mode.
+
+.TP
+.BI "remoteport " REMOTEPORT
+.br
+Specify the remote port for a
+.B udp
+bearer. The default port 6118 is used if no port is specified.
+
+.SH EXIT STATUS
+Exit status is 0 if command was successful or a positive integer upon failure.
+
+.SH SEE ALSO
+.BR tipc (8),
+.BR tipc-link (8),
+.BR tipc-media (8),
+.BR tipc-nametable (8),
+.BR tipc-node (8),
+.BR tipc-socket (8)
+.br
+.SH REPORTING BUGS
+Report any bugs to the Network Developers mailing list
+.B <netdev@vger.kernel.org>
+where the development and maintenance is primarily done.
+You do not have to be subscribed to the list to send a message there.
+
+.SH AUTHOR
+Richard Alpe <richard.alpe@ericsson.com>
diff --git a/man/man8/tipc-link.8 b/man/man8/tipc-link.8
new file mode 100644
index 0000000..899b882
--- /dev/null
+++ b/man/man8/tipc-link.8
@@ -0,0 +1,225 @@
+.TH TIPC-LINK 8 "02 Jun 2015" "iproute2" "Linux"
+
+./ For consistency, please keep padding right aligned.
+./ For example '.B "foo " bar' and not '.B foo " bar"'
+
+.SH NAME
+tipc-link \- show links or modify link properties
+
+.SH SYNOPSIS
+.ad l
+.in +8
+
+.ti -8
+
+.ti -8
+.B tipc link set
+.RB "{ " "priority "
+.IR PRIORITY
+.RB "| " tolerance
+.IR TOLERANCE
+.RB "| " window
+.IR "WINDOW " }
+.BI "link " LINK
+
+.ti -8
+.B tipc link get
+.RB "{ " "priority" " | " tolerance " | " window " } " link
+.I LINK
+
+.ti -8
+.B tipc link statistics
+.RB "{ " "show " "[ " link
+.I LINK
+.RB "] | " "reset
+.BI "link " "LINK "
+.R }
+
+.ti -8
+.B tipc link list
+.br
+
+.SH OPTIONS
+Options (flags) that can be passed anywhere in the command chain.
+.TP
+.BR "\-h" , " --help"
+Show help about last valid command. For example
+.B tipc link --help
+will show link help and
+.B tipc --help
+will show general help. The position of the option in the string is irrelevant.
+.SH DESCRIPTION
+
+.SS Link statistics
+
+.TP
+.BR "ACTIVE " "link state"
+.br
+An
+.B ACTIVE
+link is serving traffic. Two links to the same node can become
+.B ACTIVE
+if they have the same link
+.BR priority .
+If there is more than two links with the same priority the additional links will
+be put in
+.B STANDBY
+state.
+
+.TP
+.BR "STANDBY " "link state"
+.br
+A
+.B STANDBY
+link has lower link priority than an
+.B ACTIVE
+link. A
+.B STANDBY
+link has control traffic flowing and is ready to take over should the
+.B ACTIVE
+link(s) go down.
+
+.TP
+.B MTU
+.br
+The Maximum Transmission Unit. The two endpoints advertise their default or
+configured
+.B MTU
+at initial link setup and will agree to use the lower of the two values should
+they differ.
+
+.TP
+.B Packets
+.br
+The total amount of transmitted or received TIPC packets on a link. Including
+.BR "fragmented " "and " "bundled " packets.
+
+.TP
+.B Fragments
+.br
+Represented in the form
+.BR fragments / fragmented .
+Where
+.B fragmented
+is the amount of data messages which have been broken into
+.BR fragments .
+Subsequently the
+.B fragments
+are the total amount of packets that the
+.B fragmented
+messages has been broken into.
+
+.TP
+.B Bundles
+.br
+Represented in the form
+.BR bundles / bundled .
+If a link becomes congested the link will attempt to bundle data from small
+.B bundled
+packets into
+.B bundles
+of full MTU size packets before they are transmitted.
+
+.TP
+.B Profile
+.br
+Shows the
+.B average
+packet size in octets/bytes for a
+.B sample
+of packets. It also shows the packet size distribution of the
+.B sampled
+packets in the intervals
+
+0-64 bytes
+.br
+64-256 bytes
+.br
+256-1024 bytes
+.br
+1024-4096 bytes
+.br
+4096-16384 bytes
+.br
+16384-32768 bytes
+.br
+32768-66000 bytes
+
+.TP
+.B Message counters
+
+.B states
+- Number of link state messages
+.sp
+
+.B probes
+- Link state messages with probe flag set. Typically sent when a link is idle
+.sp
+
+.B nacks
+- Number of negative acknowledgement (NACK) packets sent and received by the
+link
+.sp
+
+.B defs
+- Number of packets received out of order
+.sp
+
+.B dups
+- Number of duplicate packets received
+
+.TP
+.B Congestion link
+The number of times an application has tried to send data when the TIPC link
+was congested
+
+.TP
+.B Send queue
+.B Max
+is the maximum amount of messages that has resided in the out queue during the
+statistics collection period of a link.
+
+.B Avg
+is the average outqueue size during the lifetime of a link.
+
+.SS Link properties
+
+.TP
+.B priority
+.br
+The priority between logical TIPC links to a particular node. Link priority can
+range from 0 (lowest) to 31 (highest).
+
+.TP
+.B tolerance
+.br
+Link tolerance specifies the maximum time in milliseconds that TIPC will allow
+a communication problem to exist before taking the link down. The default value
+is 1500 milliseconds.
+
+.TP
+.B window
+.br
+The link window controls how many unacknowledged messages a link endpoint can
+have in its transmit queue before TIPC's congestion control mechanism is
+activated.
+
+.SH EXIT STATUS
+Exit status is 0 if command was successful or a positive integer upon failure.
+
+.SH SEE ALSO
+.BR tipc (8),
+.BR tipc-media (8),
+.BR tipc-bearer (8),
+.BR tipc-nametable (8),
+.BR tipc-node (8),
+.BR tipc-socket (8)
+.br
+.SH REPORTING BUGS
+Report any bugs to the Network Developers mailing list
+.B <netdev@vger.kernel.org>
+where the development and maintenance is primarily done.
+You do not have to be subscribed to the list to send a message there.
+
+.SH AUTHOR
+Richard Alpe <richard.alpe@ericsson.com>
diff --git a/man/man8/tipc-media.8 b/man/man8/tipc-media.8
new file mode 100644
index 0000000..7f94efe
--- /dev/null
+++ b/man/man8/tipc-media.8
@@ -0,0 +1,86 @@
+.TH TIPC-MEDIA 8 "02 Jun 2015" "iproute2" "Linux"
+
+./ For consistency, please keep padding right aligned.
+./ For example '.B "foo " bar' and not '.B foo " bar"'
+
+.SH NAME
+tipc-media \- list or modify media properties
+
+.SH SYNOPSIS
+.ad l
+.in +8
+
+.ti -8
+
+.ti -8
+.B tipc media set
+.RB "{ " "priority "
+.IR PRIORITY
+.RB "| " tolerance
+.IR TOLERANCE
+.RB "| " window
+.IR "WINDOW " }
+.BI "media " MEDIA
+
+.ti -8
+.B tipc media get
+.RB "{ " "priority" " | " tolerance " | " window " } " media
+.I MEDIA
+
+.ti -8
+.B tipc media list
+.br
+
+.SH OPTIONS
+Options (flags) that can be passed anywhere in the command chain.
+.TP
+.BR "\-h" , " --help"
+Show help about last valid command. For example
+.B tipc media --help
+will show media help and
+.B tipc --help
+will show general help. The position of the option in the string is irrelevant.
+.SH DESCRIPTION
+
+.SS Media properties
+
+.TP
+.B priority
+.br
+Default link priority inherited by all bearers subsequently enabled on a
+media. For more info about link priority see
+.BR tipc-link (8)
+
+.TP
+.B tolerance
+.br
+Default link tolerance inherited by all bearers subsequently enabled on a
+media. For more info about link tolerance see
+.BR tipc-link (8)
+
+.TP
+.B window
+.br
+Default link window inherited by all bearers subsequently enabled on a
+media. For more info about link window see
+.BR tipc-link (8)
+
+.SH EXIT STATUS
+Exit status is 0 if command was successful or a positive integer upon failure.
+
+.SH SEE ALSO
+.BR tipc (8),
+.BR tipc-bearer (8),
+.BR tipc-link (8),
+.BR tipc-nametable (8),
+.BR tipc-node (8),
+.BR tipc-socket (8)
+.br
+.SH REPORTING BUGS
+Report any bugs to the Network Developers mailing list
+.B <netdev@vger.kernel.org>
+where the development and maintenance is primarily done.
+You do not have to be subscribed to the list to send a message there.
+
+.SH AUTHOR
+Richard Alpe <richard.alpe@ericsson.com>
diff --git a/man/man8/tipc-nametable.8 b/man/man8/tipc-nametable.8
new file mode 100644
index 0000000..c8d573f
--- /dev/null
+++ b/man/man8/tipc-nametable.8
@@ -0,0 +1,99 @@
+.TH TIPC-NAMETABLE 8 "02 Jun 2015" "iproute2" "Linux"
+
+./ For consistency, please keep padding right aligned.
+./ For example '.B "foo " bar' and not '.B foo " bar"'
+
+.SH NAME
+tipc-nametable \- show TIPC nametable
+
+.SH SYNOPSIS
+.ad l
+.in +8
+
+.ti -8
+.B tipc nametable show
+.br
+
+.SH OPTIONS
+Options (flags) that can be passed anywhere in the command chain.
+.TP
+.BR "\-h" , " --help"
+Show help about last valid command. For example
+.B tipc nametable --help
+will show nametable help and
+.B tipc --help
+will show general help. The position of the option in the string is irrelevant.
+
+.SH DESCRIPTION
+The nametable shows TIPC publication information.
+
+.SS Nametable format
+
+.TP
+.B Type
+.br
+The 32-bit type field of the port name. The type field often indicates the class of service
+provided by a port.
+
+.TP
+.B Lower
+.br
+The lower bound of the 32-bit instance field of the port name.
+The instance field is often used as as a sub-class indicator.
+
+.TP
+.B Upper
+.br
+The upper bound of the 32-bit instance field of the port name.
+The instance field is often used as as a sub-class indicator.
+A difference in
+.BR "lower " "and " upper
+means the socket is bound to the port name range [lower,upper]
+
+.TP
+.B Port Identity
+.br
+The unique socket (port) identifier within the TIPC cluster. The
+.B port identity
+consists of a node identity followed by a socket reference number.
+
+.TP
+.B Publication
+.br
+The
+.B publication
+ID is a random number used internally to represent a publication.
+
+.TP
+.B Scope
+.br
+The publication
+.B scope
+specifies the visibility of a bound port name.
+The
+.B scope
+can be specified to comprise three different domains:
+.BR node ", " "cluster " "and " zone.
+Applications residing within the specified
+.B scope
+can see and access the port using the displayed port name.
+
+.SH EXIT STATUS
+Exit status is 0 if command was successful or a positive integer upon failure.
+
+.SH SEE ALSO
+.BR tipc (8),
+.BR tipc-bearer (8),
+.BR tipc-link (8),
+.BR tipc-media (8),
+.BR tipc-node (8),
+.BR tipc-socket (8)
+.br
+.SH REPORTING BUGS
+Report any bugs to the Network Developers mailing list
+.B <netdev@vger.kernel.org>
+where the development and maintenance is primarily done.
+You do not have to be subscribed to the list to send a message there.
+
+.SH AUTHOR
+Richard Alpe <richard.alpe@ericsson.com>
diff --git a/man/man8/tipc-node.8 b/man/man8/tipc-node.8
new file mode 100644
index 0000000..66418b3
--- /dev/null
+++ b/man/man8/tipc-node.8
@@ -0,0 +1,71 @@
+.TH TIPC-NODE 8 "02 Jun 2015" "iproute2" "Linux"
+
+./ For consistency, please keep padding right aligned.
+./ For example '.B "foo " bar' and not '.B foo " bar"'
+
+.SH NAME
+tipc-node \- modify and show local node parameters or list peer nodes
+
+.SH SYNOPSIS
+.ad l
+.in +8
+
+.ti -8
+.B tipc node set
+.RB "{ " "address "
+.IR ADDRESS
+.RB "| " netid
+.IR NETID
+.RB "} "
+
+.ti -8
+.B tipc node get
+.RB "{ " "address" " | " netid " } "
+
+.ti -8
+.B tipc node list
+.br
+
+.SH OPTIONS
+Options (flags) that can be passed anywhere in the command chain.
+.TP
+.BR "\-h" , " --help"
+Show help about last valid command. For example
+.B tipc node --help
+will show node help and
+.B tipc --help
+will show general help. The position of the option in the string is irrelevant.
+.SH DESCRIPTION
+
+.SS Node parameters
+.TP
+.BI address
+.br
+The TIPC logical address. On the form x.y.z where x, y and z are unsigned
+integers.
+
+.TP
+.BI netid
+.br
+Network identity. Can by used to create individual TIPC clusters on the same
+media.
+
+.SH EXIT STATUS
+Exit status is 0 if command was successful or a positive integer upon failure.
+
+.SH SEE ALSO
+.BR tipc (8),
+.BR tipc-bearer (8),
+.BR tipc-link (8),
+.BR tipc-media (8),
+.BR tipc-nametable (8),
+.BR tipc-socket (8)
+.br
+.SH REPORTING BUGS
+Report any bugs to the Network Developers mailing list
+.B <netdev@vger.kernel.org>
+where the development and maintenance is primarily done.
+You do not have to be subscribed to the list to send a message there.
+
+.SH AUTHOR
+Richard Alpe <richard.alpe@ericsson.com>
diff --git a/man/man8/tipc-socket.8 b/man/man8/tipc-socket.8
new file mode 100644
index 0000000..af18e35
--- /dev/null
+++ b/man/man8/tipc-socket.8
@@ -0,0 +1,59 @@
+.TH TIPC-SOCKET 8 "02 Jun 2015" "iproute2" "Linux"
+
+./ For consistency, please keep padding right aligned.
+./ For example '.B "foo " bar' and not '.B foo " bar"'
+
+.SH NAME
+tipc-socket \- show TIPC socket (port) information
+
+.SH SYNOPSIS
+.ad l
+.in +8
+
+.ti -8
+.B tipc socket list
+
+.SH OPTIONS
+Options (flags) that can be passed anywhere in the command chain.
+.TP
+.BR "\-h" , " --help"
+Show help about last valid command. For example
+.B tipc socket --help
+will show socket help and
+.B tipc --help
+will show general help. The position of the option in the string is irrelevant.
+
+.SH DESCRIPTION
+A TIPC socket is represented by an unsigned integer.
+
+.TP
+.SS Bound state
+A bound socket has a logical TIPC port name associated with it.
+
+.TP
+.SS Connected state
+A connected socket is directly connected to another socket creating a point
+to point connection between TIPC sockets. If the connection to X was made using
+a logical port name Y that name will show up as
+.BR "connected to " "X " "via " Y
+.
+
+.SH EXIT STATUS
+Exit status is 0 if command was successful or a positive integer upon failure.
+
+.SH SEE ALSO
+.BR tipc (8),
+.BR tipc-bearer (8)
+.BR tipc-link (8),
+.BR tipc-media (8),
+.BR tipc-nametable (8),
+.BR tipc-node (8),
+.br
+.SH REPORTING BUGS
+Report any bugs to the Network Developers mailing list
+.B <netdev@vger.kernel.org>
+where the development and maintenance is primarily done.
+You do not have to be subscribed to the list to send a message there.
+
+.SH AUTHOR
+Richard Alpe <richard.alpe@ericsson.com>
diff --git a/man/man8/tipc.8 b/man/man8/tipc.8
new file mode 100644
index 0000000..c116552
--- /dev/null
+++ b/man/man8/tipc.8
@@ -0,0 +1,99 @@
+.TH TIPC 8 "02 Jun 2015" "iproute2" "Linux"
+.SH NAME
+tipc \- a TIPC configuration and management tool
+.SH SYNOPSIS
+
+.ad l
+.in +8
+.ti -8
+.B tipc
+.RI "[ " OPTIONS " ] " COMMAND " " ARGUMENTS "
+.sp
+
+.ti -8
+.IR COMMAND " := { "
+.BR bearer " | " link " | " media " | " nametable " | " node " | " socket " }
+.sp
+
+.ti -8
+.IR OPTIONS " := { "
+\fB\-h\fR[\fIhelp\fR] }
+
+.SH DESCRIPTION
+The Transparent Inter-Process Communication (TIPC) protocol offers total address
+transparency between processes which allows applications in a clustered computer
+environment to communicate quickly and reliably with each other, regardless of
+their location within the cluster.
+
+TIPC originated at the telecommunications manufacturer Ericsson. The first open
+source version of TIPC was created in 2000 when Ericsson released its first
+Linux version of TIPC. TIPC was introduced in the mainline Linux kernel in 2006
+and is now widely used both within and outside of Ericsson.
+
+.SH OPTIONS
+
+.TP
+.BR "\-h" , " --help"
+Show help about last given command. For example
+.B tipc bearer --help
+will show bearer help and
+.B tipc --help
+will show general help. The position of the option in the string is irrelevant.
+
+.SH COMMANDS
+
+.TP
+.B BEARER
+- Show or modify TIPC bearers
+
+.TP
+.B LINK
+- Show or modify TIPC links
+
+.TP
+.B MEDIA
+- Show or modify TIPC media
+
+.TP
+.B NAMETABLE
+- Show TIPC nametable
+
+.TP
+.B NODE
+- Show or modify TIPC node parameters
+
+.TP
+.B SOCKET
+- Show TIPC sockets
+
+.SH ARGUMENTS
+
+Command arguments are described in a command specific man page and typically
+consists of nested commands along with key value pairs.
+If no arguments are given a command typically shows its help text. The explicit
+help option
+.B -h
+or
+.B --help
+can occur anywhere among the arguments and will show help for the last valid
+command given.
+
+.SH EXIT STATUS
+Exit status is 0 if command was successful or a positive integer upon failure.
+
+.SH SEE ALSO
+.BR tipc-bearer (8),
+.BR tipc-link (8),
+.BR tipc-media (8),
+.BR tipc-nametable (8),
+.BR tipc-node (8),
+.BR tipc-socket (8)
+.br
+.SH REPORTING BUGS
+Report any bugs to the Network Developers mailing list
+.B <netdev@vger.kernel.org>
+where the development and maintenance is primarily done.
+You do not have to be subscribed to the list to send a message there.
+
+.SH AUTHOR
+Richard Alpe <richard.alpe@ericsson.com>
-- 
2.1.4


------------------------------------------------------------------------------
