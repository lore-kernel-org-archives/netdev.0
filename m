From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH] Implementation of the sendgroup() system call
Date: Mon, 04 May 2009 10:30:33 +0300
Message-ID: <49FE9999.7090103@redhat.com>
References: <49FE47A1.7070700@uwaterloo.ca> <87eiv5ibnd.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Elad Lahav <elahav@uwaterloo.ca>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:41057 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752600AbZEDHb3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2009 03:31:29 -0400
In-Reply-To: <87eiv5ibnd.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> Elad Lahav <elahav@uwaterloo.ca> writes:
>
>   
>> The attached patch contains an implementation of sendgroup(), a system
>> call that allows a UDP packet to be transmitted efficiently to
>> multiple recipients. Use cases for this system call include
>> live-streaming and multi-player online games.
>> The basic idea is that the caller maintains a group - a list of IP
>> addresses and UDP ports - and calls sendgroup() with the group list
>> and a common payload. Optionally, the call allows for per-recipient
>> data to be prepended or appended to the shared block. The data is
>> copied once in the kernel into an allocated page, and the
>> per-recipient socket buffers point to that page. Savings come from
>> avoiding both the multiple calls and the multiple copies of the data
>> required with regular socket operations.
>>     
>
> My guess it's more the copies than the calls? It sounds like
> you want sendfile() for UDP. I think that would be a cleaner solution
> than such a specific hack for your application. It would
> have the advantage of saving the first copy too and be 
> truly zero copy on capable NICs.
>   

An aio udp send could accomplish both multiple packets per call, and 
zero-copy, without adding new syscalls.  You could send the same packet 
to multiple recipients, or multiple packets to the same recipicent, or 
combinations thereof.

> Or perhaps simple send to a local multicast group and let
> some netfilter module turn that into regular UDP.
>   

Sounds hacky and rooty.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

