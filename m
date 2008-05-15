From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 1/3] net: handle errors from device_rename
Date: Thu, 15 May 2008 16:41:40 +0800
Message-ID: <482BF744.6060106@cn.fujitsu.com>
References: <20080514170316.672f809d@extreme> <20080514181543.744b8286@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, David Miller <davem@davemloft.net>,
	fubar@us.ibm.com, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62171 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752861AbYEOIoK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2008 04:44:10 -0400
In-Reply-To: <20080514181543.744b8286@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger said the following on 2008-5-15 9:15:
>  rollback:
> -	device_rename(&dev->dev, dev->name);
> +	err = device_rename(&dev->dev, dev->name);
> +	if (err) {
> +		memcpy(dev->name, oldname, IFNAMSIZ);
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
no need, dev->name didn't change in device_rename().
 
> +		return err;
> +	}
>  
