From: Jeff Garzik <jgarzik@mandrakesoft.com>
Subject: Re: [ANNOUNCE] NAPI patches for 2.4.19-rc1
Date: Thu, 11 Jul 2002 10:57:12 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <3D2D9CC8.5050200@mandrakesoft.com>
References: <Pine.LNX.4.44.0207102019160.2498-100000@beohost.scyld.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
List-Id: netdev.vger.kernel.org

Donald Becker wrote:
> The mdelay(300) is completely bogus.  While that is a typical period for
> autonegotiation to complete on a short link, the spec says that it can
> take up to 3 seconds, 10X longer, to complete autonegotiation.  Given
> that the driver must be able to handle a longer autonegotiation period
> and no link beat, why call mdelay() at all?

Ouch.  You are absolutely right, and I take the blame for not reviewing 
more closely.  That's what I get for trusting vendors too much ;-) 
[D-Link has been the one patching sundance and dl2k for a while now]

I've been meaning to go through several drivers and fix up the stupid 
assumptions they make about autonegotiation completion time.  There are 
a couple other drivers that do somewhat the same thing, though with a 
different [if equally silly] implementation.

And finally, most drivers need to be updated to follow the logic:  call 
netif_carrier_off().  Wait for autoneg complete and link OK, before 
calling netif_carrier_on().


> The driver also changes the transceiver settings to non-standard
> values.  Yes, the change might seem more descriptive, but the modified
> driver doesn't match the documentation or accept the options that other
> drivers do.  There is a value to consistency: "/bin/list" is more
> descriptive than  "/bin/ls", but you don't see any distribution trying
> to rename 'ls'... 

Which lines of code are you referring to?

This _might_ be a case where the docs are inaccurate, since the patch 
was done by D-Link with access to the chip designers.

	Jeff
