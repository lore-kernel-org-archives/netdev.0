From: Thomas Graf <tgraf@suug.ch>
Subject: Re: source routing - bug?
Date: Wed, 15 Jun 2005 03:05:48 +0200
Message-ID: <20050615010548.GE22463@postel.suug.ch>
References: <Pine.BSI.4.61.0506061455340.11929@malasada.lava.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Tim Newsham <newsham@lava.net>
Content-Disposition: inline
In-Reply-To: <Pine.BSI.4.61.0506061455340.11929@malasada.lava.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Tim Newsham <Pine.BSI.4.61.0506061455340.11929@malasada.lava.net> 2005-06-06 15:02
> Using the netcat utility I run tests from machine A:
> 
>    $ nc -g B C 3333
>        I see packets forwarded to B then on to C and the connection
>        completes successfully.
> 
>    $ nc -g A -g B C 3333
>        I see packets forwarded over lo to A, and no further packets
>        are sent over lo or eth0.  Machines B and C receive no packets.

A 127.0.0.1 source address is considered martian by the source
validation code as proposed by rfc1812. You should see warnings
in the console if you have martian logging enabled.

>    $ nc -g B A 3333
>        I see packets forwarded out over eth0 to B and then back to A
>        but machine A never seems to accept the packets or reply with
>        a SYN or RST.

A will do a route lookup of [src=A dst=A] which results in your
local route being returned. Again this violates rfc1812 because
that route will not be a unicast route but a local one. A martian
source warning should be logged if enabled.
