From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] net/udp_offload: Drop unnecessary continue
Date: Wed, 13 Aug 2014 10:06:45 -0700
Message-ID: <20140813170644.GA13556@its-macbook-pro.westell.com>
References: <20140813091605.GA2947@himangi-Dell>
 <1407941291.6804.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Himangi Saraogi <himangi774@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1407941291.6804.7.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 13, 2014 at 07:48:11AM -0700, Eric Dumazet wrote:
> On Wed, 2014-08-13 at 14:46 +0530, Himangi Saraogi wrote:
> > Continue is not needed at the bottom of a loop.
> > 
> > The Coccinelle semantic patch implementing this change is:
> > 
> > @@
> > @@
> > 
> > for (...;...;...) {
> >   ...
> >   if (...) {
> >     ...
> > -   continue;
> >   }
> > }
> > 
> > Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> > Acked-by: Julia Lawall <julia.lawall@lip6.fr>
> > ---
> >  net/ipv4/udp_offload.c | 4 +---
> >  1 file changed, 1 insertion(+), 3 deletions(-)
> > 
> > diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> > index 59035bc..62d5b9b 100644
> > --- a/net/ipv4/udp_offload.c
> > +++ b/net/ipv4/udp_offload.c
> > @@ -269,10 +269,8 @@ unflush:
> >  			continue;
> >  
> >  		uh2 = (struct udphdr   *)(p->data + off);
> > -		if ((*(u32 *)&uh->source != *(u32 *)&uh2->source)) {
> > +		if ((*(u32 *)&uh->source != *(u32 *)&uh2->source))
> >  			NAPI_GRO_CB(p)->same_flow = 0;
> > -			continue;
> > -		}
> >  	}
> >  
> >  	skb_gro_pull(skb, sizeof(struct udphdr)); /* pull encapsulating udp header */
> 
> 
> Please do not do that.
> 
> If we add another check later, we'll miss that the 'continue;' needs to
> be put back.
> 
> GRO stack is quite difficult to maintain, I prefer we keep this as is
> for consistency and code readability.

+1
this code as-is is definitely more readable
