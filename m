From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC] tun: experimental zero copy tx support
Date: Mon, 14 May 2012 22:17:20 +0300
Message-ID: <20120514191719.GD17086@redhat.com>
References: <20120513155206.GA26847@redhat.com>
 <20120514095446.3ce307d2@nehalam.linuxnetplumber.net>
 <20120514170412.GA17086@redhat.com>
 <1337022146.8512.606.camel@edumazet-glaptop>
 <20120514191456.GC17086@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ian.Campbell@citrix.com,
	kvm@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120514191456.GC17086@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 14, 2012 at 10:14:56PM +0300, Michael S. Tsirkin wrote:
> On Mon, May 14, 2012 at 09:02:26PM +0200, Eric Dumazet wrote:
> > On Mon, 2012-05-14 at 20:04 +0300, Michael S. Tsirkin wrote:
> > > On Mon, May 14, 2012 at 09:54:46AM -0700, Stephen Hemminger wrote:
> > > > On Sun, 13 May 2012 18:52:06 +0300
> > > > "Michael S. Tsirkin" <mst@redhat.com> wrote:
> > > > 
> > > > > +		/* Userspace may produce vectors with count greater than
> > > > > +		 * MAX_SKB_FRAGS, so we need to linearize parts of the skb
> > > > > +		 * to let the rest of data to be fit in the frags.
> > > > > +		 */
> > > > Rather than complex partial code, just go through slow path for
> > > > requests with too many frags (or for really small requests).
> > > > Creating mixed skb's seems too easy to get wrong.
> > > 
> > > I don't object in principle but macvtap has same code
> > > so seems better to stay consistent.
> > > 
> > 
> > If I remember well, code in vtap was buggy and still is.
> > 
> > Jason Wang fixes are not yet in,
> 
> They seem to be in net-next, or did I miss something?
> 
> > so maybe wait a bit, so that we dont
> > add a pile of new bugs ?
> > 
> > 

Things progress smoother upstream than out of tree
is my experience.

Also everything is guarded by a mod param in vhost
which is off by default and the name
experimental_zcopytx makes it hopefully clear there's
risk involved.

So the chance of hurting someone is imo minimal.
