From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: reminder to netdriver authors
Date: Sun, 04 Jul 2004 11:05:21 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40E81CB1.5070403@pobox.com>
References: <1088910801.1041.818.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1088910801.1041.818.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> 1) When you have no space in your DMA 
> 
> Do NOT stash the packet in your ring
> a) netif_stop_queue()
> b) return 1
> 
> A _lot_ of drivers dont follow this rule. A good driver to copy
> from if you are into cutnpaste is the e1000.
> If you stash the packet in your ring then return 1 you are in deep 
> doodoo friend. 
> 
> 2) return a 0 only when you have succesfully put things on DMA.
> Returning 0 always is not a BadThing. Most drivers do this.
> It is a little less efficient at the top layer for each batch of packets
> sent to the driver and you end up stopping the netif at this point.
> 
> 3) In case of error probably return a 1 and dont try anything funny
> with the skb. Dont put on your DMA or try to free it or muck with it in
> any way. You probably should whine if you have too many errors in
> sequence. 
> 
> Someone with more time than myself can audit the drivers - I have seen
> these issues.

FWIW some of this is related to my own lack of knowledge, long long ago, 
and mistakes made long ago get cut-n-pasted into the present.

I will edit this email, and add it to 
Documentation/networking/netdevices.txt.

Please (to all) consider netdevices.txt as a general text describing how 
to (or how not to) write net drivers.  Any patches -- or even random 
comments you would like me to turn into patches -- are accepted.  Share 
the knowledge!

	Jeff
