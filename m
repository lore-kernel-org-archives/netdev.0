From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 0/2] unix: Introduce /proc/net/unix_peers file
Date: Thu, 01 Dec 2011 21:41:11 +0400
Message-ID: <4ED7BC37.2030805@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:23379 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755746Ab1LARlU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Dec 2011 12:41:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

There's a common problem with unix sockets -- there's no way to determine
which tasks are connected to each other with a unix socket. Although the
/proc/<pid>/fd/<n> symlink shows a socket inode number, the peers do not
share an inode and thus these numbers give no answer.

There have been an attempt last year to print the peer=<number> for unbound
sockets in the existing /proc/net/unix file, but it was left unfinished and
had problems with bound sockets - for those the peer inode was still unknown
and the name didn't help at all.

I'd like to have this ability (determining the unix connection endpoints)
implemented and propose to introduce a /proc/net/unix_peers file with socket
inode number pairs. For not connected sockets 0 is printed.

Are there strong objections against this approach?

Patches apply to net-next tree.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
