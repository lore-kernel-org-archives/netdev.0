From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Extensible hashing and RCU
Date: Sun, 18 Feb 2007 19:46:22 +0100
Message-ID: <45D89EFE.4080103@cosmosbay.com>
References: <20070204074143.26312.qmail@science.horizon.com> <Pine.LNX.4.61.0702050952590.26852@localhost.localdomain> <20070217131302.GA22732@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: akepner@sgi.com, linux@horizon.com, davem@davemloft.net,
	netdev@vger.kernel.org, bcrl@linux.intel.com
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:34100 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751845AbXBRSwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Feb 2007 13:52:09 -0500
In-Reply-To: <20070217131302.GA22732@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov a e'crit :
> On Mon, Feb 05, 2007 at 10:02:53AM -0800, akepner@sgi.com (akepner@sgi.com) wrote:
>> On Sat, 4 Feb 2007 linux@horizon.com wrote:
>>
>>> I noticed in an LCA talk mention that apprently extensible hashing
>>> with RCU access is an unsolved problem.  Here's an idea for solving it.
>>> ....
>> Yes, I have been playing around with the same idea for
>> doing dynamic resizing of the TCP hashtable.
>>
>> Did a prototype "toy" implementation, and I have a
>> "half-finished" patch which resizes the TCP hashtable
>> at runtime. Hmmm, your mail may be the impetus to get
>> me to finally finish this thing....
> 
> Why anyone do not want to use trie - for socket-like loads it has
> exactly constant search/insert/delete time and scales as hell.
> 

Because we want to be *very* fast. You cannot beat hash table.

Say you have 1.000.000 tcp connections, with 50.000 incoming packets per 
second to *random* streams...
With a 2^20 hashtable, a lookup uses one cache line (the hash head pointer) 
plus one cache line to get the socket (you need it to access its refcounter)

Several attempts were done in the past to add RCU to ehash table (last done by 
  Benjamin LaHaise last March). I believe this was delayed a bit, because 
David would like to be able to resize the hash table...

I am not really interested in hash resizing, because an admin can size it at 
boot time. But RCU is definitly *wanted*

Note : It would be good to also use RCU for UDP, because the current rwlock 
protecting udp_hash[] is a scalability problem.

