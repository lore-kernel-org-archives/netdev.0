From: Ben Greear <greearb@candelatech.com>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Fri, 21 Jul 2006 09:14:39 -0700
Message-ID: <44C0FD6F.5010601@candelatech.com>
References: <20060719131915.GA21942@ms2.inr.ac.ru> <20060720073223.GA15567@tservice.net.ru> <20060720164100.GA9213@ms2.inr.ac.ru> <20060720210849.GA28715@tservice.net.ru> <44BFF3F5.3040104@candelatech.com> <20060721071900.GB5151@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:13478 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1750985AbWGUQO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2006 12:14:58 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060721071900.GB5151@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Thu, Jul 20, 2006 at 02:21:57PM -0700, Ben Greear (greearb@candelatech.com) wrote:
> 
>>Out of curiosity, is it possible to have the single producer logic
>>if you have two+ ethernet interfaces handling frames for a single
>>TCP connection?  (I am assuming some sort of multi-path routing
>>logic...)
> 
> 
> I do not think it is possible with additional logic like what is
> implemented in softirqs, i.e. per cpu queues of data, which in turn will
> be converted into skbs one-by-one.

Couldn't you have two NICs being handled by two separate CPUs, with both
CPUs trying to write to the same socket queue?

The receive path works with RCU locking from what I understand, so
a protocol's receive function must be re-entrant.

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

