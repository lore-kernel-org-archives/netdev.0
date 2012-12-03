From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 5/5] smsc95xx: expand check_ macros
Date: Mon, 3 Dec 2012 10:41:28 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B70D4@saturn3.aculab.com>
References: <1354290952-27109-1-git-send-email-steve.glendinning@shawell.net> <1354290952-27109-6-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: "Steve Glendinning" <steve.glendinning@shawell.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:43689 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751501Ab2LCKmv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 05:42:51 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 16307-06 for <netdev@vger.kernel.org>;
 Mon,  3 Dec 2012 10:42:43 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1354290952-27109-6-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -		check_warn_return(ret, "Error reading MII_ACCESS\n");
> +		if (ret < 0) {
> +			netdev_warn(dev->net, "Error reading MII_ACCESS\n");
> +			return ret;
> +		}
> +

It might be worth defining something like:

#define check_warn(dev, ret, errmsg) \
	(ret >= 0 ? 0 : (netdev_warn(dev->net, errmsg), ret))

so the above code can be:
	if (check_warn(dev, ret, "Error reading MII_ACCESS\n"))
		return ret;

	David
