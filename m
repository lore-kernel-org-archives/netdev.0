From: Alex Bligh <alex@alex.org.uk>
Subject: Re: Testing interface removal speedup patches from Eric Dumazet.
Date: Mon, 09 May 2011 19:56:22 +0100
Message-ID: <06627C760FB049F1A9321BC6@Ximines.local>
References: <4DC83471.7030701@candelatech.com>
Reply-To: Alex Bligh <alex@alex.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Alex Bligh <alex@alex.org.uk>
To: Ben Greear <greearb@candelatech.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.avalus.com ([89.16.176.221]:54770 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751933Ab1EIS4X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2011 14:56:23 -0400
In-Reply-To: <4DC83471.7030701@candelatech.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--On 9 May 2011 11:37:37 -0700 Ben Greear <greearb@candelatech.com> wrote:

With:
> Created 500 veth in 17.874695 seconds (0.03574939 per interface).
> Deleted 500 veth in 17.023607 seconds. (0.034047214 per interface)
Without:
> Created 500 veth in 22.507598 seconds (0.045015196 per interface).
> Deleted 500 veth in 34.998733 seconds. (0.069997466 per interface)

Interesting. On my tests (albeit with CONFIG_HZ=100) I got:

                            100 pairs      500 pairs
Interface creation               14ms          110ms
Interface deletion              160ms          148ms

So Eric's patches help in the interface create case, even though
there is no synchronize_net, sychronize_sched() or rcu_barrier() there.

I had assumed the slow create (which varies by number of pairs) was
down to sysfs scalability only (see difference between 14ms and 110ms
there).

Out of interest, if you still happen to have the scripts around, how
fast is veth creation if you just do 100 pairs?

-- 
Alex Bligh
