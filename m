From: Javier Martinez Canillas <javier@collabora.co.uk>
Subject: [PATCH 0/10] af_unix: add multicast and filtering features to AF_UNIX
Date: Mon, 20 Feb 2012 16:57:25 +0100
Message-ID: <1329753455-1106-1-git-send-email-javier@collabora.co.uk>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Alban Crequy <alban.crequy@collabora.co.uk>,
	Bart Cerneels <bart.cerneels@collabora.co.uk>,
	Rodrigo Moya <rodrigo.moya@collabora.co.uk>,
	Sjoerd Simons <sjoerd.simons@collabora.co.uk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch-set add multicast support to Unix domain socket familiy for datagram
and seqpacket sockets. This work was made by Alban Crequy as a result of a
research we have been doing to improve the performance of the D-bus IPC system.

The first approach was to create a new AF_DBUS socket address family and
move the routing logic of the D-bus daemon to the kernel. The motivations behind
that approach and the thread of the patches post can be found in [1] and [2].

The feedback was that having D-bus specific code in the kernel is a bad
idea so the second approach was to implement multicast Unix domain sockets so
clients can directly send messages to peers bypassing the D-bus daemon.
A previous version of the patches was already posted by Alban [3] who also has
a good explanation of the implementation on his blog [4].

[1]http://alban-apinc.blogspot.com/2011/12/d-bus-in-kernel-faster.html
[2]http://thread.gmane.org/gmane.linux.kernel/1040481
[3]http://thread.gmane.org/gmane.linux.network/178772
[4]http://alban-apinc.blogspot.com/2011/12/introducing-multicast-unix-sockets.html

The patch-set is composed of the following patches:

[PATCH 01/10] af_unix: Documentation on multicast unix sockets
[PATCH 02/10] af_unix: Add constant for unix socket options level
[PATCH 03/10] af_unix: add setsockopt on unix sockets
[PATCH 04/10] af_unix: create, join and leave multicast groups with setsockopt
[PATCH 05/10] af_unix: find the recipients of a multicast group
[PATCH 06/10] af_unix: Deliver message to several recipients in case of multicast
[PATCH 07/10] af_unix: implement poll(POLLOUT) for multicast sockets
[PATCH 08/10] af_unix: Unsubscribe sockets from their multicast groups on RCV_SHUTDOWN
[PATCH 09/10] Allow server side of SOCK_SEQPACKET sockets to accept a new member
[PATCH 10/10] af_unix: Add a peer BPF for multicast Unix sockets
