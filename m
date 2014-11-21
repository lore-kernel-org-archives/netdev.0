From: Alban <albeu@free.fr>
Subject: Re: [PATCH 1/2] 8139too: Allow setting MTU larger than 1500
Date: Fri, 21 Nov 2014 19:57:38 +0100
Message-ID: <20141121195738.038d2cc2@tock>
References: <1415447316-12424-1-git-send-email-albeu@free.fr>
	<1416530074.7215.11.camel@decadent.org.uk>
	<20141121145853.1be898de@tock>
	<1416595911.7215.23.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Aban Bedel <albeu@free.fr>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>,
	Benoit Taine <benoit.taine@lip6.fr>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416595911.7215.23.camel@decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 21 Nov 2014 18:51:51 +0000
Ben Hutchings <ben@decadent.org.uk> wrote:

> On Fri, 2014-11-21 at 14:58 +0100, Alban wrote:
> > On Fri, 21 Nov 2014 00:34:34 +0000
> > Ben Hutchings <ben@decadent.org.uk> wrote:
> > 
> > > On Sat, 2014-11-08 at 12:48 +0100, Alban Bedel wrote:
> > > > Replace the default ndo_change_mtu callback with one that allow
> > > > setting MTU that the driver can handle.
> > > > 
> > > > Signed-off-by: Alban Bedel <albeu@free.fr>
> > > > ---
> > > >  drivers/net/ethernet/realtek/8139too.c | 13 ++++++++++++-
> > > >  1 file changed, 12 insertions(+), 1 deletion(-)
> > > > 
> > > > diff --git a/drivers/net/ethernet/realtek/8139too.c
> > > > b/drivers/net/ethernet/realtek/8139too.c index 007b38c..8387de9
> > > > 100644 --- a/drivers/net/ethernet/realtek/8139too.c
> > > > +++ b/drivers/net/ethernet/realtek/8139too.c
> > > > @@ -185,6 +185,9 @@ static int debug = -1;
> > > >  /* max supported ethernet frame size -- must be at least
> > > > (dev->mtu+14+4).*/ #define MAX_ETH_FRAME_SIZE	1536
> > > >  
> > > > +/* max supported payload size */
> > > > +#define MAX_ETH_DATA_SIZE	(MAX_ETH_FRAME_SIZE -
> > > > ETH_HLEN - ETH_FCS_LEN)
> > > [...]
> > > 
> > > Does this maximum still allow for VLAN tags, or should it use
> > > VLAN_ETH_HLEN instead of ETH_HLEN?
> > 
> > That might well be as the VLAN code seems to assume that the
> > physical device can handle frames of MTU + VLAN_HLEN bytes. I can
> > fix it, but to me it seems like the VLAN code should be fixed to
> > respect the physical device MTU.
> 
> Drivers that support VLANs have to allow for at least one VLAN tag
> when validating the MTU.  This is obviously broken for multiple
> layers of VLAN tags, but those are the semantics we're stuck with.

Ok, I see. Should a I send a fix patch or redo a new version of this
patch?

Alban
