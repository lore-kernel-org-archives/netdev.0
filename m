From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: PATCH Re: udp weirdness
Date: Tue, 01 Oct 2002 12:16:45 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D99CA6D.5020808@nortelnetworks.com>
References: <200210011531.TAA19943@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.CA, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

kuznet@ms2.inr.ac.ru wrote:

 > But not all the errors are queued,
> only those which are supported asynchronously. ENOBUFS is still not.
> F.e. when packet is dropped lately (some qdiscs do this, dropping already
> queued packets to give place for another ones) ENOBUFS is not sent back.

Hmm...so even with IP_RECVERR I may not be notified if the packet is 
dropped?


>>			     there doesn't seem to be a lot of 
>>documentation about it.
>>
> 
> Damn! (I'm sorry) It is documented _very_ well, thanks to Andi.
> I really hate this mode when people do not worrying even to look to manpages
> before pronouncing such statements.
> 
> man recvmsg
> man ip

Yes, I looked at both of those, and man udp as well.  My point about a 
lack of documentation was more related to corner cases and exactly what 
gets returned when.  The example above (where there are cases where no 
errors are returned even with IP_RECVERR turned on) is not mentioned 
anywhere in the documentation.

I write code for a telephony softswitch.  We are running a legacy app on 
top of an emulator on top of linux.  I want to ensure that my packets 
either a) got out onto the wire, or b) my app got an error message back 
explaining why the message didn't get onto the wire so that it can 
decide how to proceed.

Now my overall bandwidth requirements aren't too bad, but the traffic is 
bursty, with a batch of messages being sent in a tight sendto() loop.  I 
do NOT want messages to be silently dropped in the kernel with no error 
returned.

Chris
