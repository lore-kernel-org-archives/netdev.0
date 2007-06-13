From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 4/15] spidernet: silence the ramfull messages
Date: Wed, 13 Jun 2007 16:12:00 -0400
Message-ID: <46704F90.7050508@garzik.org>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org> <20070611181429.GA4397@austin.ibm.com> <20070611181702.GA13741@austin.ibm.com> <20070611182650.GD13741@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39264 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752728AbXFMUME (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 16:12:04 -0400
In-Reply-To: <20070611182650.GD13741@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:
> --- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-11 10:02:34.000000000 -0500
> +++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-06-11 11:45:25.000000000 -0500
> @@ -1172,7 +1172,7 @@ spider_net_decode_one_descr(struct spide
>  		goto bad_desc;
>  	}
>  
> -	if (hwdescr->dmac_cmd_status & 0xfefe) {
> +	if (hwdescr->dmac_cmd_status & 0xfcf4) {
>  		pr_err("%s: bad status, cmd_status=x%08x\n",
>  			       card->netdev->name,
>  			       hwdescr->dmac_cmd_status);


A follow-up patch needs to remove the above magic numbers (==numeric 
constants), replacing them with named constants

I only accepted the above patch because it was needed for the fixes. 
Otherwise I would have requested a SPIDERNET_BAD_STATUS constant or 
similar, containing the relevant split-out bits

