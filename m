From: "Michael Kerrisk" <mtk.manpages@gmail.com>
Subject: Re: [PATCH] paccept, socket, socketpair w/flags
Date: Mon, 28 Apr 2008 11:52:35 +0200
Message-ID: <517f3f820804280252h753c8cacv7fe9580f96dcf1ce@mail.gmail.com>
References: <200804262224.m3QMOP3a006296@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael Kerrisk" <mtk.manpages@gmail.com>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org
To: "Ulrich Drepper" <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:18749 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754165AbYD1Jwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 05:52:36 -0400
Received: by fg-out-1718.google.com with SMTP id l27so4877682fgb.17
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 02:52:35 -0700 (PDT)
In-Reply-To: <200804262224.m3QMOP3a006296@devserv.devel.redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[CC+=Alan Cox]

On 4/27/08, Ulrich Drepper <drepper@redhat.com> wrote:
> This version of the patch hopefully integrates all of the requested
>  changes:
>
>  - the sock_map_fd interface is changed and all in-tree users changed.
>   No additional function anymore
>
>  - there is a helper function to convert the new socket flags into
>   file flags.  Shared by all three functions
>
>  - the new accept interface is now paccept() which adds the flag
>   parameter as well as a signal mask.
>
>  - not changed from the last version: the paccet() function takes
>   a flags parameter with the same value as the ORed flags for
>   socket() and socketpair().  Seems cleaner.

Ulrich,

This is ugly.  Why invent a diffent set of flags here.  I agree with
your earlier statement that new syscalls would be cleaner.  If, as
seems to be the case, we are going to create new syscalls for

eventfd()
signalfd()
accept()
dup2()
epoll_create()
pipe()
inotify_init()
(I've not seen those last two yet, but I assume you are going to do them.)

then *please* let's go the hwole way cleanly, and have new syscalls
also for socketpair() and socket(), and make all of the new syscalls
use the same flags.  Creating a different set of flags just to avoid a
couple of extra sycalls is ugly.  (You yourself asserted similar in
saying that dup3() is better than adding an extra flag to fcntl(), and
I don't disagree.)

Cheers,

Michael
