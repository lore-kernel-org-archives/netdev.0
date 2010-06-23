From: Brian Bloniarz <bmb@athenacr.com>
Subject: Re: SO_REUSEPORT
Date: Wed, 23 Jun 2010 12:09:25 -0400
Message-ID: <4C2231B5.10401@athenacr.com>
References: <AANLkTimxGK93hnV9-jGZAeeJ_JnrWCTaq-dkDvfUW6St@mail.gmail.com> <06r8f7-jsn.ln1@chipmunk.wormnet.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alexander Clouter <alex@digriz.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sprinkles.athenacr.com ([64.95.46.210]:13622 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753727Ab0FWQJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 12:09:26 -0400
In-Reply-To: <06r8f7-jsn.ln1@chipmunk.wormnet.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/23/2010 03:54 AM, Alexander Clouter wrote:
> Hi,
> 
> Tim Prepscius <timprepscius@gmail.com> wrote:
>>
>> Is SO_REUSEPORT available 2.6.ish - (or any version)?
>> I've been searching for a conclusive answer to this question and can't
>> find it.
>>
> That will be a no then:
> ----
> alex@berk:~$ grep SO_REUSEPORT -r /usr/src/linux-2.6-stable/include/
> /usr/src/linux-2.6-stable/include/asm-generic/socket.h:/* To add :#define SO_REUSEPORT 15 */
> ----
> 
>> (yes I know of SO_REUSEADDR, and I know the difference between this
>> and *PORT, and yes I know that I *definitely* need SO_REUSEPORT, no,
>> I'm unconcerned this may/may not be part of a "standard," yes I know
>> it is implemented differently on different systems, yes I know there
>> may be security problems, but no, I don't care about this.)
>>
> This really sounds like the sort of thing (for TCP/SCTP) where the 
> 'master' process would maintain the listening socket and upon accept() 
> you would fork() or pass the file descriptor off to a thread.  This 
> would make SO_REUSEPORT un-necessary and also your code would be 
> portable.
> 
> If you are doing things with UDP (or another datagram-esque stream) then 
> your master listener could pass off the incoming packets to 
> threads/processes trivially.
> 
> Of course this depends on what you are doing, but my opinion is that the 
> functionality has been unneeded so far by people in the kernel, so *I* 
> must be doing something wrong ;)

Tom Herbert gave a pretty great description of why you
might want this functionality in his original patch submission:

http://kerneltrap.org/mailarchive/linux-netdev/2010/4/19/6274993

If you follow that thread though, there wasn't consensus about
the best architecture & API for it, and nothing has made it
yet.

I'm adding netdev to the cc, AFAIK it's the place for discussing
stuff like this.
