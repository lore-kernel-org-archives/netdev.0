From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: RFC: Nagle latency tuning
Date: Tue, 9 Sep 2008 12:54:31 -0400
Message-ID: <732BEAC4-63ED-413B-8BE6-E194DFA6DD7B@oracle.com>
References: <48C59F75.6030504@redhat.com> <48C5A9A9.9040503@hp.com> <48C6052D.2080203@redhat.com> <48C6A553.2070901@hp.com>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Chris Snook <csnook@redhat.com>, Netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:30689 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757308AbYIIQyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 12:54:54 -0400
In-Reply-To: <48C6A553.2070901@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sep 9, 2008, at Sep 9, 2008, 12:33 PM, Rick Jones wrote:
>> Most of the apps where people care about this enough to complain to  
>> their vendor (the cases I hear about) are in messaging apps, where  
>> they're relaying a stream of events that have little to do with  
>> each other, and they want TCP to maintain the integrity of the  
>> connection and do a modicum of bandwidth management, but 40 ms  
>> stalls greatly exceed their latency tolerances.
>
> What _are_ their latency tolerances?  How often are they willing to  
> tolerate a modicum of TCP bandwidth management?  Do they go ape when  
> TCP sits waiting not just for 40ms, but for an entire RTO timer?
>
>> Using TCP_NODELAY is often the least bad option, but sometimes it's
>> infeasible because of its effect on the network, and it certainly
>> adds to the network stack overhead.  A more tunable Nagle delay would
>> probably serve many of these apps much better.
>
> If the applications are sending streams of logically unrelated sends  
> down the same socket, then setting TCP_NODELAY is IMO fine.  Where  
> it isn't fine is where these applications are generating their  
> logically associated data in two or more small sends.  One send per  
> message good. Two sends per message bad.

Can the same be said of the Linux kernel's RPC client, which uses  
MSG_MORE and multiple sends to construct a single RPC request on a TCP  
socket?

See net/sunrpc/xprtsock.c:xs_send_pagedata() for details.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
