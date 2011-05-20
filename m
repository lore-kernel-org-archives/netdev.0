From: Brian King <brking@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 01/27] HFI: skeleton driver
Date: Fri, 20 May 2011 13:37:50 -0500
Message-ID: <4DD6B4FE.9010309@linux.vnet.ibm.com>
References: <1303766647-30156-1-git-send-email-dykmanj@linux.vnet.ibm.com> <1303766647-30156-2-git-send-email-dykmanj@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Piyush Chaudhary <piyushc@linux.vnet.ibm.com>,
	Fu-Chung Chang <fcchang@linux.vnet.ibm.com>,
	"William S. Cadden" <wscadden@linux.vnet.ibm.com>,
	"Wen C. Chen" <winstonc@linux.vnet.ibm.com>,
	Scot Sakolish <sakolish@linux.vnet.ibm.com>,
	Jian Xiao <jian@linux.vnet.ibm.com>,
	"Carol L. Soto" <clsoto@linux.vnet.ibm.com>,
	"Sarah J. Sheppard" <sjsheppa@linux.vnet.ibm.com>
To: dykmanj@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:46121 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935437Ab1ETSiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2011 14:38:02 -0400
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4KIO7IY013373
	for <netdev@vger.kernel.org>; Fri, 20 May 2011 12:24:07 -0600
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4KIbpHM064664
	for <netdev@vger.kernel.org>; Fri, 20 May 2011 12:37:53 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4KIgxeu008695
	for <netdev@vger.kernel.org>; Fri, 20 May 2011 12:42:59 -0600
In-Reply-To: <1303766647-30156-2-git-send-email-dykmanj@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/25/2011 04:23 PM, dykmanj@linux.vnet.ibm.com wrote:
> +static int __init hfidd_mod_init(void)
> +{
> +	int			rc = 0;
> +
> +	rc = hfidd_create_class();
> +	if (rc < 0) {
> +		printk(KERN_ERR "%s: hfidd_mod_init: hfidd_create_class failed"
> +			" rc=%d\n", HFIDD_DEV_NAME, rc);
> +		return rc;
> +	}
> +
> +	printk(KERN_INFO "IBM hfi device driver loaded sucessfully\n");
> +	return 0;
> +}

This driver doesn't seem to attach to a bus like a normal driver, which breaks
things like udev being able to automatically load the driver, for example. It
also breaks tools trying to correlate between the kernel logical device and
the device in the device tree. It seems like you depend on and use a bit of
the ibmebus infrastructure. Can we have this device off that bus? 

Thanks,

Brian

-- 
Brian King
Linux on Power Virtualization
IBM Linux Technology Center


