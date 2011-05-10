From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from uninitialized
 memory in __alloc_skb
Date: Tue, 10 May 2011 13:10:43 +0300
Message-ID: <4DC90F23.7090009@cs.helsinki.fi>
References: <bug-33502-10286@https.bugzilla.kernel.org/>	 <1303181466.4152.39.camel@edumazet-laptop>	 <1303182557.4152.48.camel@edumazet-laptop>	 <1303183217.4152.49.camel@edumazet-laptop>	 <alpine.DEB.2.00.1104191210011.17888@router.home>	 <1303244270.2756.3.camel@edumazet-laptop> <4DAE7579.3020400@cs.helsinki.fi>	 <1303279470.2756.17.camel@edumazet-laptop>	 <1303285519.4dae8f0fdf9b1@imp.free.fr>  <4DAE901C.2090809@cs.helsinki.fi>	 <1303286998.3186.18.camel@edumazet-laptop>	 <1303290464.3186.32.camel@edumazet-laptop>	 <1303293765.3186.74.camel@edumazet-laptop>	 <alpine.DEB.2.00.1104200904440.8634@router.home>	 <1303309591.3186.84.camel@edumazet-laptop>	 <alpine.DEB.2.00.1104200942020.9266@router.home>	 <1303311687.3186.100.camel@edumazet-laptop>	 <alpine.DEB.2.00.1105092241390.6784@tiger>
 	 <alpine.DEB.2.00.1105091502260.26839@router.home>	 <1305016988.2614.6.camel@edumazet-laptop> <4DC909BD.5080903@cs.helsinki.fi> <1305021806.2614.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux.com>, casteyde.christian@free.fr,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Vegard Nossum <vegardno@ifi.uio.no>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34651 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752855Ab1EJKKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 06:10:45 -0400
In-Reply-To: <1305021806.2614.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On 5/10/11 1:03 PM, Eric Dumazet wrote:
> What I meant is I dont understand how Christoph expect to solve this
> problem if irqsafe_cpu_cmpxchg_double() is used everywhere.

Do you see any problem with annotating the freelist pointers with 
kmemcheck_mark_initialized() in set_freepointer()?

The #ifdef removal was requested by Linus et al when we fixed a bug that 
was causing problems during boot on certain CPUs. So even though it 
invalidates your fix, it's the way to go forward.

			Pekka
