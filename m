From: Ben Greear <greearb@candelatech.com>
Subject: Re: Net device queries.
Date: Sun, 10 Nov 2002 19:47:31 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DCF2853.4000908@candelatech.com>
References: <3DCE7B81.4070604@tpg.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bill Leckey <bleckey@tpg.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bill Leckey wrote:
> I've been coding an ethernet driver for some new hardware we're
> developing and while it's working, there are a few issues I'm still
> unsure of.  I couldn't find any archives for this list, so I'm
> suspecting I'm going to cover a lot of 'old ground'.  Most of my info 
> for coding ethernet drivers comes out of Rubini and Corbet's LInux 
> Device Drivers, and what I've gleaned from kernel sources
> 
> Firstly some background.  With these cards I can have up to 25 point to
> point connections (to the same destination machine, or 25 destination
> machines).  I have almost total control of what goes out on the wire, so
> I've chosen a minimal header that contains the type (passed in to
> hard_header) and a 16 bit field that contains misc other information.
> So, 32 bits, plus the data.  The hardware provides things like length,
> and CRC checking.
> 
> Currently I'm setting dev->hard_header_len to 4.
> 
> The part that concerns me is what I set dev->type, dev->addr_len and
> dev->flags to.
> 
> We don't technically have a hardware address so I set dev->addr_len to 0.

If you want to look like ethernet, it seems you would want at least a fake
MAC.  To me, it also sounds like you may want up to 25 net_devices, since
you have that many logical point-to-point connections.  (Similar to the
way VLAN works)

> 
> I set dev->type to ARPHRD_VOID, simply because I'm not sure what the
> consequences of setting it to anything else are.

Maybe you could get a serial number out of your device and then hash it
into MAC addresses?  The user can always change these with ifconfig or 'ip'
after your device initializes anyway...


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
