From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [PATCH] Ethernet Bridging: Enable Hardware Checksumming
Date: Thu, 19 May 2005 08:10:13 -0700
Message-ID: <428CAC55.4000202@us.ibm.com>
References: <E1DYayB-0005Sk-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jon Mason <jdmason@us.ibm.com>, shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DYayB-0005Sk-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

> Jon Mason <jdmason@us.ibm.com> wrote:
> 
>>checksum and scatter gather as features of the bridge device.  In the 
>>case that the physical ethernet device does not support scatter 
>>gather or hardware checksum, dev_queue_xmit() will check the
>>dev->features and do the necessary linearization and calculate the
>>checksum.
> 
> 
> Unfortunately skb_linearize is a lot more expensive than not
> generating the non-linear skb's in the first place.
> 
> So this is going to hurt people using the bridge devices over
> physical devices that don't support SG.

Fair point - though I would argue that devices that
support SG are much more common now - so optimizing
for the more common case might be preferable - since
people using bridging with devices that support
checksum offload are taking quite a hit when they
do bridging - perhaps this could be a conditional?

thanks,
Nivedita
