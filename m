From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] [PATCH] ipv6: Fix potential hang in mif6_add
Date: Wed, 02 May 2012 09:02:40 +0200
Message-ID: <1335942160.22133.51.camel@edumazet-glaptop>
References: <20120502060957.30368.34595.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:52086 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185Ab2EBHCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 03:02:45 -0400
Received: by bkcji2 with SMTP id ji2so166124bkc.19
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 00:02:44 -0700 (PDT)
In-Reply-To: <20120502060957.30368.34595.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-02 at 11:39 +0530, Krishna Kumar wrote:
> Fix a potential "waiting for %s to become free" hang.
> mif6_add() called ip6mr_reg_vif to allocate/register a
> netdevice, which also took an extra reference on the
> device. On error, mif6_add should drop this reference
> before unregistering the device.
> 
> (untested, noticed from code walkthrough)
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>  net/ipv6/ip6mr.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff -ruNp org/net/ipv6/ip6mr.c new/net/ipv6/ip6mr.c
> --- org/net/ipv6/ip6mr.c	2012-04-19 09:03:34.000000000 +0530
> +++ new/net/ipv6/ip6mr.c	2012-05-02 10:51:01.953110994 +0530
> @@ -937,8 +937,8 @@ static int mif6_add(struct net *net, str
>  			return -ENOBUFS;
>  		err = dev_set_allmulti(dev, 1);
>  		if (err) {
> -			unregister_netdevice(dev);
>  			dev_put(dev);
> +			unregister_netdevice(dev);
>  			return err;
>  		}
>  		break;
> 

This makes no difference to dev_put() before or after
unregister_netdevice() because we hold RTNL in mif6_add()
