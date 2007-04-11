From: David Howells <dhowells@redhat.com>
Subject: [PATCH 0/8] AFS: Add security support and fix bugs
Date: Wed, 11 Apr 2007 20:09:56 +0100
Message-ID: <20070411190956.15499.55352.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, dhowells@redhat.com
To: torvalds@osdl.org, akpm@osdl.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


These patches build on the patchset labelled "AF_RXRPC socket family and AFS
rewrite".  The patches are also available for http download.

Firstly, the patches fix a number of bugs in AF_RXRPC:

	http://people.redhat.com/~dhowells/rxrpc/09-af_rxrpc-own-workqueues.diff
	http://people.redhat.com/~dhowells/rxrpc/10-af_rxrpc-fixes.diff

Secondly, they fix some bugs in the AFS filesystem:

	http://people.redhat.com/~dhowells/rxrpc/11-afs-callback-wq.diff
	http://people.redhat.com/~dhowells/rxrpc/12-afs-vlocation.diff
	http://people.redhat.com/~dhowells/rxrpc/13-afs-multimount.diff

And finally, they add security support to AFS:

	http://people.redhat.com/~dhowells/rxrpc/14-afs-rxrpc-key.diff
	http://people.redhat.com/~dhowells/rxrpc/15-afs-nameidata-key.diff
	http://people.redhat.com/~dhowells/rxrpc/16-afs-security.diff


A security key is acquired by running the klog program:

	http://people.redhat.com/~dhowells/rxrpc/klog.c

This is compiled by:

	make klog CFLAGS="-Wall -g" LDLIBS="-lcrypto -lcrypt -lkrb4 -lkeyutils"

And then run by:

	./klog

Note that at the moment this is a rough and ready test program that has the
username, realm, password and proposed key timeout compiled in.  Note also that
it will only talk to the AFS kaserver.


If a security key is acquired, then all subsequent operations - including VL
lookups and mounts - performed with that session keyring will be authenticated
using that key.  The key can be viewed like so:

	[root@andromeda ~]# keyctl show
	Session Keyring
	       -3 --alswrv      0     0  keyring: _ses.3268
		2 --alswrv      0     0   \_ keyring: _uid.0
	111416553 --als--v      0     0   \_ rxrpc: afs@CAMBRIDGE.REDHAT.COM

David
