From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 02/18] flag parameters: socket and socketpair
Date: Mon, 05 May 2008 13:24:52 +0900 (JST)
Message-ID: <20080505.132452.98853465.yoshfuji@linux-ipv6.org>
References: <200805050342.m453gktl029817@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org,
	yoshfuji@linux-ipv6.org
To: drepper@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:38614 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752029AbYEEEYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 00:24:46 -0400
In-Reply-To: <200805050342.m453gktl029817@devserv.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <200805050342.m453gktl029817@devserv.devel.redhat.com> (at Sun, 4 May 2008 23:42:46 -0400), Ulrich Drepper <drepper@redhat.com> says:

> This patch adds support for flag values which are ORed to the type passwd
> to socket and socketpair.  The additional code is minimal.  Beside
> decoding the flags with the library function introduced in a prior patch
> all that has to be done is to pass the new value around.
> 
> The internal functions sock_alloc_fd and sock_map_fd get a new parameters
> and all callers are changed.

Well, this seems the only patch that overrides basic context of the
arguments.  (Or, we have already "flags" argument for other APIs
that do not require new API.)

To me, it seems overriding 2nd argument is a too ad-hoc workaround,
and introducing new syscalls with flags is cleaner, e.g.,
    psocket(family, socktype, protocol, flags);
    psocketpair(d, type, protocol, int sv[2], flags);

--yoshfuji
