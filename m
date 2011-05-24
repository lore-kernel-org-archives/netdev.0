From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: 2.6.39: ipv6 tcp connections hanging on transmit
Date: Tue, 24 May 2011 15:09:21 -0700
Message-ID: <4DDC2C91.6060408@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: NetDev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When I use ssh over ipv6 to connect to my machines, it works fine for
command-line interaction until there's a large output (ps alxw, ps -l,
etc), whereupon the connection hangs.  It appears to be about when it
would send an MTU-sized packet.

Logging in with ssh over ipv4 works fine.

The outputting processes terminate OK, but they leave queued data in the
socket:

# netstat
Proto Recv-Q Send-Q Local Address               Foreign Address             State      
[...]
tcp        0   5776 2001:470:a816:0:230:48f:ssh 2001:470:a816:0:e45e::47865 ESTABLISHED 
tcp        0  26688 2001:470:a816:0:230:48f:ssh 2001:470:a816:0:e45e::55428 ESTABLISHED 
tcp        0      0 2001:470:a816:0:230:48f:ssh 2001:470:a816:0:e45e::55426 ESTABLISHED 
tcp        0   5856 2001:470:a816:0:230:48f:ssh 2001:470:a816:0:e45e::55434 ESTABLISHED 

and the corresponding ssh sessions are hung forever.

The path to the host is over openvpn bridged to the host's lan.  The
path MTU is 1500, verified with "traceroute6 --mtu" and "ping -s 1500"
works.

The network device is a bridge containing a single ethernet device: an
Intel 82574L using the e1000e driver.

I think this regression appeared in .38/.39, but unfortunately I haven't
had a chance to go back and systematically test older kernels yet.

Any clues, suggestions, further information I can provide, etc?

Thanks,
    J
