From: Christoph Lameter <cl@linux.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from uninitialized
 memory in __alloc_skb
Date: Tue, 19 Apr 2011 12:09:30 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1104191208010.17888@router.home>
References: <bug-33502-10286@https.bugzilla.kernel.org/>  <20110418153852.153d3ed3.akpm@linux-foundation.org>  <1303181466.4152.39.camel@edumazet-laptop> <1303182557.4152.48.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, casteyde.christian@free.fr,
	Vegard Nossum <vegardno@ifi.uio.no>,
	Pekka Enberg <penberg@kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp102.prem.mail.ac4.yahoo.com ([76.13.13.41]:37398 "HELO
	smtp102.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752223Ab1DSRJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 13:09:38 -0400
In-Reply-To: <1303182557.4152.48.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 19 Apr 2011, Eric Dumazet wrote:

> get_freepointer(s, object) can access to freed memory and kmemcheck
> triggers the fault, while this_cpu_cmpxchg_double() would presumably
> detect a change of tid and would not perform the freelist/tid change.

Sounds right. The new lockless patchset for slub that uses a locked
cmpxchg16b will make this behavior even more common since it will do more
speculative accesses.

