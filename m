From: Michel Lespinasse <walken@zoy.org>
Subject: Re: [Bugme-new] [Bug 12282] New: Network data corruption on eee 1000
Date: Tue, 30 Dec 2008 18:20:27 -0800
Message-ID: <20081231022027.GA28913@zoy.org>
References: <bug-12282-10286@http.bugzilla.kernel.org/> <20081223232035.5a5caea9.akpm@linux-foundation.org> <3400f2f60812240532s23c8f218q51e4717f4231b3bc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	Jie Yang <jie.yang@atheros.com>
To: "J. K. Cliburn" <jcliburn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.lespinasse.org ([64.142.28.226]:34981 "EHLO
	server.lespinasse.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753807AbYLaCUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2008 21:20:30 -0500
Content-Disposition: inline
In-Reply-To: <3400f2f60812240532s23c8f218q51e4717f4231b3bc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 24, 2008 at 07:32:36AM -0600, J. K. Cliburn wrote:
> Do things improve if you turn off TSO in the atl1e driver?
> 
> ethtool -K eth0 tso off

Seems to work:

I get "operation not supported" when trying this ethtool command.
However, I compiled 2.6.28 with a patch to not set NETIF_F_TSO and
NETIF_F_TSO6 into netdev->features and I've been able to transfer
180 GB with scp overnight without running into any corrupted MACs.

One thing I do not understand - I thought the tso option was only
meaningful on the sender side ??? In my case, the transfers are going
from the external server to the local atl1e based interface...

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.
