From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: linux-wireless mailing list
Date: Wed, 10 Mar 2004 13:25:48 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <404F5DAC.4020807@pobox.com>
References: <Pine.LNX.4.58.0403031656090.22365@marabou.research.att.com> <40469DA1.9090502@pobox.com> <20040305040352.GA16669@bougret.hpl.hp.com> <404F5461.80000@pobox.com> <20040310180602.GB9531@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pavel Roskin <proski@gnu.org>, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20040310180602.GB9531@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jean Tourrilhes wrote:
> 	The current API is already completely 32<->64-bit
> safe. Wireless Tools have been used on Alpha since the end of the
> 90's. The code to support 32 bit user space on 64 bit kernel was
> trivial and concern only a single pointer, and such pointer would not
> exist when using RtNetlink. So, I claim that when using RtNetlink, the
> API would be entirely 32<->64-bit safe.

Yes, I agree.


> 	You point about type safety is perfectly valid.
> 	I believe that this is a tradeoff. The design reason to have a
> single type of handler, apart from the space saving, was to allow a
> driver to hook a common handler to multiple commands. I've used that
> in a few cases, because it made the driver code simpler.
> 	So far, we never had any problem with regards to type
> safety. Maybe it's because wireless driver authors are very clever ;-)

A type-specific wireless_ops is something that I definitely want to see.

It reduces code in the drivers, by increasing the amount of code that 
can be made generic.  It's much better to, for example, have all the 
user data (length, etc.) validate checks, and capable(CAP_xxx) security 
checks all in one place.  And perhaps more importantly, a type-specific 
wireless_ops makes it harder for driver writers to screw up ;-)  That's 
an important attribute in a driver API, I've come to learn...

	Jeff
