From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next] rxrpc: Change module filename to rxrpc.ko
Date: Fri, 17 Feb 2017 18:16:21 +0000
Message-ID: <148735538165.2347.15424333408396462662.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change module filename from af-rxrpc.ko to rxrpc.ko so as to be consistent
with the other protocol drivers.

Also adjust the documentation to reflect this.

Further, there is no longer a standalone rxkad module, as it has been
merged into the rxrpc core, so get rid of references to that.

Reported-by: Marc Dionne <marc.dionne@auristor.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 Documentation/filesystems/afs.txt |   34 +---------------------------------
 net/rxrpc/Makefile                |   12 ++++++------
 2 files changed, 7 insertions(+), 39 deletions(-)

diff --git a/Documentation/filesystems/afs.txt b/Documentation/filesystems/afs.txt
index ffef91c4e0d6..060da408923b 100644
--- a/Documentation/filesystems/afs.txt
+++ b/Documentation/filesystems/afs.txt
@@ -64,8 +64,7 @@ USAGE
 When inserting the driver modules the root cell must be specified along with a
 list of volume location server IP addresses:
 
-	modprobe af_rxrpc
-	modprobe rxkad
+	modprobe rxrpc
 	modprobe kafs rootcell=cambridge.redhat.com:172.16.18.73:172.16.18.91
 
 The first module is the AF_RXRPC network protocol driver.  This provides the
@@ -214,34 +213,3 @@ If a file is opened with a particular key and then the file descriptor is
 passed to a process that doesn't have that key (perhaps over an AF_UNIX
 socket), then the operations on the file will be made with key that was used to
 open the file.
-
-
-========
-EXAMPLES
-========
-
-Here's what I use to test this.  Some of the names and IP addresses are local
-to my internal DNS.  My "root.afs" partition has a mount point within it for
-some public volumes volumes.
-
-insmod /tmp/rxrpc.o
-insmod /tmp/rxkad.o
-insmod /tmp/kafs.o rootcell=cambridge.redhat.com:172.16.18.91
-
-mount -t afs \%root.afs. /afs
-mount -t afs \%cambridge.redhat.com:root.cell. /afs/cambridge.redhat.com/
-
-echo add grand.central.org 18.9.48.14:128.2.203.61:130.237.48.87 > /proc/fs/afs/cells
-mount -t afs "#grand.central.org:root.cell." /afs/grand.central.org/
-mount -t afs "#grand.central.org:root.archive." /afs/grand.central.org/archive
-mount -t afs "#grand.central.org:root.contrib." /afs/grand.central.org/contrib
-mount -t afs "#grand.central.org:root.doc." /afs/grand.central.org/doc
-mount -t afs "#grand.central.org:root.project." /afs/grand.central.org/project
-mount -t afs "#grand.central.org:root.service." /afs/grand.central.org/service
-mount -t afs "#grand.central.org:root.software." /afs/grand.central.org/software
-mount -t afs "#grand.central.org:root.user." /afs/grand.central.org/user
-
-umount /afs
-rmmod kafs
-rmmod rxkad
-rmmod rxrpc
diff --git a/net/rxrpc/Makefile b/net/rxrpc/Makefile
index 8fc6ea347182..b9da4d6b914f 100644
--- a/net/rxrpc/Makefile
+++ b/net/rxrpc/Makefile
@@ -2,7 +2,9 @@
 # Makefile for Linux kernel RxRPC
 #
 
-af-rxrpc-y := \
+obj-$(CONFIG_AF_RXRPC) += rxrpc.o
+
+rxrpc-y := \
 	af_rxrpc.o \
 	call_accept.o \
 	call_event.o \
@@ -26,8 +28,6 @@ af-rxrpc-y := \
 	skbuff.o \
 	utils.o
 
-af-rxrpc-$(CONFIG_PROC_FS) += proc.o
-af-rxrpc-$(CONFIG_RXKAD) += rxkad.o
-af-rxrpc-$(CONFIG_SYSCTL) += sysctl.o
-
-obj-$(CONFIG_AF_RXRPC) += af-rxrpc.o
+rxrpc-$(CONFIG_PROC_FS) += proc.o
+rxrpc-$(CONFIG_RXKAD) += rxkad.o
+rxrpc-$(CONFIG_SYSCTL) += sysctl.o
