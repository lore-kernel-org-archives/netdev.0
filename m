From: "Carlos Velasco" <carlosev@newipnet.com>
Subject: Re: Bug? ARP with wrong src IP address
Date: Thu, 24 Jul 2003 17:28:27 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307241728270476.0031BAB0@192.168.128.16>
References: <Pine.LNX.4.44.0307241352340.2177-100000@l>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Bart De Schuymer" <bdschuym@pandora.be>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <Pine.LNX.4.44.0307241352340.2177-100000@l>
To: "Julian Anastasov" <ja@ssi.bg>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 24/07/2003 at 14:04 Julian Anastasov wrote:

>	The src IP in the ARP probe is a hint. In most of the
>cases it is ignored. But the receiver has the right to answer
>based on it. You know, the reply is sent to the sender's hwaddr,
>not to the src IP. Also, Linux always replies if the remote host asks
>for IP configured on loopback interface. So, there is no problem.
>If the remote system has your patch, there is also no problem.
>What kind of problems do you see except the loopback IP as sender
>IP? Dropped probes? Unanswered probes?

Julian,

The problem is more complicated than the simplified setting I have builded for describing the bug:
Real setting and meaning of the lo interface is because I'm using IOS Load Balancing in dispatched mode on Cisco Catalyst 6500.
This cause packets being sent to a server farm of Linux boxes with destination IP the one configured on the loopback interface in all machines.
In the ethernet interface all Linux boxes have diferent IP address and the balancing device send the packets through any of these interfaces, choosing the "leastconnections" server.
Thus, the load balancing device only change the mac address of the real packet on the fly sending it to one of the real servers where it's accepted cause of destination IP is the loopback IP address on every Linux machine.

Problem is when the packet go back to the balancing device, as they send ARP request with loopback source IP address, that cause Cisco device not to reply the ARP request.
I have tried different IOS and Cisco devices, no one reply this ARP request.


As you have stated in your last e-mail I checked the RFC (if I'm not wrong it's rfc826) to see if when replying an ARP request the source IP address need to be correct and stepped into this:

"
      ?Is the opcode ares_op$REQUEST?  (NOW look at the opcode!!)
      Yes:
	Swap hardware and protocol fields, putting the local
	    hardware and protocol addresses in the sender fields.
	Set the ar$op field to ares_op$REPLY
	Send the packet to the (new) target hardware address on
	    the same hardware on which the request was received.
"

According to this, I think YOU ARE RIGHT and the source IP address should not be checked when replying to this ARP Request.

I have setup another setting forcing a windows machine to be the default route of the linux box and see if windows OS replied to this ARP request... and IT DID.

For now, I'm going to contact Cisco TAC and open a case to see if the bug is in Cisco IOS.
Will keep you posted about this issue if you want to.

Regards,
Carlos Velasco
