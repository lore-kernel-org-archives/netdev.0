From: Simon Arlott <simon@fire.lp0.eu>
Subject: open() on sockets (sock_no_open)
Date: Sun, 15 Jul 2007 00:04:17 +0100
Message-ID: <46995671.5080503@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:35789 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932394AbXGNXET (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jul 2007 19:04:19 -0400
Received: from redrum.lp0.eu ([2001:4b10:1005:0:204:23ff:fea8:25f0]:60952 ident=byte)
	by proxima.lp0.eu with esmtps (TLSv1:AES256-SHA:256)
	id 1I9qew-0001X1-3k
	for netdev@vger.kernel.org; Sun, 15 Jul 2007 00:04:18 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are sockets in /proc/<pid>/fd/, but they can't be opened because
of this function:

/*
 *  In theory you can't get an open on this inode, but /proc provides
 *  a back door. Remember to keep it shut otherwise you'll let the
 *  creepy crawlies in.
 */
static int sock_no_open(struct inode *irrelevant, struct file *dontcare)


How would I make it possible to open existing sockets?

It's possible to duplicate access to the same socket using fork(), but I
just seem to be creating a mess when I try to make open() work because
it breaks after calling socket_close... is there a way to do this so it
works properly?

-- 
Simon Arlott
