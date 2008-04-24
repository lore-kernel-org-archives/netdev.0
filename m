From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 11:25:14 +0100
Message-ID: <20080424112514.055d8071@the-village.bc.nu>
References: <200804240403.m3O43us8028699@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:36431 "EHLO
	the-village.bc.nu" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751581AbYDXKx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 06:53:58 -0400
In-Reply-To: <200804240403.m3O43us8028699@devserv.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> - I decided against using the O_* flags here.  Most are not useful and
>   we might need the bits for something else at some time.  Hence the
>   new SOCKFL_* flag.  The intend is to define SOCKFL_CLOEXEC and
>   O_CLOEXEC to the same value.  In this case there is zero overhead.

Given we will never have 2^32 socket types, and in a sense this is part
of the type why not just use

	socket(PF_INET, SOCK_STREAM|SOCK_CLOEXEC, ...)

that would be far far cleaner, no new syscalls on the socket side at all.

Alan
