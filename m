From: Ben Greear <greearb@candelatech.com>
Subject: Re: hard_start_xmit and Linux bridging
Date: Thu, 09 Sep 2004 16:30:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4140E782.2000505@candelatech.com>
References: <FD52892BD296D71183B400065BFCB6900EDB4C74@il02exm12>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lewis Adam-CAL022 <Adam.Lewis@motorola.com>
In-Reply-To: <FD52892BD296D71183B400065BFCB6900EDB4C74@il02exm12>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Lewis Adam-CAL022 wrote:
> Hi all,
> 
> I tried going to the bridge@lists.osdl.org for this question but got no response, I'm hoping somebody here has had a similar experience as me.
> 
> Basically, I put my wlan0 driver in a bridge with eth0.  When my hard_start_xmit() function is called (as a result of a packet received on eth0 and bridged to my driver), the skb that I am passed contains an extra four bytes (e.g. the Ethernet FCS).  
> 
> In my mind, this should be stripped off.  But I have looked at all the open source net drivers I could find and nobody seems to care.  Is there a way to know if the skb has been forwarded by a bridged interface?  If I forward on the extra bytes, then a 1500 byte packet becomes 1504 and fails the MTU check on the other side of the wireless interface (when it is passed back to eth0).
> 
> TIA,
> Adam

I added some ioctls to allow one to turn on the ability to receive the CRC, but I
don't know of any drivers that include it by default.

What driver/hardware is your eth0 device?

How are you determining the size, by the skb->len ?

Does tcpdump/ethereal show the extra 4 bytes if you sniff eth0 w/out bridging?

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
