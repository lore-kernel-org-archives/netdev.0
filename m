From: "Akinobu Mita" <akinobu.mita@gmail.com>
Subject: Re: [PATCH 1/2] eHEA: Capability flag for DLPAR support
Date: Wed, 4 Jul 2007 21:53:39 +0900
Message-ID: <961aa3350707040553m12ff1bccw9421e714337c80d1@mail.gmail.com>
References: <200707041209.37127.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jeff@garzik.org>, netdev <netdev@vger.kernel.org>,
	"Christoph Raisch" <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	"Marcus Eder" <meder@de.ibm.com>,
	"Thomas Klein" <tklein@de.ibm.com>,
	"Stefan Roscher" <stefan.roscher@de.ibm.com>
To: "Jan-Bernd Themann" <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:32108 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758900AbXGDMxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 08:53:40 -0400
Received: by py-out-1112.google.com with SMTP id u77so3836409pyb
        for <netdev@vger.kernel.org>; Wed, 04 Jul 2007 05:53:40 -0700 (PDT)
In-Reply-To: <200707041209.37127.ossthema@de.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2007/7/4, Jan-Bernd Themann <ossthema@de.ibm.com>:

> diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
> index bdb5241..f8c0908 100644
> --- a/drivers/net/ehea/ehea_main.c
> +++ b/drivers/net/ehea/ehea_main.c
> @@ -2923,6 +2923,15 @@ static int check_module_parm(void)
>         return ret;
>  }
>
> +static ssize_t ehea_show_capabilities(struct device_driver *drv,
> +                                     char *buf)
> +{
> +       return sprintf(buf, "%d", EHEA_CAPABILITIES);
> +}
> +
> +static DRIVER_ATTR(capabilities, S_IRUSR | S_IRGRP | S_IROTH,
> +                  ehea_show_capabilities, NULL);
> +
>  int __init ehea_module_init(void)
>  {
>         int ret;
> @@ -2937,12 +2946,20 @@ int __init ehea_module_init(void)
>         if (ret)
>                 ehea_error("failed registering eHEA device driver on ebus");
>

You forgot to put:
                return ret;
or
                goto out;

> +       ret = driver_create_file(&ehea_driver.driver, &driver_attr_capabilities);
> +       if (ret) {
> +               ehea_error("failed to register capabilities attribute, ret=%d", ret);
> +               ibmebus_unregister_driver(&ehea_driver);
> +               goto out;
> +       }
> +
>  out:
>         return ret;
>  }
>
