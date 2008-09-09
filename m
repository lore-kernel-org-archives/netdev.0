From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: RFC: Nagle latency tuning
Date: Tue, 9 Sep 2008 14:21:30 -0300
Message-ID: <20080909172130.GG12726@ghostprotocols.net>
References: <48C59F75.6030504@redhat.com> <48C5A9A9.9040503@hp.com> <48C6052D.2080203@redhat.com> <48C6A553.2070901@hp.com> <732BEAC4-63ED-413B-8BE6-E194DFA6DD7B@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hp.com>, Chris Snook <csnook@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:50317 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753570AbYIIRaA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 13:30:00 -0400
Content-Disposition: inline
In-Reply-To: <732BEAC4-63ED-413B-8BE6-E194DFA6DD7B@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Sep 09, 2008 at 12:54:31PM -0400, Chuck Lever escreveu:
> On Sep 9, 2008, at Sep 9, 2008, 12:33 PM, Rick Jones wrote:
>>> Most of the apps where people care about this enough to complain to  
>>> their vendor (the cases I hear about) are in messaging apps, where  
>>> they're relaying a stream of events that have little to do with each 
>>> other, and they want TCP to maintain the integrity of the connection 
>>> and do a modicum of bandwidth management, but 40 ms stalls greatly 
>>> exceed their latency tolerances.
>>
>> What _are_ their latency tolerances?  How often are they willing to  
>> tolerate a modicum of TCP bandwidth management?  Do they go ape when  
>> TCP sits waiting not just for 40ms, but for an entire RTO timer?
>>
>>> Using TCP_NODELAY is often the least bad option, but sometimes it's
>>> infeasible because of its effect on the network, and it certainly
>>> adds to the network stack overhead.  A more tunable Nagle delay would
>>> probably serve many of these apps much better.
>>
>> If the applications are sending streams of logically unrelated sends  
>> down the same socket, then setting TCP_NODELAY is IMO fine.  Where it 
>> isn't fine is where these applications are generating their logically 
>> associated data in two or more small sends.  One send per message good. 
>> Two sends per message bad.
>
> Can the same be said of the Linux kernel's RPC client, which uses  
> MSG_MORE and multiple sends to construct a single RPC request on a TCP  
> socket?
>
> See net/sunrpc/xprtsock.c:xs_send_pagedata() for details.

That is not a problem, it should be equivalent to corking the socket.
I.e. the uncorking operation will be the last part of the buffer, where
'more' will be 0.

- Arnaldo
