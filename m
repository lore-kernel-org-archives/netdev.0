From: James Ketrenos <jketreno@linux.jf.intel.com>
Subject: Limiting frame re-encryption with TCP retries...
Date: Fri, 09 Jul 2004 16:44:14 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40EF11AE.9020008@linux.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


The recent 'pskb change in dst-output' thread reminded me that I've been meaning 
to ask about this...

With wireless drivers TCP retransmission occur pretty frequently.  With WEP, 
etc. this means the driver has to re-encrypt the same frame with each retry.

In one of the snapshots for ipw2100 I was encrypting over the SKB provided from 
the kernel via the xmit and putting new data at the head and tail (to hold the 
IV and ICV).  Anyway, that broke all sorts of tools (ip_conntrack, netfilter, etc.)

So now I allocate a new SKB on reception of an SKB from the networking stack and 
encrypt the copy.  The question I have -- is there a way to attach the new SKB 
to the old one such that if the transmit is retried I can check that data and 
don't have to re-encrypt it?

 From the sk_buff.h description of the cb field, I only get to use that data 
while I control the SKB.  Even if this weren't the case it wouldn't quite do 
what I need.  Ideally I want to be able to attach the encrypted SKB to the 
original SKB such that when the network stack gets the ACK it can nuke the 
original SKB and the encrypted one and the driver doesn't have to know.

This gets complicated further when 802.11 level fragmentation is required -- and 
one incoming SKB results in N outbound 802.11 fragments, each encrypted separately.

Any ideas?  I'm not too familiar with the internals of the kernel's network 
stack so if there is something obvious that I should have seen already, please 
point it out to me :)

Thanks,
James
