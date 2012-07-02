From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [patch] [SCSI] bnx2i: use strlcpy() instead of memcpy() for
 strings
Date: Mon, 2 Jul 2012 08:13:38 -0700
Message-ID: <1341242018.7472.5.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <20120630114935.GB22767@elgon.mountain>
 <AE90C24D6B3A694183C094C60CF0A2F6026B6F6F@saturn3.aculab.com>
 <20120702104843.GB4519@mwanda>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: "David Laight" <David.Laight@ACULAB.COM>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	"Barak Witkowski" <barak@broadcom.com>,
	"Eddie Wai" <eddie.wai@broadcom.com>, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: "Dan Carpenter" <dan.carpenter@oracle.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20120702104843.GB4519@mwanda>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-07-02 at 13:48 +0300, Dan Carpenter wrote: 
> On Mon, Jul 02, 2012 at 11:09:19AM +0100, David Laight wrote:
> > > Subject: [patch] [SCSI] bnx2i: use strlcpy() instead of memcpy() for
> > strings
> > > 
> > > DRV_MODULE_VERSION here is "2.7.2.2" which is only 8 chars but we copy
> > > 12 bytes from the stack so it's a small information leak.
> > > 
> > > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> > > ---
> > > This was just added to linux-next yesterday, but I'm not sure 
> > > which tree it came from.
> > > 
> > > diff --git a/drivers/scsi/bnx2i/bnx2i_init.c 
> > > b/drivers/scsi/bnx2i/bnx2i_init.c
> > > index 7729a52..b17637a 100644
> > > --- a/drivers/scsi/bnx2i/bnx2i_init.c
> > > +++ b/drivers/scsi/bnx2i/bnx2i_init.c
> > > @@ -400,7 +400,7 @@ int bnx2i_get_stats(void *handle)
> > >  	if (!stats)
> > >  		return -ENOMEM;
> > >  
> > > -	memcpy(stats->version, DRV_MODULE_VERSION,
> > sizeof(stats->version));
> > > +	strlcpy(stats->version, DRV_MODULE_VERSION,
> > sizeof(stats->version));
> > >  	memcpy(stats->mac_add1 + 2, hba->cnic->mac_addr, ETH_ALEN);
> > 
> > Doesn't that leak the original contents of the last bytes of
> > stats->version instead?
> 
> I'm pretty sure we set those to zero in bnx2x_handle_drv_info_req().
> 

Yes, bnx2x zeros the whole stats structure, so strlcpy() is correct.

This came from the net-next tree, so David is the right persion to apply
this.  Thanks.

Acked-by: Michael Chan <mchan@broadcom.com>


