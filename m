From: Pedro Fortuna <pedro.fortuna@gmail.com>
Subject: Re: filtering packtes before OS takes care about them
Date: Tue, 1 Mar 2005 00:30:51 +0000
Message-ID: <db95d40c05022816301520b0a6@mail.gmail.com>
References: <09766A6E64A068419B362367800D50C0B58A17@moritz.faps.uni-erlangen.de>
	 <7bca1cb50502281209798e8a00@mail.gmail.com>
Reply-To: Pedro Fortuna <pedro.fortuna@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
In-Reply-To: <7bca1cb50502281209798e8a00@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,
I was searching for something like this also. 
In my case, I'll need to intercept all outgoing IP packets and change
them (including L2 frame) before they are passed to the network
interface driver.
The changes are: 
-modify the ethertype number in the L2 frame (e.g. DIX frames) to a
private not used one
-complety modify the IP packet header and payload
After this, the packets are sent on their way (passed to the network driver)

The reverse operation is applied to incoming IP Packets in the destination host.

I didnt investigate the packet_type example you provided but I hope I
will be able to used for the purposes I explained.

Best Regards,
Pedro Fortuna


On Mon, 28 Feb 2005 14:09:56 -0600, Asim Shankar <asimshankar@gmail.com> wrote:
> > i need a possibility to catch IP4 packets (from ethernet devices) before OS' netmodules (IP, UDP, TCP, ICMP, ARP, ROUTE, NETFILTER ...) takes care about them and
> > * to delete them from input buffer such that OS' netmodules can't receive them
> > * to modify packet headers and move packets to interface related output buffers
> > * to keep them in input buffers such that OS' netmodules can take care about them.
> 
> You can process packets even before ip_rcv() gets them by registering
> your own packet handler (struct packet_type) using dev_add_pack().  I
> have a small sample at:
> http://limnos.csrd.uiuc.edu/notes/code-samples/samples/kernel/packet_type/packet_type_test.c
> This may not be the cleanest way, but it isn't that dirty either.
> 
> Also see:
> http://www.phrack.org/show.php?p=55&a=12
> 
> -- Asim
> 
>
