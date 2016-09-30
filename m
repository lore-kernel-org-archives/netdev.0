From: Johannes Thumshirn <jthumshirn-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 1/3] cw1200: Don't leak memory if krealloc failes
Date: Fri, 30 Sep 2016 15:00:32 +0200
Message-ID: <20160930130032.rz66gxmohjakic6c@linux-x5ow.site>
References: <1475237495-15030-1-git-send-email-jthumshirn@suse.de>
 <25a38254-f0e3-1f4e-de46-688d9fd1b736@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Solomon Peachy <pizza-pCgMCH4qpMRg9hUCZPvPmw@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <25a38254-f0e3-1f4e-de46-688d9fd1b736-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 30, 2016 at 03:56:45PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 9/30/2016 3:11 PM, Johannes Thumshirn wrote:
> 
> > The call to krealloc() in wsm_buf_reserve() directly assigns the newly
> > returned memory to buf->begin. This is all fine except when krealloc()
> > failes we loose the ability to free the old memory pointed to by
> 
>    Fails.
> 
> > buf->begin. If we just create a temporary variable to assign memory to
> > and assign the memory to it we can mitigate the memory leak.
> > 
> > Signed-off-by: Johannes Thumshirn <jthumshirn-l3A5Bk7waGM@public.gmane.org>
> > ---
> >  drivers/net/wireless/st/cw1200/wsm.c | 16 +++++++++-------
> >  1 file changed, 9 insertions(+), 7 deletions(-)
> > 
> > diff --git a/drivers/net/wireless/st/cw1200/wsm.c b/drivers/net/wireless/st/cw1200/wsm.c
> > index 680d60e..12fad99 100644
> > --- a/drivers/net/wireless/st/cw1200/wsm.c
> > +++ b/drivers/net/wireless/st/cw1200/wsm.c
> > @@ -1807,16 +1807,18 @@ static int wsm_buf_reserve(struct wsm_buf *buf, size_t extra_size)
> >  {
> >  	size_t pos = buf->data - buf->begin;
> >  	size_t size = pos + extra_size;
> > +	u8 *tmp;
> > 
> >  	size = round_up(size, FWLOAD_BLOCK_SIZE);
> > 
> > -	buf->begin = krealloc(buf->begin, size, GFP_KERNEL | GFP_DMA);
> > -	if (buf->begin) {
> > -		buf->data = &buf->begin[pos];
> > -		buf->end = &buf->begin[size];
> > -		return 0;
> > -	} else {
> > -		buf->end = buf->data = buf->begin;
> > +	tmp = krealloc(buf->begin, size, GFP_KERNEL | GFP_DMA);
> > +	if (tmp) {
> 
>    !tmp, you mean?

Yes, I've already sent out a v2.

-- 
Johannes Thumshirn                                          Storage
jthumshirn-l3A5Bk7waGM@public.gmane.org                                +49 911 74053 689
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nürnberg
GF: Felix Imendörffer, Jane Smithard, Graham Norton
HRB 21284 (AG Nürnberg)
Key fingerprint = EC38 9CAB C2C4 F25D 8600 D0D0 0393 969D 2D76 0850
