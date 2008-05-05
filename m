From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH 00/18] flag parameters
Date: Sun, 4 May 2008 23:42:46 -0400
Message-ID: <200805050342.m453gkv3029811@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52480 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754068AbYEEDmy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 May 2008 23:42:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series replaces the individual patches I sent out before.  They
introduce changes for all the file descriptor-generating syscalls which
do not have a flags parameter (or where it is not handled).

I think I addressed all the comments people made on the previous patches.
New in this series is support for pipe and inotify_init.  These are
straight-forward extensions like the rest.  Both require new userlevel
interfaces, though.  We need new userlevel interfaces for:

 - paccept
 - epoll_create2
 - dup3
 - pipe2
 - inotify_init1

We do /not/ need new interfaces for

 - signalfd4
 - eventfd2
 - timerfd_create
 - socket
 - socketpair

These either have flags parameters in the interface exported by glibc
or (in case of the socket functions) overload a parameter with a bitset.

In addition to support for setting the close-on-exec flag I also added
support to set the non-blocking mode.  This is how most modern, scalable
code should work and adding the support comes almost for free.  Support
to enable non-blocking is not added for dup3 (for obvious reasons)
and epoll_create2.  For the latter I have not found any support in the
kernel.  In case I missed something let me know and  I'll add the few
lines of code.

Each semantic change has a test program.  For archs other than x86 and
x86-64 you'll have to add the appropriate syscall number.

The patches all apply individually in sequence and the source tree
remains compilable and runnable.

Regarding the little mapping tables for the flags.  There are multiple
copies with the same values (for now).  We could play tricks for mergable
ELF sections to avoid this minimal duplication.
