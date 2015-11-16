From: Dave Young <dyoung@redhat.com>
Subject: Re: [net] net: fix feature changes on devices without
 ndo_set_features
Date: Mon, 16 Nov 2015 10:01:14 +0800
Message-ID: <20151116020114.GC3439@dhcp-128-65.nay.redhat.com>
References: <1447422841-2333-1-git-send-email-razor@blackwall.org>
 <20151115072544.GA18705@dhcp-128-65.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Jarod Wilson <jarod@redhat.com>, Jiri Pirko <jiri@resnulli.us>,
	Ido Schimmel <idosch@mellanox.com>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43651 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751393AbbKPCBc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Nov 2015 21:01:32 -0500
Content-Disposition: inline
In-Reply-To: <20151115072544.GA18705@dhcp-128-65.nay.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/15/15 at 03:25pm, Dave Young wrote:
> On 11/13/15 at 02:54pm, Nikolay Aleksandrov wrote:
> > From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> > 
> > When __netdev_update_features() was updated to ensure some features are
> > disabled on new lower devices, an error was introduced for devices which
> > don't have the ndo_set_features() method set. Before we'll just set the
> > new features, but now we return an error and don't set them. Fix this by
> > returning the old behaviour and setting err to 0 when ndo_set_features
> > is not present.
> > 
> > Fixes: e7868a85e1b2 ("net/core: ensure features get disabled on new lower devs")
> > CC: Jarod Wilson <jarod@redhat.com>
> > CC: Jiri Pirko <jiri@resnulli.us>
> > CC: Ido Schimmel <idosch@mellanox.com>
> > CC: Sander Eikelenboom <linux@eikelenboom.it>
> > CC: Andy Gospodarek <gospo@cumulusnetworks.com>
> > CC: Florian Fainelli <f.fainelli@gmail.com>
> > Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> > Reviewed-by: Jiri Pirko <jiri@mellanox.com>
> > Reviewed-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> > Reviewed-by: Jarod Wilson <jarod@redhat.com>
> > Tested-by: Florian Fainelli <f.fainelli@gmail.com>
> > ---
> > Sander please feel free to give your Tested-by.
> > 
> >  net/core/dev.c | 2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index ab9b8d0d115e..4a1d198dbbff 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -6426,6 +6426,8 @@ int __netdev_update_features(struct net_device *dev)
> >  
> >  	if (dev->netdev_ops->ndo_set_features)
> >  		err = dev->netdev_ops->ndo_set_features(dev, features);
> > +	else
> > +		err = 0;
> >  
> >  	if (unlikely(err < 0)) {
> >  		netdev_err(dev,
> 
> Tested-by: Dave Young <dyoung@redhat.com>
> 

BTW, more words about my testing. Latest mainline kernel breaks vpn connection.

Though vpnc connected successfully but ssh/web access failed. With this patch
applied it works again.

Thanks
Dave

> Thanks
> Dave
