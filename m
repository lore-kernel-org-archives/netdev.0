From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] ipconfig.c : implement DHCP Class-identifier
Date: Thu, 8 Nov 2007 22:27:16 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711082225330.26833@kivilampi-30.cs.helsinki.fi>
References: <20071108143205.GA22490@mpi-sb.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, pcernko@mpi-sws.mpg.de
To: Rainer Jochem <rainer.jochem@mpi-sb.mpg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43856 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761348AbXKHU1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 15:27:18 -0500
In-Reply-To: <20071108143205.GA22490@mpi-sb.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 8 Nov 2007, Rainer Jochem wrote:

> @@ -620,6 +622,17 @@ ic_dhcp_init_options(u8 *options)
>  		*e++ = sizeof(ic_req_params);
>  		memcpy(e, ic_req_params, sizeof(ic_req_params));
>  		e += sizeof(ic_req_params);
> +
> +		// Send it only if the according kernel parameter was set

No C99 comments please. Though I'm not sure if this comment is that 
necessary anyway...

> +		if (*vendor_class_identifier) {
> +			printk(KERN_INFO "Sending class identifier \"%s\"\n",
> +			       vendor_class_identifier);
> +			*e++ = 60;	/* Class-identifier */
> +			*e++ = strlen(vendor_class_identifier);
> +			memcpy(e, vendor_class_identifier,
> +			       strlen(vendor_class_identifier));
> +			e += strlen(vendor_class_identifier);
> +		}
>  	}
>  
>  	*e++ = 255;	/* End of the list */

-- 
 i.
