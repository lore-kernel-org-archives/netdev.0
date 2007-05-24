From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8536] New: Kernel drops UDP packets silently
 when reading from certain proc file entries
Date: Thu, 24 May 2007 12:59:26 -0700
Message-ID: <20070524125926.f91d64a2.akpm@linux-foundation.org>
References: <200705241948.l4OJmTAe031670@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, andsve@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:36029 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750864AbXEXT7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 15:59:30 -0400
In-Reply-To: <200705241948.l4OJmTAe031670@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 24 May 2007 12:48:29 -0700
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8536
> 
>            Summary: Kernel drops UDP packets silently when reading from
>                     certain proc file entries
>     Kernel Version: 2.6.x
>             Status: NEW
>           Severity: high
>              Owner: acme@ghostprotocols.net
>          Submitter: andsve@gmail.com
> 
> 
> Most recent kernel where this bug did *NOT* occur:
> I do not know, but I now that it exists in RHEL4 2.6.9.x kernels
> Distribution:
> All
> Hardware Environment:
> Multi core SMP
> Software Environment:
> All
> Problem Description:
> It is possible to introduce UDP packet losses by reading
> the proc file entry /proc/net/tcp. The really strange thing is that
> the error counters for packet drops are not increased. 
> This means that the kernel introduce "silent" packet drops by just reading a
> proc statistics entry which is Not a good thing! I can most probably be used for
> denial of service attacks from no root users.
> 
> When looking at the network code it does not seem possible that silent packet
> drops can ocurr so it is probably a quite nasty kernel bug.
> 
> 
> Steps to reproduce:
> 
> * Send high speed RTP/UDP multicast traffic towards the system, 50Mbit/s. 
> 
> * Receive the RTP packets and check/validate the RTP counters and print out when
> the counter is not continous.
> 
> * Do a while loop cat:ing from the /proc/net/tcp and see the packets beeing
> dropped but not accounted for in the counter statistics.
> 
> I have reproduced this behavior on all our systems ranging from dual to quad
> core Xeon and Opteron and also on different OS releases, RHEL4, RHEL5, Fedora
> Core 5 and 6
> 
