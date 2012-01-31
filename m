From: Karsten Keil <kkeil@linux-pingi.de>
Subject: Re: [PATCH 01/16] eicon: fix -Warray-bounds warning
Date: Tue, 31 Jan 2012 16:25:34 +0100
Message-ID: <20120131152534.GA14825@gw.linux-pingi.de>
References: <1327960820-11867-1-git-send-email-danny.kukawka@bisect.de>
 <1327960820-11867-2-git-send-email-danny.kukawka@bisect.de>
 <1327964972.2595.31.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Danny Kukawka <danny.kukawka@bisect.de>,
	Armin Schindler <mac@melware.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1327964972.2595.31.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 30, 2012 at 11:09:32PM +0000, Ben Hutchings wrote:
> On Mon, 2012-01-30 at 23:00 +0100, Danny Kukawka wrote:
> > Fix for a -Warray-bounds warning. mixer_notify_update() tries to
> > write to ((CAPI_MSG *) msg)->info.facility_req.structs[3] while
> > structs is defined as byte structs[1], define structs[1] as
> > structs[4].
> 
> I suspect that all the 'byte structs[1];' fields defined in that header
> are actually variable-length arrays.  In that case, there may be no
> reasonable bound you can specify.

Yes, exactely, the structs is a ASN1 coded message so it can have any len.

Karsten

> 
> Ben.
> 
> > Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
> > ---
> >  drivers/isdn/hardware/eicon/capi20.h |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/drivers/isdn/hardware/eicon/capi20.h b/drivers/isdn/hardware/eicon/capi20.h
> > index 7ebcccd..f9170ad 100644
> > --- a/drivers/isdn/hardware/eicon/capi20.h
> > +++ b/drivers/isdn/hardware/eicon/capi20.h
> > @@ -226,7 +226,7 @@ typedef struct {
> >          /* FACILITY-REQUEST */
> >  typedef struct {
> >    word Selector;
> > -  byte structs[1];      /* Facility parameters */
> > +  byte structs[4];      /* Facility parameters */
> >  } _FAC_REQP;
> >          /* FACILITY-CONFIRM STRUCT FOR SUPPLEMENT. SERVICES */
> >  typedef struct {
> 
