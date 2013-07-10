From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH] xen-netfront: pull on receive skb may need
 to happen earlier
Date: Wed, 10 Jul 2013 13:53:15 +0100
Message-ID: <20130710125315.GM19798@zion.uk.xensource.com>
References: <20130705145319.GB9050@zion.uk.xensource.com>
 <51DAA9B202000078000E3357@nat28.tlf.novell.com>
 <51DAE6CA02000078000E3566@nat28.tlf.novell.com>
 <20130708154814.GI8027@zion.uk.xensource.com>
 <51DBCF4F02000078000E3793@nat28.tlf.novell.com>
 <20130709165134.GG19798@zion.uk.xensource.com>
 <51DD221E02000078000E3BC6@nat28.tlf.novell.com>
 <20130710100416.GL19798@zion.uk.xensource.com>
 <51DD57C102000078000E3D38@nat28.tlf.novell.com>
 <1373460644.5453.109.camel@hastur.hellion.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jan Beulich <JBeulich@suse.com>, Wei Liu <wei.liu2@citrix.com>,
	<davem@davemloft.net>, Dion Kant <g.w.kant@hunenet.nl>,
	<xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<stable@vger.kernel.org>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1373460644.5453.109.camel@hastur.hellion.org.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 10, 2013 at 01:50:44PM +0100, Ian Campbell wrote:
> On Wed, 2013-07-10 at 11:46 +0100, Jan Beulich wrote:
> > >>> On 10.07.13 at 12:04, Wei Liu <wei.liu2@citrix.com> wrote:
> > > Jan, looking at the commit log, the overrun issue in
> > > xennet_get_responses was not introduced by __pskb_pull_tail. The call to
> > > xennet_fill_frags has always been in the same place.
> > 
> > I'm convinced it was: Prior to that commit, if the first response slot
> > contained up to RX_COPY_THRESHOLD bytes, it got entirely
> > consumed into the linear portion of the SKB, leaving the number of
> > fragments available for filling at MAX_SKB_FRAGS. Said commit
> > dropped the early copying, leaving the fragment count at 1
> > unconditionally, and now accumulates all of the response slots into
> > fragments, only pulling after all of them got filled in. It neglected to
> > realize - due to the count now always being 1 at the beginning - that
> > this can lead to MAX_SKB_FRAGS + 1 frags getting filled, corrupting
> > memory.
> 
> That argument makes sense to me.
> 
> Is it possible to hit a scenario where we need to pull more than
> RX_COPY_THRESHOLD in order to fit all of the data in MAX_SKB_FRAGS ?
> 
> > Ian - I have to admit that I'm slightly irritated by you so far not
> > having participated at all in sorting out the fix for this bug that a
> > change of yours introduced.
> 
> Sorry I've been travelling and not following closely enough to realise
> this was related to something I'd done.
> 
> Does this relate somehow to the patch Annie has sent out recently too?
> 

No. That's not related.


Wei.


> Ian.
