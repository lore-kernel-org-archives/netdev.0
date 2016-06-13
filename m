From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 1/2] rxrpc: Rename files matching ar-*.c to git rid
 of the "ar-" prefix
Date: Mon, 13 Jun 2016 15:07:57 +0100
Message-ID: <146582687747.9344.1127780366985480556.stgit@warthog.procyon.org.uk>
References: <146582687035.9344.8429200604453755089.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146582687035.9344.8429200604453755089.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rename files matching net/rxrpc/ar-*.c to get rid of the "ar-" prefix.
This will aid splitting those files by making easier to come up with new
names.

Note that the not all files are simply renamed from ar-X.c to X.c.  The
following exceptions are made:

 (*) ar-call.c -> call_object.c
     ar-ack.c -> call_event.c

     call_object.c is going to contain the core of the call object
     handling.  Call event handling is all going to be in call_event.c.

 (*) ar-accept.c -> call_accept.c

     Incoming call handling is going to be here.

 (*) ar-connection.c -> conn_object.c
     ar-connevent.c -> conn_event.c

     The former file is going to have the basic connection object handling,
     but there will likely be some differentiation between client
     connections and service connections in additional files later.  The
     latter file will have all the connection-level event handling.

 (*) ar-local.c -> local_object.c

     This will have the local endpoint object handling code.  The local
     endpoint event handling code will later be split out into
     local_event.c.

 (*) ar-peer.c -> peer_object.c

     This will have the peer endpoint object handling code.  Peer event
     handling code will be placed in peer_event.c (for the moment, there is
     none).

 (*) ar-error.c -> peer_event.c

     This will become the peer event handling code, though for the moment
     it's actually driven from the local endpoint's perspective.

Note that I haven't renamed ar-transport.c to transport_object.c as the
intention is to delete it when the rxrpc_transport struct is excised.

The only file that actually has its contents changed is net/rxrpc/Makefile.

net/rxrpc/ar-internal.h will need its section marker comments updating, but
I'll do that in a separate patch to make it easier for git to follow the
history across the rename.  I may also want to rename ar-internal.h at some
point - but that would mean updating all the #includes and I'd rather do
that in a separate step.

Signed-off-by: David Howells <dhowells@redhat.com.
---

 net/rxrpc/Makefile        |   34 +++++++++++++++++-----------------
 net/rxrpc/call_accept.c   |    0 
 net/rxrpc/call_event.c    |    0 
 net/rxrpc/call_object.c   |    0 
 net/rxrpc/conn_event.c    |    0 
 net/rxrpc/conn_object.c   |    0 
 net/rxrpc/input.c         |    0 
 net/rxrpc/key.c           |    0 
 net/rxrpc/local_object.c  |    0 
 net/rxrpc/output.c        |    0 
 net/rxrpc/peer_event.c    |    0 
 net/rxrpc/peer_object.c   |    0 
 net/rxrpc/proc.c          |    0 
 net/rxrpc/recvmsg.c       |    0 
 net/rxrpc/security.c      |    0 
 net/rxrpc/skbuff.c        |    0 
 net/rxrpc/transport.c     |    0 
 17 files changed, 17 insertions(+), 17 deletions(-)
 rename net/rxrpc/{ar-accept.c => call_accept.c} (100%)
 rename net/rxrpc/{ar-ack.c => call_event.c} (100%)
 rename net/rxrpc/{ar-call.c => call_object.c} (100%)
 rename net/rxrpc/{ar-connevent.c => conn_event.c} (100%)
 rename net/rxrpc/{ar-connection.c => conn_object.c} (100%)
 rename net/rxrpc/{ar-input.c => input.c} (100%)
 rename net/rxrpc/{ar-key.c => key.c} (100%)
 rename net/rxrpc/{ar-local.c => local_object.c} (100%)
 rename net/rxrpc/{ar-output.c => output.c} (100%)
 rename net/rxrpc/{ar-error.c => peer_event.c} (100%)
 rename net/rxrpc/{ar-peer.c => peer_object.c} (100%)
 rename net/rxrpc/{ar-proc.c => proc.c} (100%)
 rename net/rxrpc/{ar-recvmsg.c => recvmsg.c} (100%)
 rename net/rxrpc/{ar-security.c => security.c} (100%)
 rename net/rxrpc/{ar-skbuff.c => skbuff.c} (100%)
 rename net/rxrpc/{ar-transport.c => transport.c} (100%)

