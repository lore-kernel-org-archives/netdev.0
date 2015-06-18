From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC] tun, macvtap: higher order allocations for skbs
Date: Thu, 18 Jun 2015 13:13:25 +0200
Message-ID: <20150618131045-mutt-send-email-mst@redhat.com>
References: <1434622758-16549-1-git-send-email-mst@redhat.com>
 <5582A374.6020402@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org
To: Christian Borntraeger <borntraeger@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54301 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753910AbbFRLN2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jun 2015 07:13:28 -0400
Content-Disposition: inline
In-Reply-To: <5582A374.6020402@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 18, 2015 at 12:54:44PM +0200, Christian Borntraeger wrote:
> Am 18.06.2015 um 12:20 schrieb Michael S. Tsirkin:
> > Needs more testing. Anyone see anything wrong with this?
> Can you explain the motivation? 
> FWIW, basic networking between two guest over macvtap still
> seems to work on s390 so I dont see any obvious regression.
> 
> Christian

Shorter fragment list often makes processing in the net stack more
efficient.

> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > ---
> >  drivers/net/macvtap.c | 2 +-
> >  drivers/net/tun.c     | 2 +-
> >  2 files changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> > index 928f3f4..80e87e4 100644
> > --- a/drivers/net/macvtap.c
> > +++ b/drivers/net/macvtap.c
> > @@ -610,7 +610,7 @@ static inline struct sk_buff *macvtap_alloc_skb(struct sock *sk, size_t prepad,
> >  		linear = len;
> > 
> >  	skb = sock_alloc_send_pskb(sk, prepad + linear, len - linear, noblock,
> > -				   err, 0);
> > +				   err, 1);
> >  	if (!skb)
> >  		return NULL;
> > 
> > diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> > index cb376b2d..8f2f1e5 100644
> > --- a/drivers/net/tun.c
> > +++ b/drivers/net/tun.c
> > @@ -1069,7 +1069,7 @@ static struct sk_buff *tun_alloc_skb(struct tun_file *tfile,
> >  		linear = len;
> > 
> >  	skb = sock_alloc_send_pskb(sk, prepad + linear, len - linear, noblock,
> > -				   &err, 0);
> > +				   &err, 1);
> >  	if (!skb)
> >  		return ERR_PTR(err);
> > 
