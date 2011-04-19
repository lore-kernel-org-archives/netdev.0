From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from
 uninitialized memory in __alloc_skb
Date: Tue, 19 Apr 2011 05:09:17 +0200
Message-ID: <1303182557.4152.48.camel@edumazet-laptop>
References: <bug-33502-10286@https.bugzilla.kernel.org/>
	 <20110418153852.153d3ed3.akpm@linux-foundation.org>
	 <1303181466.4152.39.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, casteyde.christian@free.fr,
	Vegard Nossum <vegardno@ifi.uio.no>,
	Pekka Enberg <penberg@kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44733 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754093Ab1DSDJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 23:09:23 -0400
Received: by wya21 with SMTP id 21so4457240wya.19
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2011 20:09:22 -0700 (PDT)
In-Reply-To: <1303181466.4152.39.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 19 avril 2011 =C3=A0 04:51 +0200, Eric Dumazet a =C3=A9crit :

> Hmm, looking at mm/slub.c, I wonder what prevents "object" from point=
ing
> to a now freed and unreachable zone of memory. (Say we are interrupte=
d,
> object given to interrupt handler and this one wants to change page b=
its
> to trap access)


Yes, I suspect this whole business is not kmemcheck compatable, or
DEBUG_PAGEALLOC

get_freepointer(s, object) can access to freed memory and kmemcheck
triggers the fault, while this_cpu_cmpxchg_double() would presumably
detect a change of tid and would not perform the freelist/tid change.




