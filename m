From: Andrew McGregor <andrew@indranet.co.nz>
Subject: Re: ipv6 stack seems to forget to send ACKs
Date: Fri, 10 Jan 2003 00:55:22 +1300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <27430000.1042113322@localhost.localdomain>
References: <20030108130850.GQ22951@wiggy.net>
 <20030109123857.A15625@bitwizard.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Rogier Wolff <R.E.Wolff@BitWizard.nl>, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org
In-Reply-To: <20030109123857.A15625@bitwizard.nl>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



--On Thursday, January 09, 2003 12:38:58 +0100 Rogier Wolff 
<R.E.Wolff@BitWizard.nl> wrote:

> On Wed, Jan 08, 2003 at 02:08:50PM +0100, Wichert Akkerman wrote:
>>

Looked normal and then:

>
>> 13:57:40.282351 2001:968:1::2.8000 > tornado.wiggy.net.33035: .
>> 9359225:9360433(1208) ack 1 win 5712 <nop,nop,timestamp 369670744 846103>
>
> But now: No ack! Funny.

Might be SACK deciding not to...

>> 13:57:40.284307 2001:968:1::2.8000 > tornado.wiggy.net.33035: .
>> 9360433:9360653(220) ack 1 win 5712 <nop,nop,timestamp 369670744 846103>
>
> Another packet, no ack!
>
>> 13:57:40.297307 2001:968:1::2.8000 > tornado.wiggy.net.33035: .
>> 9360653:9361861(1208) ack 1 win 5712 <nop,nop,timestamp 369670745 846104>
>> 13:57:40.297376 tornado.wiggy.net.33035 > 2001:968:1::2.8000: . ack
>> 9359225 win 32616 <nop,nop,timestamp 846111 369670744,nop,nop,sack sack
>> 1 {9360653:9361861} >
>
> Another packet, but this time it SACKs  the just-recieved packet. It looks
> as if the two packets inbetween somehow were not recognized as belonging
> with this connection.

or SACK forgot about them?

> Two more packets, and still more hints towards the other machine that
> we're missing 9359225-9360653
>
>> 13:57:40.568652 2001:968:1::2.8000 > tornado.wiggy.net.33035: .
>> 9359225:9360433(1208) ack 1 win 5712 <nop,nop,timestamp 369670773 846113>
>
> So, it retransmits the first. but we don't see it as beloging to
> this connection or something, so it gets ignored.

or we're waiting for the other one to ACK them both in one go?

> It looks as if somehow those two packets 9359225:9360433 and
> 9360433:9360653 get  mangled in a way as to invalidate the checksum. This
> would cause "silent drop"  of these packets before they were acked....

Could be data dependant, so there's a pattern in the packet contents that 
causes this?

> Can you check the stats counters, to see if they are indeed dropped?
>
> 				Roger.
