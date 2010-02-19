From: "Benjamin Li" <benli@broadcom.com>
Subject: Re: BNX2: Kernel crashes with 2.6.31 and 2.6.31.9
Date: Fri, 19 Feb 2010 13:47:14 -0800
Message-ID: <1266616034.2610.51.camel@dhcp-10-12-137-130.broadcom.com>
References: <20091229084929.54912c0c@pluto.restena.lu>
 <1262077540.12520.4.camel@localhost>
 <20091229145403.39f82773@pluto.restena.lu>
 <1262149691.2788.63.camel@localhost>
 <20100219091034.5fbb0165@pluto.restena.lu>
 <1266609426.2610.36.camel@dhcp-10-12-137-130.broadcom.com>
 <4B7EFCA6.7050709@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Bruno =?ISO-8859-1?Q?Pr=E9mont?=" <bonbons@linux-vserver.org>,
	NetDEV <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>,
	Linux-Kernel <linux-kernel@vger.kernel.org>
To: "Brian Haley" <brian.haley@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B7EFCA6.7050709@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Brian,

On Fri, 2010-02-19 at 13:03 -0800, Brian Haley wrote:
> Hi Ben,
> 
> Benjamin Li wrote:
> > Hi Bruno,
> > 
> > @@ -8201,7 +8204,7 @@ bnx2_init_napi(struct bnx2 *bp)
> >  {
> >  	int i;
> >  
> > -	for (i = 0; i < BNX2_MAX_MSIX_VEC; i++) {
> > +	for (i = 0; i < bp->irq_nvecs; i++) {
> >  		struct bnx2_napi *bnapi = &bp->bnx2_napi[i];
> >  		int (*poll)(struct napi_struct *, int);
> 
> Would this same change need to be made in other places, like bnx2_init_chip()
> or bnx2_clear_ring_states() ?

The other locations in the bnx2.c driver are bnx2_init_chip(),
bnx2_clear_ring_states(), bnx2_alloc_mem().  With the current
implementation, the bnx2_napi structures are initialize but never used
which should be ok.  But, we can clean this up to save some cycles.

The following are the areas in the code which iterate through all the
vectors.

bnx2_init_chip() - zero the last_status_idx field in the bnx2_napi
structure
bnx2_clear_ring_states() - zero the rings producer/consumer indexes
bnx2_alloc_mem() - initialize the consumer pointers

Thanks again.

-Ben

> 
> -Brian
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
