From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Subject: RE: [PATCH] net: ioctl SIOCSIFADDR minor cleanup
Date: Wed, 16 Nov 2016 03:13:31 +0000
Message-ID: <8729016553E3654398EA69218DA29EEF0E42F73A@cnshjmbx02>
References: <1479213899-5952-1-git-send-email-cugyly@163.com>
 <20161115.220108.1225196299725031215.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        "cugyly@163.com" <cugyly@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnshjsmin03.alcatel-sbell.com.cn ([116.246.26.71]:48659 "EHLO
        cnshjsmin03.alcatel-sbell.com.cn" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934958AbcKPDNr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 22:13:47 -0500
In-Reply-To: <20161115.220108.1225196299725031215.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi david,

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of David Miller
> Sent: Wednesday, November 16, 2016 11:01 AM
> To: cugyly@163.com
> Cc: netdev@vger.kernel.org; YUAN Linyu
> Subject: Re: [PATCH] net: ioctl SIOCSIFADDR minor cleanup
> 
> From: yuan linyu <cugyly@163.com>
> Date: Tue, 15 Nov 2016 20:44:59 +0800
> 
> > @@ -1063,10 +1063,7 @@ int devinet_ioctl(struct net *net, unsigned int
> cmd, void __user *arg)
> >  			if (!ifa)
> >  				break;
> >  			INIT_HLIST_NODE(&ifa->hash);
> > -			if (colon)
> > -				memcpy(ifa->ifa_label, ifr.ifr_name, IFNAMSIZ);
> > -			else
> > -				memcpy(ifa->ifa_label, dev->name, IFNAMSIZ);
> > +			memcpy(ifa->ifa_label, ifr.ifr_name, IFNAMSIZ);
> 
> This is an incorrect and untested change.
> 
> If there is a colon character in ifr.ifr_name, earlier in this function
> we will:
> 
> 1) First replace that colon with a NULL character.
> 
> 2) Perform __dev_get_by_name() on the result.
> 
> 3) Put the ":" colon character back into ifr.ifr_name
> 
> So the two strings ifr.ifr_name and dev->name can in fact be different
> here.  Therefore the code has to be left as it is.
Here we assign value to ifa->ifa_label. 
orginal code means when reqest name have colon, then label name will have colon.
If request name have no colon, label name will same as dev-name, it's also have no colon.
So assign label to request name will do same thing as original code.
thanks
