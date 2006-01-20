From: "kus Kusche Klaus" <kus@keba.com>
Subject: RE: My vote against eepro* removal
Date: Fri, 20 Jan 2006 12:27:43 +0100
Message-ID: <AAD6DA242BC63C488511C611BD51F367323327@MAILIT.keba.co.at>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "John Ronciak" <john.ronciak@gmail.com>,
	"Adrian Bunk" <bunk@stusta.de>,
	"Lee Revell" <rlrevell@joe-job.com>,
	<linux-kernel@vger.kernel.org>, <john.ronciak@intel.com>,
	<ganesh.venkatesan@intel.com>, <jesse.brandeburg@intel.com>,
	<netdev@vger.kernel.org>, "Steven Rostedt" <rostedt@goodmis.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750850AbWATL1v@vger.kernel.org>
Content-class: urn:content-classes:message
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov
> Just a hack:
> 
> --- drivers/net/e100.c.1	2006-01-20 13:39:19.000000000 +0300
> +++ drivers/net/e100.c	2006-01-20 14:15:40.000000000 +0300
> @@ -879,8 +879,8 @@
>  
>  	writel((reg << 16) | (addr << 21) | dir | data, 
> &nic->csr->mdi_ctrl);
>  
> -	for(i = 0; i < 100; i++) {
> -		udelay(20);
> +	for(i = 0; i < 1000; i++) {
> +		udelay(2);
>  		if((data_out = readl(&nic->csr->mdi_ctrl)) & mdi_ready)
>  			break;
>  	}

My test environment and software is not precise enough for small 
improvements, but I'd say this results in a 10-15 % improvement
(i.e. something like 50 us shorter delay) on the average.

To be sure, one would have to take and print tsc timestamps directly
in the watchdog code, but printk's mess up my timings.

-- 
Klaus Kusche                 (Software Development - Control Systems)
KEBA AG             Gewerbepark Urfahr, A-4041 Linz, Austria (Europe)
Tel: +43 / 732 / 7090-3120                 Fax: +43 / 732 / 7090-6301
E-Mail: kus@keba.com                                WWW: www.keba.com
