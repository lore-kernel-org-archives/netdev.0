From: "Alex Aizman" <alex@neterion.com>
Subject: RE: Intel and TOE in the news
Date: Mon, 21 Feb 2005 11:34:08 -0800
Message-ID: <000001c5184c$5599c890$0100a8c0@OFFICEONEATHOME>
References: <42194972.8060303@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "'Jeff Garzik'" <jgarzik@pobox.com>, "'Andi Kleen'" <ak@muc.de>,
        "'Leonid Grossman'" <leonid.grossman@neterion.com>,
        "'rick jones'" <rick.jones2@hp.com>, <netdev@oss.sgi.com>
In-Reply-To: <42194972.8060303@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > Alternative: wait until Xframe II adapter w/MSI-X..
> 
> How does that help with MSI?

Does not help with MSI, helps to scale.

Btw, there's one alternative to MSI/MSI-X idea that in theory should
help to scale with CPUs. In a month or so I might get time to try it
out.

> The infiniband Linux driver is already using multi-MSI.  You 
> are behind the times :)

That's just great. Where, which kernel?

2.6.11-rc4 MSI-HOWTO still says "Due to the non-contiguous fashion in
vector assignment of the existing Linux kernel, this version does not
support multiple messages regardless of a device function is capable of
supporting more than one vector." 

2.6.11-rc4 MTHCA driver still does request_irq() just once for MSI
(note: MSI, not MSI-X). 

> Despite Andis assertion that theres value in amortizing the 
> locks, the benefits are highly missing on a generic level 
> unfortunately. Locking overhead is like the 50th item on 
> things you have to worry about
> - so i wouldnt even start worrying about this. 

That's probably true. Not 50th, 5th but still.

>  Yes when queue length/batch increases you're risking to load the L2 
>  twice for the same skb. Which is the most expensive operation.... 
>  Forwarding profiles show most functions where cache misses occur.

I wonder if alloc_skb_from_cache() will help to relieve the pressure on
memory at multi-Gbps receives.

Alex
