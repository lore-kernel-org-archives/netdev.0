From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8342] New: sctp_getsockopt_local_addrs_old()
 calls copy_to_user() while a spinlock is held
Date: Fri, 20 Apr 2007 14:35:00 -0700
Message-ID: <20070420143500.cdac0fab.akpm@linux-foundation.org>
References: <200704162134.l3GLYMuF004745@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, matthias.kaehlcke@gmail.com,
	lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:55937 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1767262AbXDTVfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 17:35:42 -0400
In-Reply-To: <200704162134.l3GLYMuF004745@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 16 Apr 2007 14:34:22 -0700
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8342
> 
>            Summary: sctp_getsockopt_local_addrs_old() calls copy_to_user()
>                     while a spinlock is held
>     Kernel Version: 2.6.20
>             Status: NEW
>           Severity: normal
>              Owner: acme@ghostprotocols.net
>          Submitter: matthias.kaehlcke@gmail.com
> 
> 
> Problem Description:
> 
> sctp_getsockopt_local_addrs_old() in net/sctp/socket.c calls copy_to_user()
> while the spinlock addr_lock is held. this should not be done as copy_to_user()
> might sleep. the call to sctp_copy_laddrs_to_user() while holding the lock is
> also problematic as it calls copy_to_user()
> 

yup.
