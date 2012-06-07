From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/2] e1000e: Disable ASPM L1 on 82574
Date: Thu, 7 Jun 2012 10:41:09 +0900
Message-ID: <20120607014109.GD16281@kroah.com>
References: <1335216578-21542-1-git-send-email-bootc@bootc.net>
 <1335216578-21542-2-git-send-email-bootc@bootc.net>
 <4FC93154.1060906@bootc.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nix@esperi.org.uk,
	carolyn.wyborny@intel.com, stable@vger.kernel.org
To: Chris Boot <bootc@bootc.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4FC93154.1060906@bootc.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 01, 2012 at 10:17:08PM +0100, Chris Boot wrote:
> On 23/04/2012 22:29, Chris Boot wrote:
> > ASPM on the 82574 causes trouble. Currently the driver disables L0s for
> > this NIC but only disables L1 if the MTU is >1500. This patch simply
> > causes L1 to be disabled regardless of the MTU setting.
> >
> > Signed-off-by: Chris Boot <bootc@bootc.net>
> > Cc: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
> > Cc: Nix <nix@esperi.org.uk>
> > Link: https://lkml.org/lkml/2012/3/19/362
> > ---
> >  drivers/net/ethernet/intel/e1000e/82571.c |    3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> >
> > diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
> > index b3fdc69..c6d95f2 100644
> > --- a/drivers/net/ethernet/intel/e1000e/82571.c
> > +++ b/drivers/net/ethernet/intel/e1000e/82571.c
> > @@ -2061,8 +2061,9 @@ const struct e1000_info e1000_82574_info = {
> >  				  | FLAG_HAS_SMART_POWER_DOWN
> >  				  | FLAG_HAS_AMT
> >  				  | FLAG_HAS_CTRLEXT_ON_LOAD,
> > -	.flags2			  = FLAG2_CHECK_PHY_HANG
> > +	.flags2			= FLAG2_CHECK_PHY_HANG
> >  				  | FLAG2_DISABLE_ASPM_L0S
> > +				  | FLAG2_DISABLE_ASPM_L1
> >  				  | FLAG2_NO_DISABLE_RX,
> >  	.pba			= 32,
> >  	.max_hw_frame_size	= DEFAULT_JUMBO,
> 
> Now that this patch is in master (d4a4206e) and has presumably been
> widely tested, what's the possibility of it making it into stable? I
> really should have included a CC to stable when I sent it...

I'd be glad to apply it, but it doesn't apply properly to the 3.4-stable
tree :(

> This patch should probably also be accompanied with 59aed952 (e1000e:
> Remove special case for 82573/82574 ASPM L1 disablement) on top, to
> remove a special case that's no longer required once this is applied.

As I can't apply the first one, this one shouldn't be applied either at
this point in time...

thanks,

greg k-h
