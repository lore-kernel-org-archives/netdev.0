From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: Intel and TOE in the news
Date: Mon, 21 Feb 2005 10:02:47 -0800
Message-ID: <200502211803.j1LI3cDD009072@guinness.s2io.com>
References: <1109005880.1076.77.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Andi Kleen'" <ak@muc.de>, "'rick jones'" <rick.jones2@hp.com>,
        <netdev@oss.sgi.com>, "'Alex Aizman'" <alex@neterion.com>
To: <hadi@cyberus.ca>, "'Leonid Grossman'" <leonid.grossman@neterion.com>
In-Reply-To: <1109005880.1076.77.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: jamal [mailto:hadi@cyberus.ca] 
> Sent: Monday, February 21, 2005 9:11 AM
> To: Leonid Grossman
> Cc: 'Andi Kleen'; 'rick jones'; netdev@oss.sgi.com; 'Alex Aizman'
> Subject: RE: Intel and TOE in the news
> 
> On Mon, 2005-02-21 at 11:52, Leonid Grossman wrote:
> >  
> > WRT to the burst of packets related to the same flow - we 
> are hoping 
> > to be able to collapse the burst into a single oversized frame and 
> > pass it to the stack, this way no or very minimal changes 
> to the stack will be needed.
> > There is enough intelligence on the NIC to do that efficiently, we 
> > just need to try and see how well this works.
> 
> Indeed, would be nice to see what you come up with. I think 
> there may be value in sending one huge chunk packet which 
> itself is actually a collection of several independet packets 
> when you have a huge amount of small packets. The benefit 
> being you amortize the cost of DMA setup.
> But then you may need to be able to break them down in the 
> driver; is this what you are talking about?

Pretty much. Actually the ASIC separates the headers so the driver doesn't
need to break packets down.
The driver just chains the payload (for several packets from a same-flow
burst) and builds the header for this single oversized frame. Kind of
inversed TSO, but on receive side. 
We are going to post an experimental driver code in 2-3 weeks, along with
this "Large Receive Offload" algorithm, for review.

Cheers, Leonid

> 
> cheers,
> jamal
> 
> 
