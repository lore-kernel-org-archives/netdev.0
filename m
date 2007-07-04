From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: [PATCH 1/2] eHEA: Capability flag for DLPAR support
Date: Wed, 4 Jul 2007 14:58:11 +0200
Message-ID: <200707041458.12792.ossthema@de.ibm.com>
References: <200707041209.37127.ossthema@de.ibm.com> <961aa3350707040553m12ff1bccw9421e714337c80d1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jeff@garzik.org>, netdev <netdev@vger.kernel.org>,
	"Christoph Raisch" <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	"Marcus Eder" <meder@de.ibm.com>,
	"Thomas Klein" <tklein@de.ibm.com>,
	"Stefan Roscher" <stefan.roscher@de.ibm.com>
To: "Akinobu Mita" <akinobu.mita@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:3897 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758570AbXGDNXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 09:23:04 -0400
In-Reply-To: <961aa3350707040553m12ff1bccw9421e714337c80d1@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

good catch.

Thanks

On Wednesday 04 July 2007 14:53, Akinobu Mita wrote:
> 2007/7/4, Jan-Bernd Themann <ossthema@de.ibm.com>:
> 
> > diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
> > index bdb5241..f8c0908 100644
> > --- a/drivers/net/ehea/ehea_main.c
> > +++ b/drivers/net/ehea/ehea_main.c
> > @@ -2923,6 +2923,15 @@ static int check_module_parm(void)
> >         return ret;
> >  }
> >
> > +static ssize_t ehea_show_capabilities(struct device_driver *drv,
> > +                                     char *buf)
> > +{
> > +       return sprintf(buf, "%d", EHEA_CAPABILITIES);
> > +}
> > +
> > +static DRIVER_ATTR(capabilities, S_IRUSR | S_IRGRP | S_IROTH,
> > +                  ehea_show_capabilities, NULL);
> > +
> >  int __init ehea_module_init(void)
> >  {
> >         int ret;
> > @@ -2937,12 +2946,20 @@ int __init ehea_module_init(void)
> >         if (ret)
> >                 ehea_error("failed registering eHEA device driver on ebus");
> >
> 
> You forgot to put:
>                 return ret;
> or
>                 goto out;
> 
> > +       ret = driver_create_file(&ehea_driver.driver, &driver_attr_capabilities);
> > +       if (ret) {
> > +               ehea_error("failed to register capabilities attribute, ret=%d", ret);
> > +               ibmebus_unregister_driver(&ehea_driver);
> > +               goto out;
> > +       }
> > +
> >  out:
> >         return ret;
> >  }
> >
> 
