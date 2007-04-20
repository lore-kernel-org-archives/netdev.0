From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8330] New: lmc: copy_to/from_user cals while
 spinlock is held
Date: Fri, 20 Apr 2007 15:56:59 -0700
Message-ID: <20070420155659.099dad03.akpm@linux-foundation.org>
References: <200704152128.l3FLSgOB026277@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, matthias.kaehlcke@gmail.com,
	khc@pm.waw.pl
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:54173 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1767307AbXDTW5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 18:57:16 -0400
In-Reply-To: <200704152128.l3FLSgOB026277@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 15 Apr 2007 14:28:42 -0700
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8330
> 
>            Summary: lmc: copy_to/from_user cals while spinlock is held
>     Kernel Version: 2.6.20
>             Status: NEW
>           Severity: normal
>              Owner: jgarzik@pobox.com
>          Submitter: matthias.kaehlcke@gmail.com
> 
> 
> Problem Description:
> 
> the lmc_ioctl() function in drivers/net/wan/lmc/lmc_main.c calls
> copy_from/to_user() while the spinlock sc->lmc_lock is held. AFAIK this should
> not be done as copy_from/to_user() might sleep
> 

urgh.  That function is a study in "what not to do while holding a spinlock".
Including "return without having unlocked it".

It is irreparable.
