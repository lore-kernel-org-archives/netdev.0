From: Jason Wang <jasowang@redhat.com>
Subject: Re: [RFC PATCH 1/2] tun: correctly report an error in tun_flow_init()
Date: Thu, 06 Dec 2012 11:35:13 +0800
Message-ID: <7532518.OI6gKAFHLF@jason-thinkpad-t430s>
References: <20121129215724.30020.69464.stgit@sifl> <20121129220629.30020.99947.stgit@sifl> <2057175.PIsargdSHu@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Paul Moore <pmoore@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <2057175.PIsargdSHu@sifl>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, December 05, 2012 11:02:04 AM Paul Moore wrote:
> On Thursday, November 29, 2012 05:06:29 PM Paul Moore wrote:
> > On error, the error code from tun_flow_init() is lost inside
> > tun_set_iff(), this patch fixes this by assigning the tun_flow_init()
> > error code to the "err" variable which is returned by
> > the tun_flow_init() function on error.
> > 
> > Signed-off-by: Paul Moore <pmoore@redhat.com>
> 
> Jason, we've had some good discussion around patch 2/2 but nothing on this
> fix; can I assume you are okay with this patch?  If so I think we should go
> ahead and apply this ...

Yes, it looks good. Maybe we can separate this patch from this RFC series and 
tag it as "net-next" to let David apply it soon.

Thanks
> 
> > ---
> > 
> >  drivers/net/tun.c |    3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> > index 607a3a5..877ffe2 100644
> > --- a/drivers/net/tun.c
> > +++ b/drivers/net/tun.c
> > @@ -1605,7 +1605,8 @@ static int tun_set_iff(struct net *net, struct file
> > *file, struct ifreq *ifr)
> > 
> >  		tun_net_init(dev);
> > 
> > -		if (tun_flow_init(tun))
> > +		err = tun_flow_init(tun);
> > +		if (err < 0)
> > 
> >  			goto err_free_dev;
> >  		
> >  		dev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST |
