From: Oskar Andreasson <blueflux@koffein.net>
Subject: [RFC] Badly documented sysctl?
Date: Fri, 1 Nov 2002 20:22:47 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0211012014340.20535-100000@laptop1.agatha>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I just started checking out the /proc/sys/net/ipv4/route/error_cost and 
error_burst sysctl's. According to 
linux/Documentation/filesystems/proc.txt:

----

error_burst and error_cost
--------------------------

These parameters are used to limit the warning messages written to the
kernel log from the routing code.  The higher the error_cost factor is,
the fewer messages will be written. Error_burst controls when messages
will be dropped. The default settings limit warning messages to one every
five seconds.

----

I just spent some time reading the source code in question, and if I am 
not totally off base... this is totally wrong? I am currently checking 
linux/net/ipv4/route.c, and if I am right, it limits how many 
ICMP_DEST_UNREACH we are sending to a specific host, and _possibly_ it 
will also printk() in the ip_rt_send_redirect() function. I don't know for 
sure, but I _think_ the default settings will limit ICMP_DEST_UNREACH 
sending in ip_error() to 5 per second... 

If anyone would shed some light on this, I would be tremenduously happy!

----
Oskar Andreasson
http://www.frozentux.net
mailto:blueflux@koffein.net
