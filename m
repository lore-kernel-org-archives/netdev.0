From: Martin Hamilton <m@martinh.net>
Subject: NOARP and 2.4 kernels
Date: Wed, 12 Feb 2003 10:20:20 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E18iu04-0005Ba-00@mostly-harmless.lut.ac.uk>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi folks, what's the current thinking on this?

Once upon a time (2.2 kernel) it was made possible to mark an
interface as "hidden", in which case Linux wouldn't respond to ARP
who-has broadcasts for any IP address associated with the hidden
interface.

This feature was squished in the 2.4 kernel, though Julian Anastasov
has now implemented a number of alternate approaches to solving the
problem...

  http://www.linuxvirtualserver.org/~julian/#hidden

Is it likely that any of these will be making an appearance in (or
return to ;-) the canonical (Linus) kernel in the 2.4 series?

This feature is very useful for anyone trying to build server
clusters, e.g. using L4 switching.

Obviously one can always build a kernel which includes one of the ARP
hiding patches, but it would be much less painful to have this feature
back in the Linus kernel again and available in vendors' default
distributions without any heavy lifting being required.

If nothing else, loopback and dummy interfaces should surely not
respond to ARP broadcasts, which they currently (2.4.20/2.4.21-pre)
still appear to do.

If the NOARP flag means nothing, then it would help to avoid confusion
if the kernel was rigged so that attempts to set it result in an error
message (ifconfig eth0:0 -arp, ip link set eth0:0 arp off).  Likewise,
NOARP should not be set on dummy interfaces if it has no effect... ?

  # ifconfig dummy0 inet 10.9.8.7 netmask 255.255.255.255 broadcast 10.9.8.7 up     
  [root@mostly-harmless root]# ifconfig
  dummy0    Link encap:Ethernet  HWaddr 00:00:00:00:00:00  
            inet addr:10.9.8.7  Bcast:10.9.8.7  Mask:255.255.255.255
            UP BROADCAST RUNNING NOARP  MTU:1500  Metric:1
            RX packets:0 errors:0 dropped:0 overruns:0 frame:0
            TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
            collisions:0 txqueuelen:0 
            RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)

Thanks in advance for any thoughts :-)

Cheers,

Martin
