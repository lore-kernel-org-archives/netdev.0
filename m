From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Subject: RE: [PATCH] net: ioctl SIOCSIFADDR minor cleanup
Date: Wed, 16 Nov 2016 03:57:08 +0000
Message-ID: <8729016553E3654398EA69218DA29EEF0E42F7ED@cnshjmbx02>
References: <1479213899-5952-1-git-send-email-cugyly@163.com>
        <20161115.220108.1225196299725031215.davem@davemloft.net>
        <8729016553E3654398EA69218DA29EEF0E42F73A@cnshjmbx02>
 <20161115.223111.734917440131578613.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "cugyly@163.com" <cugyly@163.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnshjsmin03.alcatel-sbell.com.cn ([116.246.26.71]:59238 "EHLO
        cnshjsmin03.alcatel-sbell.com.cn" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752445AbcKPD5Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 22:57:24 -0500
In-Reply-To: <20161115.223111.734917440131578613.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No, this patch will not change dev->name,
It's care about ifa->ifa_label.
> -			if (colon)
> -				memcpy(ifa->ifa_label, ifr.ifr_name, IFNAMSIZ);
> -			else
> -				memcpy(ifa->ifa_label, dev->name, IFNAMSIZ);
When ifr.ifr_name have no colon, dev->name must equal to ifr.ifr_name.
So we change to 
> -			else
> -				memcpy(ifa->ifa_label, ifr.ifr_name, IFNAMSIZ);
Then if and else do same thing. Just one line is enough,
memcpy(ifa->ifa_label, ifr.ifr_name, IFNAMSIZ);

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, November 16, 2016 11:31 AM
> To: YUAN Linyu
> Cc: cugyly@163.com; netdev@vger.kernel.org
> Subject: Re: [PATCH] net: ioctl SIOCSIFADDR minor cleanup
> 
> From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> Date: Wed, 16 Nov 2016 03:13:31 +0000
> 
> > So assign label to request name will do same thing as original code.
> 
> Nope.  dev->name does not have the colon, it was trimmed from the
> string for the device lookup.  So the found device's dev->name does
> not have the colon character, even if it was in ifr.ifr_name
> 
> This was my entire point.
> 
> You are changing the behvaior of the code in an invalid way.
