From: Tim Newsham <newsham@lava.net>
Subject: Re: source routing - bug?
Date: Tue, 14 Jun 2005 15:15:23 -1000 (HST)
Message-ID: <Pine.BSI.4.61.0506141513050.28194@malasada.lava.net>
References: <Pine.BSI.4.61.0506061455340.11929@malasada.lava.net>
 <20050615010548.GE22463@postel.suug.ch>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050615010548.GE22463@postel.suug.ch>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>    $ nc -g A -g B C 3333
>>        I see packets forwarded over lo to A, and no further packets
>>        are sent over lo or eth0.  Machines B and C receive no packets.
>
> A 127.0.0.1 source address is considered martian by the source
> validation code as proposed by rfc1812. You should see warnings
> in the console if you have martian logging enabled.

I see the same behavior when the source address is explicitely bound
to an address belonging to a local NIC (-s option to netcat).

>>    $ nc -g B A 3333
>>        I see packets forwarded out over eth0 to B and then back to A
>>        but machine A never seems to accept the packets or reply with
>>        a SYN or RST.
>
> A will do a route lookup of [src=A dst=A] which results in your
> local route being returned. Again this violates rfc1812 because
> that route will not be a unicast route but a local one. A martian
> source warning should be logged if enabled.

Is there any way to enable routing for this case?  This is a
desirable source route at times.  I would hate to have to boot
FreeBSD every time I want to use this feature.

Tim Newsham
http://www.lava.net/~newsham/
