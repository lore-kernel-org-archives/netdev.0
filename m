From: "Eble, Dan" <DanE@aiinet.com>
Subject: MTU of related devices
Date: Wed, 16 Jun 2004 15:53:12 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C060DFCD9697A842B3189B458524FDC205D2D4@AIMAIL1.ai.aiinet.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I have two devices, where the traffic transmitted into one is encapsulated
and sent out the other (ethernet frames bridged over Cisco HDLC in my case),
and the MTU of the underlying device needs to be large enough to accommodate
the MTU of the encapsulated device plus its link layer header.  What is the
best way to handle this?  I have thought of a few things.

0. Have the encapsulated device change the underlying device's MTU when
necessary.  I would like this if there were only one encapsulated device,
but there could possibly be more.

1. Make both change_mtu() functions examine the other device's current MTU
and return -EINVAL when the requested value does not meet the constraints.
This is nice because it provides immediate feedback at the time of the
problem.  Its primary drawback is that it requires the MTUs to be changed in
a certain order.

2. Don't constrain the MTUs in change_mtu(), but drop all packets sent to
the encapsulated device when the MTU of the underlying device is too small
for the encapsulated device.  Dropping all packets is better than dropping
only the ones that are too large, because it can not be overlooked by a
lackadaisical admin who simply pings with a small packet to see if the link
is working.  I could either log a message, controlled by net_ratelimit(), or
I could simply declare that MTU is one of the things to check when a link
does not work.

Is any of these, or a variation, officially preferred over the others?
Thank you,
-- 
Dan Eble <dane@aiinet.com>  _____  .
Software Engineer          |  _  |/|
Applied Innovation Inc.    | |_| | |
http://www.aiinet.com/     |__/|_|_|
