From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: anyone ever done multicast AF_UNIX sockets?
Date: Mon, 03 Mar 2003 17:29:14 -0500
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3E63D73A.2000402@nortelnetworks.com>
References: <3E5E7081.6020704@nortelnetworks.com>	<1046695876.7731.78.camel@pc-16.office.scali.no> 	<3E638C51.2000904@nortelnetworks.com> <1046720360.28127.209.camel@eggis1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org, davem@redhat.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Terje Eggestad <terje.eggestad@scali.com>
List-Id: netdev.vger.kernel.org

Terje Eggestad wrote:
> On Mon, 2003-03-03 at 18:09, Chris Friesen wrote:
>     Terje Eggestad wrote:
>     > On a single box you would use a shared memory segment to do this. It has
>     > the following advantages:
>     > - no syscalls at all
>     
>     Unless you poll for messages on the receiving side, how do you trigger 
>     the receiver to look for a message?  Shared memory doesn't have file 
>     descriptors.
>     
> OK, you want multicast to send the *same* info to all peers. The only of
> two sane reason to do that is to update the peers with some info they
> need to do real work. So when there is reel work to be done, the info is
> available in the shm. 

Okay, but how do they know there is work to be done?  They're waiting in 
select() monitoring sockets, fds, being hit with signals, etc.  How do 
you tell them to check their messages?  You have to hit them over the 
head with a signal or something and tell them to check the shared memory 
messages.
> If you *had* multicast, you don't know *when* a peer proccessed it. 
> What if the peer is suspended ??? you don't get an error on the send,
> and you apparently never get an answer, then what? The peer may also
> gone haywire on a while(1);

Exactly.  So if the message got delivered you have no way of knowing for 
sure that it was processed and you have application-level timers and 
stuff. But if the message wasn't delivered to anyone and you know it 
should have been, then you don't have to wait for the timer to expire to 
know that they didn't get it.

>     How do they know the information has changed?  Suppose one process 
>     detects that the ethernet link has dropped.  How does it alert other 
>     processes which need to do something?
>     
> Again, if you want someone to do something, they must ack the request
> before you can safely assume that they are going to do something.

Certainly.  My point was that if you're trying to handle all events in a 
single thread, you need some way to tell the message recipient that it 
needs to check the shared memory buffer.  Otherwise you need multiple 
threads like you mentioned in your project description.


Chris


-- 
Chris Friesen                    | MailStop: 043/33/F10
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com

