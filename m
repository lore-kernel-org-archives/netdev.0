From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/3] net: RCU lookups for UDP, DCCP and TCP protocol
Date: Thu, 13 Nov 2008 18:20:09 +0100
Message-ID: <87k5b7czli.fsf@basil.nowhere.org>
References: <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com>
	<49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com>
	<20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org>
	<4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org>
	<20081029185200.GE6732@linux.vnet.ibm.com>
	<4908C0CD.5050406@cosmosbay.com>
	<20081029201759.GF6732@linux.vnet.ibm.com>
	<4908DEDE.5030706@cosmosbay.com> <4909D551.9080309@cosmosbay.com>
	<491C27F0.8000507@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Corey Minyard <minyard@acm.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	benny+usenet@amorsen.dk,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Christian Bell <christian@myri.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:49207 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754023AbYKMRUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 12:20:12 -0500
In-Reply-To: <491C27F0.8000507@cosmosbay.com> (Eric Dumazet's message of "Thu, 13 Nov 2008 14:13:20 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <dada1@cosmosbay.com> writes:


> 1) Introduce hlist_nulls variant of hlist
>
>   hlist uses NULL value to finish a chain.
>   hlist_nulls variant use the low order bit set to 1 to signal an end marker.
>   This allows to store many different end markers, so that some RCU lockless
>   algos (used in TCP/UDP stack for example) can save some memory barriers in
>   fast paths.

Do you have any numbers that demonstrate the read memory barriers being
a performance problem? At least on x86 they should be very cheap
because they're normally nops.

-Andi

-- 
ak@linux.intel.com
