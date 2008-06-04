From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 9/12]: wext: Dispatch and handle compat ioctls entirely in net/wireless/wext.c
Date: Wed, 4 Jun 2008 14:20:48 +0200
Message-ID: <200806041420.49316.arnd@arndb.de>
References: <20080603.132842.123235332.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, linville@tuxdriver.com,
	mokuno@sm.sony.co.jp, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:52237 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbYFDMVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 08:21:49 -0400
In-Reply-To: <20080603.132842.123235332.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 03 June 2008, David Miller wrote:
> Next we can kill the hacks in fs/compat_ioctl.c and also
> dispatch compat ioctls down into the driver and 80211 protocol
> helper layers in order to handle iw_point objects embedded in
> stream replies which need to be translated.

Great work! Thanks for getting one large chunk of fs/compat_ioctl.c
removed on the way.

> diff --git a/include/net/wext.h b/include/net/wext.h
> index 80b31d8..6d76a39 100644
> --- a/include/net/wext.h
> +++ b/include/net/wext.h
> @@ -12,6 +12,8 @@ extern int wext_proc_init(struct net *net);
>  extern void wext_proc_exit(struct net *net);
>  extern int wext_handle_ioctl(struct net *net, struct ifreq *ifr, unsigned int cmd,
>  			     void __user *arg);
> +extern int compat_wext_handle_ioctl(struct net *net, unsigned int cmd,
> +				    unsigned long arg);

Is it intentional that the prototypes are so different? Why not
pass a void __user *arg instead of unsigned long arg?

> +int compat_wext_handle_ioctl(struct net *net, unsigned int cmd,
> +			     unsigned long arg)
> +{
> +	void __user *argp = (void __user *)arg;

For the conversion, you should also use compat_ptr() instead of the
cast. This currently only makes a difference on s390, which does
not have wireless, but it's better not to give wrong examples in the
code.

	Arnd <><
