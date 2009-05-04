From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH] Implementation of the sendgroup() system call
Date: Mon, 04 May 2009 12:58:38 +0300
Message-ID: <49FEBC4E.5040805@redhat.com>
References: <49FE47A1.7070700@uwaterloo.ca> <87eiv5ibnd.fsf@basil.nowhere.org> <49FE9999.7090103@redhat.com> <20090504095300.GF23223@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Elad Lahav <elahav@uwaterloo.ca>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48638 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751894AbZEDJ73 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2009 05:59:29 -0400
In-Reply-To: <20090504095300.GF23223@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
>>> My guess it's more the copies than the calls? It sounds like
>>> you want sendfile() for UDP. I think that would be a cleaner solution
>>> than such a specific hack for your application. It would
>>> have the advantage of saving the first copy too and be 
>>> truly zero copy on capable NICs.
>>>  
>>>       
>> An aio udp send could accomplish both multiple packets per call, and 
>>     
>
> AIO sockets are a lot of work. There have been various attempts
> over the years, but they are very difficult. This was mostly
> for TCP -- possibly UDP would be a bit easier -- but still
> many complications. It would also need a lot of changes and
> you would need to convince the network maintainers that they
> are a good idea.
>   

I would love them for kvm.  As far as I understand, the only 
complication is proper socket destructors so we can put_page() the memory.

Right now sendfile() is only usable for read-only files.  It's not 
usable for files that change, or non-file memory.

>   
>>> Or perhaps simple send to a local multicast group and let
>>> some netfilter module turn that into regular UDP.
>>>  
>>>       
>> Sounds hacky and rooty.
>>     
>
> rooty? Everyone can send to all directions anyways.
>
> It wouldn't be perfect, but quite usable as a short term solution
> for a production server.
>   

I meant, you need root to insert that netfiler module.  It's workable as 
a one off but it's not something reusable.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

