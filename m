From: shemminger@osdl.org
Subject: Re: Fw: [Bugme-new] [Bug 3777] New: tun driver fails to open
     whenbuilt in, must be modular
Date: Fri, 19 Nov 2004 21:32:45 -0800 (PST)
Message-ID: <60957.63.170.215.71.1100928765.squirrel@www.osdl.org>
References: <20041119150808.578154d3.akpm@osdl.org>
    <419ED5CB.3080106@web.de>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <419ED5CB.3080106@web.de>
To: "Michael Renzmann" <mrenzmann@web.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Hi.
>
> Andrew Morton wrote:
>> Problem Description: kernel will not assign/open a tun device when tun.o
>> is
>> compiled as a built-in. ifconfig gives 'unable to open /dev/net/tun'
>> error.
>> compiling as a module fixes.
>
> If anyone can give me a small general hints for what might be the cause
> of this problem, I could take a look at it. I already have some patches
> for tun.o (that needs to be sent to the maintainer), another one doesn't
> hurt :) But since I'm not yet too experienced with programming of kernel
> modules, any help would be appreciated.
>
> Bye, Mike
>

See if it successfully registers with the misc driver (misc_register).
I suspect it is an initialization order type thing. Probably the
code to register with the misc driver (to create the device) should
just be delayed until the network device is brought up (ie dev->open)
is called.

Good luck.