diff --git a/net/rxrpc/Makefile b/net/rxrpc/Makefile
index e05a06ef2254..7e1006a3bfa5 100644
--- a/net/rxrpc/Makefile
+++ b/net/rxrpc/Makefile
@@ -4,25 +4,25 @@
 
 af-rxrpc-y := \
 	af_rxrpc.o \
-	ar-accept.o \
-	ar-ack.o \
-	ar-call.o \
-	ar-connection.o \
-	ar-connevent.o \
-	ar-error.o \
-	ar-input.o \
-	ar-key.o \
-	ar-local.o \
-	ar-output.o \
-	ar-peer.o \
-	ar-recvmsg.o \
-	ar-security.o \
-	ar-skbuff.o \
-	ar-transport.o \
+	call_accept.o \
+	call_event.o \
+	call_object.o \
+	conn_event.o \
+	conn_object.o \
+	input.o \
 	insecure.o \
-	misc.o
+	key.o \
+	local_object.o \
+	misc.o \
+	output.o \
+	peer_event.o \
+	peer_object.o \
+	recvmsg.o \
+	security.o \
+	skbuff.o \
+	transport.o
 
-af-rxrpc-$(CONFIG_PROC_FS) += ar-proc.o
+af-rxrpc-$(CONFIG_PROC_FS) += proc.o
 af-rxrpc-$(CONFIG_RXKAD) += rxkad.o
 af-rxrpc-$(CONFIG_SYSCTL) += sysctl.o
 
diff --git a/net/rxrpc/ar-accept.c b/net/rxrpc/call_accept.c
similarity index 100%
rename from net/rxrpc/ar-accept.c
rename to net/rxrpc/call_accept.c
diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/call_event.c
similarity index 100%
rename from net/rxrpc/ar-ack.c
rename to net/rxrpc/call_event.c
diff --git a/net/rxrpc/ar-call.c b/net/rxrpc/call_object.c
similarity index 100%
rename from net/rxrpc/ar-call.c
rename to net/rxrpc/call_object.c
diff --git a/net/rxrpc/ar-connevent.c b/net/rxrpc/conn_event.c
similarity index 100%
rename from net/rxrpc/ar-connevent.c
rename to net/rxrpc/conn_event.c
diff --git a/net/rxrpc/ar-connection.c b/net/rxrpc/conn_object.c
similarity index 100%
rename from net/rxrpc/ar-connection.c
rename to net/rxrpc/conn_object.c
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/input.c
similarity index 100%
rename from net/rxrpc/ar-input.c
rename to net/rxrpc/input.c
diff --git a/net/rxrpc/ar-key.c b/net/rxrpc/key.c
similarity index 100%
rename from net/rxrpc/ar-key.c
rename to net/rxrpc/key.c
diff --git a/net/rxrpc/ar-local.c b/net/rxrpc/local_object.c
similarity index 100%
rename from net/rxrpc/ar-local.c
rename to net/rxrpc/local_object.c
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/output.c
similarity index 100%
rename from net/rxrpc/ar-output.c
rename to net/rxrpc/output.c
diff --git a/net/rxrpc/ar-error.c b/net/rxrpc/peer_event.c
similarity index 100%
rename from net/rxrpc/ar-error.c
rename to net/rxrpc/peer_event.c
diff --git a/net/rxrpc/ar-peer.c b/net/rxrpc/peer_object.c
similarity index 100%
rename from net/rxrpc/ar-peer.c
rename to net/rxrpc/peer_object.c
diff --git a/net/rxrpc/ar-proc.c b/net/rxrpc/proc.c
similarity index 100%
rename from net/rxrpc/ar-proc.c
rename to net/rxrpc/proc.c
diff --git a/net/rxrpc/ar-recvmsg.c b/net/rxrpc/recvmsg.c
similarity index 100%
rename from net/rxrpc/ar-recvmsg.c
rename to net/rxrpc/recvmsg.c
diff --git a/net/rxrpc/ar-security.c b/net/rxrpc/security.c
similarity index 100%
rename from net/rxrpc/ar-security.c
rename to net/rxrpc/security.c
diff --git a/net/rxrpc/ar-skbuff.c b/net/rxrpc/skbuff.c
similarity index 100%
rename from net/rxrpc/ar-skbuff.c
rename to net/rxrpc/skbuff.c
diff --git a/net/rxrpc/ar-transport.c b/net/rxrpc/transport.c
similarity index 100%
rename from net/rxrpc/ar-transport.c
rename to net/rxrpc/transport.c
