From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/7] rxrpc: Miscellany
Date: Tue, 29 Aug 2017 13:26:47 +0100
Message-ID: <150400960745.21371.15455867950162722742.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Here are a number of patches that make some changes/fixes and add a couple
of extensions to AF_RXRPC for kernel services to use.  The changes and
fixes are:

 (1) Use time64_t rather than u32 outside of protocol or
     UAPI-representative structures.

 (2) Use the correct time stamp when loading a key from an XDR-encoded
     Kerberos 5 key.

 (3) Fix IPv6 support.

 (4) Fix some places where the error code is being incorrectly made
     positive before returning.

 (5) Remove some white space.

And the extensions:

 (6) Add an end-of-Tx phase notification, thereby allowing kAFS to
     transition the state on its own call record at the correct point,
     rather than having to do it in advance and risk non-completion of the
     call in the wrong state.

 (7) Allow a kernel client call to be retried if it fails on a network
     error, thereby making it possible for kAFS to iterate over a number of
     IP addresses without having to reload the Tx queue and re-encrypt data
     each time.

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-next

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-next-20170829

David
---
Baolin Wang (1):
      net: rxrpc: Replace time_t type with time64_t type

David Howells (6):
      rxrpc: Use correct timestamp from Kerberos 5 ticket
      rxrpc: Fix IPv6 support
      rxrpc: Don't negate call->error before returning it
      rxrpc: Remove some excess whitespace
      rxrpc: Add notification of end-of-Tx phase
      rxrpc: Allow failed client calls to be retried


 Documentation/networking/rxrpc.txt |   57 ++++++++++++++++++++
 fs/afs/rxrpc.c                     |   46 ++++++++++++----
 include/keys/rxrpc-type.h          |   23 ++++++++
 include/net/af_rxrpc.h             |   21 +++++++
 net/rxrpc/af_rxrpc.c               |   75 +++++++++++++++++++++++++-
 net/rxrpc/ar-internal.h            |   25 ++++-----
 net/rxrpc/call_accept.c            |    2 -
 net/rxrpc/call_object.c            |  102 ++++++++++++++++++++++++++++++++++--
 net/rxrpc/conn_client.c            |   17 +++++-
 net/rxrpc/conn_object.c            |    2 -
 net/rxrpc/key.c                    |   22 +++++---
 net/rxrpc/local_event.c            |    2 -
 net/rxrpc/output.c                 |    2 -
 net/rxrpc/peer_event.c             |    6 +-
 net/rxrpc/rxkad.c                  |   22 ++++----
 net/rxrpc/sendmsg.c                |   62 +++++++++++++++-------
 net/rxrpc/utils.c                  |   23 ++++++--
 17 files changed, 419 insertions(+), 90 deletions(-)
