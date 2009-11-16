From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Mon, 16 Nov 2009 08:39:05 -0800
Message-ID: <20091116083905.634b8f56@nehalam>
References: <4AFA8911.7050204@gmail.com>
	<4AFBD911.6000900@gmail.com>
	<4AFCE273.7010901@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57885 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752620AbZKPQjZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Nov 2009 11:39:25 -0500
In-Reply-To: <4AFCE273.7010901@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Nov 2009 12:37:07 +0800
Changli Gao <xiaosuo@gmail.com> wrote:

> ifb: add multi-queue support
> 
> Add multi-queue support, and one kernel thread is created for per queue.
> It can used to emulate multi-queue NIC in software, and distribute work
> among CPUs.

My $.02 is that receive packet steering RPS should be done generically at
receive layer. Then all the CPU, mapping and configuration issues can be
done once, not just for IFB, Bridge, VLAN, ... The number of users of IFB
is small, and setup is complex. Steering packets in IFB is optimizing only
a rarely used corner.

Layered link services like IFB need to be multi-threaded lockless to maintain
the advantages of multi-queue and RPS.

-- 
