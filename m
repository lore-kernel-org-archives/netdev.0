From: "Carlos Velasco" <carlosev@newipnet.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Mon, 28 Jul 2003 01:40:47 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307280140470646.1078EC67@192.168.128.16>
References: <Pine.LNX.4.53.0307272239570.2743@vialle.bloemsaat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: layes@loran.com, torvalds@osdl.org, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <Pine.LNX.4.53.0307272239570.2743@vialle.bloemsaat.com>
To: "Bas Bloemsaat" <bloemsaa@xs4all.nl>, marcelo@conectiva.com.br,
   netdev@oss.sgi.com, linux-net@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 27/07/2003 at 22:52 Bas Bloemsaat wrote:

>I learned from the kernel sources that any NIC receiving an ARP request
>for any local IP adress would respond to that request. Among others, that
>has the following implications:
>- when you have two NICs same ethernet segment, only one of them is used:
>they both respond to any ARP request. As only the first response is ever
>used (fasted router), only the NIC that responds first receives any
>traffic. This NIC may or may not be bound to the destination IP. It may
>not even be reachable because of iptables-rules. This also defeats a
>common form of load balancing.

I stepped into the same problems you have reported here.

There's a feature to do linux to behave like other OS and systems, called "hidden".
However it's not included into the default kernel main stream. Although IMHO IT SHOULD BE.
Here is the patch:
http://www.ssi.bg/~ja/#hidden

Extracted from http://www.linuxvirtualserver.org/docs/arp.html:
===
Linux kernel 2.0.xx doesn't do arp response on loopback alias and tunneling interfaces, it is good for the LVS cluster. However, Linux kernel 2.2.xx does all arp responses of all its IP addresses except the loopback addresses (127.0.0.0/255.0.0.0) and multicast addresses. 
===

Currently linux is the only OS those I have tried with this behaviour:

Solaris 8 -> does not send ARP reply of other interface.
Cisco -> does not send ARP reply of other interface.
Windows 2000, XP -> does not send ARP reply of other interface.
Linux 2.6.0-pre1, 2.4.20, 2.4.21 -> DOES send ARP reply of other interface


>- when you have two NICs on seperate ethernet segments, for example on a
>firewall, it is possible to probe one NIC for the IP address of the other.
>This can be used to gain information about the inside network of the
>firewall, which is a (minor) security risk. While this is not really
>practical because every IP address has to be tried, often the inside is of
>a limit range (10.x.x.x, 192.168.x.x), which makes it useful.

Yes, minor security problem arise with this _INTENTIONAL_ behaviour of linux networking.

The official approach is that you play with routing and netfilter/arpfilter to solve this _INTENTIONAL_ behaviour and make linux behave like other OS do.

The unofficial (not in the kernel main stream, reason unknow) is to use the "hidden patch".
This works using a /proc switch: /proc/sys/net/ipv4/conf/<XXX>/hidden, so it should not break anything.
However is not into the main kernel.

Regards,
Carlos Velasco
