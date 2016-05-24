From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC] net: remove busylock
Date: Tue, 24 May 2016 13:50:35 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F4C5166@AcuExch.aculab.com>
References: <1463677716.18194.203.camel@edumazet-glaptop3.roam.corp.google.com>
	<CAKgT0UfBxW=KpqJux+tjyNpHQUHhZ5Laiqnt5FPs=jpkBJWrHA@mail.gmail.com>
	<20160520092903.38620c60@redhat.com>
	<1463749909.18194.291.camel@edumazet-glaptop3.roam.corp.google.com>
	<1463752069.18194.294.camel@edumazet-glaptop3.roam.corp.google.com>
	<1463753815.18194.298.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160520194951.6354fba1@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Alexander Duyck <aduyck@mirantis.com>,
	"John Fastabend" <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: 'Jesper Dangaard Brouer' <brouer@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.186]:56856 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752419AbcEXNvy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2016 09:51:54 -0400
In-Reply-To: <20160520194951.6354fba1@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer
> Sent: 20 May 2016 18:50
...
> If would be cool if you could run a test with removed busylock and
> allow HTB to bulk dequeue.

(Without having looked ....)
Could you have two queues and separate queue and dequeue locks.

The enqueue code would acquire the enqueue lock and add the packet
to the first queue.

The dequeue code would acquire the dequeue lock and try to remove
a packet from the 2nd queue, if nothing present it would acquire
the enqueue lock and move the entire 1st queue to the 2nd queue.

The obvious downside is two lock/unlocks for single packet dequeue.
If you can guarantee a single dequeue thread the 2nd lock isn't needed.

	David
