From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 6802] New: pktgen cause kernel oops with
 transmit load balanced bonding
Date: Fri, 7 Jul 2006 11:50:19 -0700
Message-ID: <20060707115019.ebeb6865.akpm@osdl.org>
References: <200607071437.k67EbqZS022297@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:62140 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932218AbWGGSub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 14:50:31 -0400
To: cltien@gmail.com
In-Reply-To: <200607071437.k67EbqZS022297@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 7 Jul 2006 07:37:52 -0700
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=6802
> 
>            Summary: pktgen cause kernel oops with transmit load balanced
>                     bonding
>     Kernel Version: 2.4.32, 2.6.17.2
>             Status: NEW
>           Severity: high
>              Owner: acme@conectiva.com.br
>          Submitter: cltien@gmail.com
> 
> 
> Most recent kernel where this bug did not occur:
> not found
> Distribution:
> Fedora Core 4
> 
> Hardware Environment:
> i386, ppc
> 
> Software Environment:
> gcc
> 
> Problem Description:
> If running the kernel packet generator (pktgen), and the output device is set 
> to bonding interface with mode balance-tlb or balance-alb, then there will be 
> kernel oops.
> 
> I only set the odev, dst and count (as 0 for infinite test) for the pktgen. I 
> wonder if I made mistake for the pktgen parameters but it doesn't cause problem 
> if the odev set to physical device such as eth0, etc.
> 
> My investigations shows that the problem happen when the bond_alb_xmit tries to 
> access the daddr fields of IP header in skb->nh.iph. If I did the same in round-
> robin mode, it can generate oops too.
> 
> Steps to reproduce:
> 1. Build kernel with pktgen (CONFIG_NET_PKTGEN) and bonding driver 
> (CONFIG_BONDING).
> 2. Setup bonding interface.
> ifenslave bond0 eth0
> 3. Create a script for starting packet generator,
> the script I start packet generator for kernel 2.4 series is like following:
> -----------cut here --------
> #! /bin/sh
> 
> modprobe pktgen
> 
> PGDEV=/proc/net/pktgen/pg0
> 
> function pgset() {
>     local result
> 
>     echo $1 > $PGDEV
> 
>     result=`cat $PGDEV | fgrep "Result: OK:"`
>     if [ "$result" = "" ]; then
>          cat $PGDEV | fgrep Result:
>     fi
> }
> 
> function pg() {
>     echo inject > $PGDEV
>     cat $PGDEV
> }
> 
> pgset "odev bond0"
> pgset "dst 127.1.16.1"
> pgset "count 0"
> pg
> -----------cut here --------
> 
> 4. If the odev is set to eth0, the this script will not have problem, problem 
> only happen when it is set to bond0.
> 

Please send (via an emailed reply-to-all) a copy of the oops output.

Thanks.
