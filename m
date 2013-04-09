From: Ed W <lists@wildgooses.com>
Subject: Re: Modifying the exponential backoff on new connection SYN packets
Date: Tue, 09 Apr 2013 16:52:21 +0100
Message-ID: <51643935.6070201@wildgooses.com>
References: <5163DA09.5070202@wildgooses.com>  <1365515283.3887.124.camel@edumazet-glaptop> <1365520328.3887.141.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.nippynetworks.com ([91.220.24.129]:56328 "EHLO
	mail1.nippynetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936061Ab3DIPwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 11:52:23 -0400
In-Reply-To: <1365520328.3887.141.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/04/2013 16:12, Eric Dumazet wrote:
> On Tue, 2013-04-09 at 06:48 -0700, Eric Dumazet wrote:
>
>> You'll have to change inet_csk_reqsk_queue_prune() in
>> net/ipv4/inet_connection_sock.c
>>
>> timeo = min(timeout << req->num_timeout, max_rto);
>> req->expires = now + timeo;
>>
>> Good luck !
> Oh well, this code is for SYNACK retransmits...
>
> For other retransmits, you'll have to take a look in
> net/ipv4/tcp_timer.c, around lines 475
>
> icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
>
>

Hmm, I don't necessarily want to change the normal data timeouts, just 
the initial SYN timeouts. How might I make detect that I'm in SYN state 
and cap the timer appropriately? Apologies for beginner questions...

Thanks

Ed W
