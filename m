From: ebiederm@xmission.com (Eric W. Biederman)
Subject: netlink scm creds uid and gids are always 0.
Date: Thu, 23 Aug 2012 23:45:04 -0700
Message-ID: <871uiwlrf3.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:59446 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243Ab2HXGpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 02:45:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


While working on the kuid_t and kgid_t conversion of the audit subsystem
I noticed that since the performance problem of scm creds and af_unix
sockets were fixed af_netlink sockets have not filled in the uid or gid
of the originator of the socket.

I think all we need is an appropriate cred_to_ucred call to fix this
regression, but I am going so many different directions right now I
can't get myself to focus on this long enough to work up an appripriate
patch to fix.

Eric do you think you might take a gander?

The commit where this regression was introduced appears to be.

commit 16e5726269611b71c930054ffe9b858c1cea88eb
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Mon Sep 19 05:52:27 2011 +0000

    af_unix: dont send SCM_CREDENTIALS by default
    
    Since commit 7361c36c5224 (af_unix: Allow credentials to work across
    user and pid namespaces) af_unix performance dropped a lot.
    
    This is because we now take a reference on pid and cred in each write(),
    and release them in read(), usually done from another process,
    eventually from another cpu. This triggers false sharing.
    
