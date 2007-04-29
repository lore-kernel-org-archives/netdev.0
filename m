From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8405] New: pppd does stops compresion with
 "Lost compression sync"
Date: Sun, 29 Apr 2007 14:20:47 -0700
Message-ID: <20070429142047.d8617669.akpm@linux-foundation.org>
References: <200704292001.l3TK1P6d000716@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>,
	Richard Purdie <rpurdie@rpsys.net>
To: stefan.wenk@gmx.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:42265 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161398AbXD2VVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2007 17:21:30 -0400
In-Reply-To: <200704292001.l3TK1P6d000716@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(switch to email - please retain all ccs)

On Sun, 29 Apr 2007 13:01:25 -0700 bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8405
> 
>            Summary: pppd does stops compresion with "Lost compression sync"
>     Kernel Version: 2.6.18-2.6.21
>             Status: NEW
>           Severity: normal
>              Owner: other_modules@kernel-bugs.osdl.org
>          Submitter: stefan.wenk@gmx.at
> 
> 
> Most recent kernel where this bug did *NOT* occur:2.6.17
> Distribution: Fedora core 3
> Hardware Environment:
> Software Environment:
> Problem Description:
> I have the same problem as reported on
> http://www.luga.at/mailing-lists/luga/2007/02/msg00032.html (in German).
> When I connect to my ISP via an analogue serial modem my Linux Box sends a PPP
> Compression Control Protocol Termination Request with  "Lost compression sync"
> to the provider and then the provider dropps the link. This does not happen with
> kernel
> 2.6.17, but happens from kernel version 2.6.18 to 2.6.21 (not tested: 2.6.19).
> If I put the nodeflate command line to the pppd then the link remains stable.
> Steps to reproduce:
> In order to find out what is happening I have set up a ppp connection via a
> serial nullmodem to another old Linux box (kernel 2.2.14) and have activated the
> kernel debug in the ppp_deflate.ko module. The "Lost compression sync:" is
> reproducable in this configuration - the only difference is that the link
> remains (without deflate compression).
> 
> Here is the log vor /var/log/messages:
> 
> Apr 29 16:53:34 linux kernel: PPP Deflate Compression module registered
> Apr 29 16:53:47 linux pppd[9090]: pppd 2.4.4 started by root, uid 0
> Apr 29 16:53:47 linux pppd[9090]: Using interface ppp0
> Apr 29 16:53:47 linux pppd[9090]: Connect: ppp0 <--> /dev/pts/9
> Apr 29 16:53:47 linux pppd[9090]: kernel does not support PPP filtering
> Apr 29 16:53:47 linux pppd[9090]: Deflate (15) compression enabled
> Apr 29 16:53:47 linux pppd[9090]: Cannot determine ethernet address for proxy ARP
> Apr 29 16:53:47 linux pppd[9090]: local  IP address 192.168.3.2
> Apr 29 16:53:47 linux pppd[9090]: remote IP address 192.168.3.1
> Apr 29 16:54:03 linux kernel: z_decompress0: inflate returned -5 ()
> Apr 29 16:54:03 linux pppd[9090]: PPPIOCGFLAGS flags: c030c0
> Apr 29 16:54:03 linux pppd[9090]: Lost compression sync: disabling compression
> 
> I had a look at the kernel patch of 2.6.18 - the lib/zlib/zlib_inflate was
> changed a lot and for me it looks to be the reason of the problem.

If you're referring to 4f3865fb57a04db7cca068fed1c15badc064a302,
"zlib_inflate: Upgrade library code to a recent version" then that was
mainly a zlib_inflate change, not a zlib_deflate change.

But yes, I'd say that this patch might well have been the cause.

http://userweb.kernel.org/~akpm/zlib-backout.patch is a backout patch
against 2.6.21.  If you apply that to 2.6.21 does it make ppp work again?

