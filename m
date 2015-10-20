From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Tue, 20 Oct 2015 14:45:58 +0100
Message-ID: <56264596.90104@oracle.com>
References: <20151019095938.72ea48e6@xeon-e3>	 <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com>	 <562594E1.8040403@oracle.com>	 <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>	 <56261092.7080003@oracle.com> <1445347173.22974.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:19226 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752155AbbJTNqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 09:46:05 -0400
In-Reply-To: <1445347173.22974.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/10/2015 14:19, Eric Dumazet wrote:

>> That may be how Linux implements accept(), but I don't see anything
>> about refcounting in the POSIX spec for accept().
>
> That's an internal implementation detail. POSIX does not document linux
> kernel overall design and specific tricks.

No, neither does it document Solaris kernel design, or *BSD design, or 
Windows design. It does however specify what the externally observable 
behaviour has to be in order to be POSIX compliant.

> linux is GPL, while Solaris is proprietary code. There is quite a
> difference, and we do not want to copy Solaris behavior. We want our own
> way, practical, and good enough.

I don't see what the licensing terms of particular implementations have 
to do with POSIX, indeed as far as I can tell POSIX says nothing at all 
about the subject. It's therefore not pertinent to this discussion.

I'm not expecting Linux to copy every Solaris behaviour, if I was I 
might for example be suggesting that Linux dropped support for the 
SO_RCVTIMEO and SO_SNDTIMEO setsockopt() options on AF_UNIX sockets, 
because Solaris doesn't currently implement those options. That would 
clearly be a ridiculous stance for me to take, what I've actually done 
is logged a bug against Solaris because it's clearly something we need 
to fix.

What I do think is reasonable is that if Linux claims POSIX conformance 
then it either conforms or documents the variant behaviour and as I've 
said I don't believe is does conform in the case of shutdown().

> If POSIX makes sense we try to be compliant. If not, we do not.

That's one possible design option. However in this case the Linux 
manpage claims the Linux behaviour is POSIX compliant and as far as I 
can tell it isn't. As I've already said several times, I agree there's 
probably not much that can be done about it without causing breakage, 
which is why I suggested simply documenting the behaviour may be the 
best option.

And I still haven't seen any reasoning behind the Linux close() and 
poll() behaviour on sockets that are in the listen state.

> If you are interested, take a look at fs/* code, and try to implement
> your proposal and keep good performance.
>
> You might find a clever way, without infringing prior art. We did not
> yet.

I might, but contractually I can't, unfortunately.

-- 
Alan Burlison
--
