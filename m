From: Jeff Garzik <jeff@garzik.org>
Subject: Re: POHMELFS high performance network filesystem. Transactions, failover,
 performance.
Date: Wed, 14 May 2008 15:03:40 -0400
Message-ID: <482B378C.5070807@garzik.org>
References: <20080513174523.GA1677@2ka.mipt.ru> <4829E752.8030104@garzik.org> <20080513205114.GA16489@2ka.mipt.ru> <Pine.LNX.4.64.0805140623001.14334@cobra.newdream.net> <20080514135156.GA23131@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sage Weil <sage@newdream.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58142 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755515AbYENTDo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 15:03:44 -0400
In-Reply-To: <20080514135156.GA23131@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov wrote:
> Hi Sage.
> 
> On Wed, May 14, 2008 at 06:35:19AM -0700, Sage Weil (sage@newdream.net) wrote:
>>>> What is your opinion of the Paxos algorithm?
>>> It is slow. But it does solve failure cases.
>> For writes, Paxos is actually more or less optimal (in the non-failure 
>> cases, at least).  Reads are trickier, but there are ways to keep that 
>> fast as well.  FWIW, Ceph extends basic Paxos with a leasing mechanism to 
>> keep reads fast, consistent, and distributed.  It's only used for cluster 
>> state, though, not file data.
> 
> Well, it depends... If we are talking about single node perfromance,
> then any protocol, which requries to wait for authorization (or any
> approach, which waits for acknowledge just after data was sent) is slow.

Quite true, but IMO single-node performance is largely an academic 
exercise today.  What production system is run without backups or 
replication?


> If we are talking about agregate parallel perfromance, then its basic
> protocol with 2 messages is (probably) optimal, but still I'm not
> convinced, that 2 messages case is a good choise, I want one :)

I think part of Paxos' attraction is that it is provably correct for the 
chosen goal, which historically has not been true for hand-rolled 
consensus algorithms often found these days.

There are a bunch of variants (fast paxos, byzantine paxos, fast 
byzantine paxos, etc., etc.) based on Classical Paxos which make 
improvements in the performance/latency areas.  There is even a Paxos 
Commit which appears to be more efficient than the standard transaction 
two-phase commit used by several existing clustered databases.

	Jeff



