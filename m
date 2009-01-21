From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH 1/6] smsc911x: add support for platform-specific irq flags
Date: Wed, 21 Jan 2009 15:54:04 +0000
Message-ID: <OF316EA217.8804B96B-ON80257545.0056A474-80257545.00576FA1@smsc.com>
References: <20090120145539.GD2425@trinity.fluff.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, ian.saturley@smsc.com,
	Russell King <linux@arm.linux.org.uk>,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	Stanley Miao <stanley.miao@windriver.com>
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:4943 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754401AbZAUPz4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jan 2009 10:55:56 -0500
In-Reply-To: <20090120145539.GD2425@trinity.fluff.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

Ben Dooks <ben-linux@fluff.org> wrote on 20/01/2009 14:55:39:
> On Tue, Jan 20, 2009 at 01:28:29PM +0000, Steve Glendinning wrote:
> > @@ -1919,6 +1919,14 @@ static int __devinit 
> smsc911x_drv_probe(struct platform_device *pdev)
> >     }
> >     res_size = res->end - res->start;
> > 
> > +   irq_res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
> > +   if (!irq_res) {
> > +      pr_warning("%s: Could not allocate irq resource.\n",
> > +         SMSC_CHIPNAME);
> > +      retval = -ENODEV;
> > +      goto out_0;
> 
> -ENODEV is certainly not the right code to be returning here, it is
> likely to get lost in the driver porbe process.
> 

Thanks for spotting this.

This probe function also returns -ENODEV in two other places: if 
platform_data is null or if it fails to get it's IORESOURCE_MEM.  I guess 
these should all be fixed, which return code should the driver use to 
indicate "my platform_data is missing or incomplete"?

Steve
