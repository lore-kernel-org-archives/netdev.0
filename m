From: Ben Greear <greearb@candelatech.com>
Subject: An interface goes away while a socket is bound to it..what happens?
Date: Mon, 17 Jan 2005 19:28:27 -0800
Message-ID: <41EC825B.4030603@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've been playing around with multi-link PPP interfaces, and
have noticed something strange (kernel 2.6.9+hacks, pppd 2.4.1b2 ).

My application binds tight to the local IP address and the
interface.  In the instance tested, I was using UDP traffic
but TCP seems to behave the same.

Suppose I am pulling the T1 interfaces to cause
a failover:   If I pull both at once for a few seconds and then
replace them, ppp0 will dissappear, and then quickly be rebuilt.

My application discovers interfaces based on their name, by
parsing /proc/net/dev every 30 seconds or so.  Often, it does not
detect that the interface ever went away (and came back), so it
cannot take any evasive action.

The interesting part to me is that I do not appearantly see any errors
while continuing to send UDP packets on the socket that was bound to the
original ppp0 interface, and yet no packets are ever routed over the new
ppp0 interface.  I would expect it to either fail the write, or to just
magically keep working.

So first:  Is this happily-write-down-a-black-hole issue a bug?

and:  What is a good way to discover the coming and going of interfaces
    as it happens?  (I looked around Netlink, but it does not appear to do
    notifications.)

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
