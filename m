From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: PATCH Re: udp weirdness
Date: Tue, 01 Oct 2002 13:17:34 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D99D8AE.3070205@nortelnetworks.com>
References: <200210011641.UAA20171@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.CA, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

kuznet@ms2.inr.ac.ru wrote:

>>Hmm...so even with IP_RECVERR I may not be notified if the packet is 
>>dropped?
>>
> 
> Do you not jest occasionally? :-) "Even" sounds interesting, because
> this kind of errors cannot be reported _principially_ without IP_RECVERR,
> providing asynchronous error reporting.

The point that I fundamentally need IP_RECVERR for async errors is 
interesting, I'll have to look into that.  Thanks for the pointer.

> Packet can be dropped, damaged _after_ they are successfully queued
> to the device. And this need not to be emphasized in documentation
> on IP_RECVERR, except for a section "FUTURE DEVELOPMENT".

This is certainly true, but I would hope that packets being damaged or 
dropped after being queued to the device would be a rare event.  It 
would still be good to have them reported though.

I understand the problems with regards to blocking sockets, since you 
can't block after the select() passes and select() doesn't know where 
the packet is going.  It seems that it should be pretty straightforward 
to enable ENOBUFS for nonblocking sockets though--am I missing something?

For now I'll play with SO_SNDBUF and IP_RECVERR.

Thanks,

Chris
