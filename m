From: =?ISO-8859-1?Q?Roar_Bj=F8rgum_Rotvik?= <roarbr@tihlde.org>
Subject: Re: Required resources on network driver programming
Date: Mon, 20 Dec 2004 10:44:05 +0100
Message-ID: <41C69EE5.7070907@tihlde.org>
References: <20041220074535.64217.qmail@web52208.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux lover <linux_lover2004@yahoo.com>
In-Reply-To: <20041220074535.64217.qmail@web52208.mail.yahoo.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

linux lover wrote:
>  
> Hi all,
>                   I am newbie to Linux kernel
> programming. I want to write my own virtual network
> device driver that take every packets from IP layer
> just print the contents of packet(header part with its
> starting addresses only) and send it to actual device
> driver for packet transmission and at receiving end
> receive packet from NIC card again print the header
> addresses and send it to upper layer for normal packet
> processing.
>                  I require help about where can i get
> resources or any book for writing virtual network
> driver with SAMPLE EXAMPLES?

Another mail gave you pointers to driver programming.
Here are links to TUN/TAP, a virtual ethernet (or point-to-point) device 
driver in the Linux kernel.

With TAP you have a virtual ethernet device, where the device driver is 
replaced with a userspace application (that you write) that receives all 
data sent to the tap device (for instance tap0) from the linux kernel 
network stack.
This data contains ethernet header + all other payload (like IP-header + 
IP data with either TCP/UDP or arp-packets)..

Your userspace app may also send data to a tap-device and this data will 
be sent to the linux network stack like it came from a real ethernet device.

So your userspace app may do whatever it want with the data, it may 
print out the contents of the IP layer and forward the data to another 
PC using the real ethernet device (eth0, or another network medium).
The other PC may do the opposite, i.e. receive the data from the 
ethernet device and send then to the tap device.

Your application may even encapsulate the data send between the two PC 
in any protocol you may like (you got tunneling).

If you wanted to do all in kernel mode this is not what you want, but 
tun/tap code may give you some tips on how to create a virtual ethernet 
device..

See these links:
http://lxr.linux.no/source/drivers/net/tun.c?v=2.6.8.1
http://vtun.sourceforge.net/tun/
http://vtun.sourceforge.net/tun/faq.html

-- 
Roar B. Rotvik
