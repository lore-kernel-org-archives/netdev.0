From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: sanity checking iov_iter patches
Date: Thu, 15 Dec 2016 06:23:05 +0000
Message-ID: <20161215062305.GR1555@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:51632 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757413AbcLOHJj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 02:09:39 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Some of the vfs.git#work.iov_iter stuff touches net/*; basically,
there are several missing primitives (copy_from_iter_full(), etc.) for
"try to copy, tell whether it has copied the full amount requested and
advance the iterator only in case of success".  Most of the callers were
actually doing just that (see e.g. skb_add_data() and friends) and while
nothing in the current kernel cares whether we advance ->msg_iter on
failure, it's much more consistent semantics.

	If anybody has objections to that stuff (in linux-next, or in
git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs.git#work.iov_iter),
or thinks that some of that should go via net-next.git, yell and I'll
drop the bits in question.  If not, to Linus it all goes...
