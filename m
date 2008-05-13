From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 02/18] flag parameters: paccept
Date: Mon, 12 May 2008 21:10:56 -0700
Message-ID: <20080512211056.16e07167.akpm@linux-foundation.org>
References: <200805062118.m46LI7SS004041@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davidel@xmailserver.org, mtk.manpages@gmail.com,
	torvalds@linux-foundation.org, Roland McGrath <roland@redhat.com>
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44713 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751164AbYEMELj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 00:11:39 -0400
In-Reply-To: <200805062118.m46LI7SS004041@devserv.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 6 May 2008 17:18:07 -0400 Ulrich Drepper <drepper@redhat.com> wrote:

> This patch is by far the most complex in the series.  It adds a new syscall
> paccept.  This syscall differs from accept in that it adds (at the userlevel)
> two additional parameters:
> 
> - a signal mask
> - a flags value
> 
> The flags parameter can be used to set flag like SOCK_CLOEXEC.  This is
> imlpemented here as well.  Some people argued that this is a property
> which should be inherited from the file desriptor for the server but
> this is against POSIX.  Additionally, we really want the signal mask
> parameter as well (similar to pselect, ppoll, etc).  So an interface
> change in inevitable.
> 
> The flag value is the same as for socket and socketpair.  I think
> diverging here will only create confusion.  Similar to the filesystem
> interfaces where the use of the O_* constants differs, it is acceptable
> here.
> 
> The signal mask is handled as for pselect etc.  The mask is temporarily
> installed for the thread and removed before the call returns.  I modeled
> the code after pselect.  If there is a problem it's likely also in
> pselect.
> 
> For architectures which use socketcall I maintained this interface
> instead of adding a system call.  The symmetry shouldn't be broken.
> 
> The following test must be adjusted for architectures other than x86 and
> x86-64 and in case the syscall numbers changed.

Am getting moderately bored of these patches :(

arm exploded thusly:

net/socket.c: In function `sys_paccept':
net/socket.c:1534: error: implicit declaration of function `set_restore_sigmask'

because afacit arm doesn't implement set_restore_sigmask() and nor does
it need to, because it doesn't set HAVE_SET_RESTORE_SIGMASK.

I will continue to fumble along in the rc2-mm1 direction.  Fixes against that
kernel would suit, thanks.
