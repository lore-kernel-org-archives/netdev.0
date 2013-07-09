From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH] xen-netfront: pull on receive skb may need
 to happen earlier
Date: Tue, 9 Jul 2013 17:51:34 +0100
Message-ID: <20130709165134.GG19798@zion.uk.xensource.com>
References: <8511913.uMAmUdIO30@eistomin.edss.local>
 <20130517085923.GC14401@zion.uk.xensource.com>
 <51D57C1F.8070909@hunenet.nl>
 <20130704150137.GW7483@zion.uk.xensource.com>
 <51D6AED902000078000E2EA9@nat28.tlf.novell.com>
 <20130705145319.GB9050@zion.uk.xensource.com>
 <51DAA9B202000078000E3357@nat28.tlf.novell.com>
 <51DAE6CA02000078000E3566@nat28.tlf.novell.com>
 <20130708154814.GI8027@zion.uk.xensource.com>
 <51DBCF4F02000078000E3793@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>, <davem@davemloft.net>,
	Dion Kant <g.w.kant@hunenet.nl>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, <stable@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51DBCF4F02000078000E3793@nat28.tlf.novell.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 09, 2013 at 07:52:31AM +0100, Jan Beulich wrote:
> >>> On 08.07.13 at 17:48, Wei Liu <wei.liu2@citrix.com> wrote:
> > On Mon, Jul 08, 2013 at 03:20:26PM +0100, Jan Beulich wrote:
> >> @@ -1014,7 +1025,7 @@ err:
> >>  
> >>  		skb_shinfo(skb)->frags[0].page_offset = rx->offset;
> >>  		skb_frag_size_set(&skb_shinfo(skb)->frags[0], rx->status);
> >> -		skb->data_len = rx->status;
> >> +		skb->len = skb->data_len = rx->status;
> > 
> > This is not correct. You should not be needing this. Now you lose count
> > of SKB head len. Try to go without the above line and see if it makes a
> > difference?
> 
> I don't follow - at this point, there's 0 bytes of head (this only
> changes with the first call to __pskb_pull_tail()). Hence ->len ==
> ->data_len seems correct to me (and afaict pulling would do the
> wrong thing if I dropped that change).
> 

My bad, I suggested the wrong thing. :-(

But I would prefer skb->len += skb->data_len. In the case that skb->len
== 0 it's the same as your line while skb->len is not zero it would also
do the right thing.

As for the warning in skb_try_coalesce, I don't see any direct call to
it in netfront, I will need to think about it. It looks like it's really
something very deep in the stack.


Wei.

> Jan
