From: Paul Moore <pmoore@redhat.com>
Subject: Re: [RFC PATCH v2 1/3] tun: correctly report an error in tun_flow_init()
Date: Thu, 06 Dec 2012 10:46:42 -0500
Message-ID: <1925714.MfFlfY86Ce@sifl>
References: <20121205202144.18626.61966.stgit@localhost> <20121205202604.18626.71229.stgit@localhost> <2215330.qi9iHRh0XG@jason-thinkpad-t430s>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, mst@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <2215330.qi9iHRh0XG@jason-thinkpad-t430s>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, December 06, 2012 06:31:29 PM Jason Wang wrote:
> On Wednesday, December 05, 2012 03:26:04 PM Paul Moore wrote:
> > On error, the error code from tun_flow_init() is lost inside
> > tun_set_iff(), this patch fixes this by assigning the tun_flow_init()
> > error code to the "err" variable which is returned by
> > the tun_flow_init() function on error.
> > 
> > Signed-off-by: Paul Moore <pmoore@redhat.com>
> > ---
> > 
> >  drivers/net/tun.c |    3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> > index a1b2389..14a0454 100644
> > --- a/drivers/net/tun.c
> > +++ b/drivers/net/tun.c
> > @@ -1591,7 +1591,8 @@ static int tun_set_iff(struct net *net, struct file
> > *file, struct ifreq *ifr)
> > 
> >                 tun_net_init(dev);
> > 
> > -               if (tun_flow_init(tun))
> > +               err = tun_flow_init(tun);
> > +               if (err < 0)
> > 
> >                         goto err_free_dev;
> >                 
> >                 dev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST |
> > 
> > --
> 
> Looks fine, we can separate this out of this series and replace the RFC with
> net-next to let David apply it soon.

Will do shortly.

-- 
paul moore
security and virtualization @ redhat

