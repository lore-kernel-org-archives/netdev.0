From: "Carlos Velasco" <carlosev@newipnet.com>
Subject: Re: Bug? ARP with wrong src IP address
Date: Thu, 24 Jul 2003 01:34:03 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307240134030339.1EADABD4@192.168.128.16>
References: <Pine.LNX.4.44.0307240149480.1181-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <Pine.LNX.4.44.0307240149480.1181-100000@u.domain.uli>
To: "Julian Anastasov" <ja@ssi.bg>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 24/07/2003 at 2:01 Julian Anastasov wrote:

>> When linux machine tries to find out the mac address of 192.168.128.60
>with
>> ARP, it uses the loopback IP address (lo:2) as source insted of the IP
>address
>> of the ethernet interface (eth0).
>
>	You are right but the kernel tries to preserve the sender's
>IP. This helps the receiver to select the best interface
>to answer this ARP probe - the same where the IP packet will be
>accepted later. As there are different setups, the tuning of the
>ARP handling can be done better with user tools such as arptables
>and iparp.

Julian,

The linux box is trying to do an ARP request with a source IP address that has not sense in that ethernet network. It's imposible to obtain a reply in that way. Although the receiver would have a route to the loopback address through ethernet interface it would never reply such a ARP request.
IMHO it's a bug. Loopback IP address has not any sense on the eth0 network.

Linux receives the packet destination loopback address and then performs a lookup in the route table to reach the src address.
It takes the route (ex. default) and is on eth0 interface, then does the arp request.
As the route is in eth0, it must use the src IP address of eth0, not the loopback address.

If we have more than 1 IP address in eth0 (eth:0, eth:1) I suppose that the route table must distinguish the right interface for ARP.

I have tried to reproduce the same problem with a Cisco router with IOS 12.2(15)T5, but it works fine in Cisco.
I will try to test on Solaris 8, but I think the only problem is in linux.


>http://sourceforge.net/projects/ebtables/
>http://www.ssi.bg/~ja/#iparp

I didn't know about these tools.
I have taken a look on them, but they seem to be used for arp filtering?
I can't see how these tools can help me into this.

My workaround with linux is to use static arps for solving this problem (arp -s).

Regards,
Carlos Velasco
