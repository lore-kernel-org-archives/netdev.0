From: Andi Kleen <ak@muc.de>
Subject: Re: Intel and TOE in the news
Date: 22 Feb 2005 18:27:29 +0100
Message-ID: <20050222172729.GA70246@muc.de>
References: <1108993498.1089.149.camel@jzny.localdomain> <200502211653.j1LGr3DD025897@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, "'rick jones'" <rick.jones2@hp.com>, netdev@oss.sgi.com,
        "'Alex Aizman'" <alex@neterion.com>
Date: Tue, 22 Feb 2005 18:27:29 +0100
To: Leonid Grossman <leonid.grossman@neterion.com>
Content-Disposition: inline
In-Reply-To: <200502211653.j1LGr3DD025897@guinness.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Feb 21, 2005 at 08:52:13AM -0800, Leonid Grossman wrote:
> Yes, the question was with regards to the burst of random packets.
> I agree that this may be not too useful and arguably doesn't warrant the
> significant stack change. The reason I asked is that one of our engineers
> was under impression (from reading Linux TCP/IP Stack book) that the feature
> is already supported.

There is some support to process list of skbs, but it's only used
for IP fragments belonging to the same IP packet; and is also
only valid for some small parts of the stack between IP and transport
layer.

The only IP protocols that support it are UDP and RAW. 
TCP doesn't support it; or rather it would always try to reassemble
them first. 

In short it's a hack to avoid one copy of data for NFS over
fragmented UDP.

I guess he thought it was a more general facility or the author
of the book didn't make it clear enough that it was a quite special
case hack. 

> WRT to the burst of packets related to the same flow - we are hoping to be
> able to collapse the burst into a single oversized frame and pass it to the
> stack, this way no or very minimal changes to the stack will be needed. 
> There is enough intelligence on the NIC to do that efficiently, we just need
> to try and see how well this works.

Hopefully you don't need too many cache misses to figure this out though.

-Andi
