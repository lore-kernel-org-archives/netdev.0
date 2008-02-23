From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH] [PS3] gelic wireless driver needs MAC80211 support
Date: Sat, 23 Feb 2008 21:09:26 +0100
Message-ID: <200802232109.27158.IvDoorn@gmail.com>
References: <20080223193517.GA6704@Chamillionaire.breakpoint.cc> <200802232050.35157.IvDoorn@gmail.com> <20080223200637.GA7135@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Sebastian Siewior <netdev@ml.breakpoint.cc>,
	Masakazu Mokuno <mokuno@sm.sony.co.jp>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Sebastian Siewior <bigeasy@breakpoint.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.180]:54003 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763436AbYBWUJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 15:09:47 -0500
Received: by el-out-1112.google.com with SMTP id v27so731577ele.23
        for <netdev@vger.kernel.org>; Sat, 23 Feb 2008 12:09:46 -0800 (PST)
In-Reply-To: <20080223200637.GA7135@Chamillionaire.breakpoint.cc>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 23 February 2008, Sebastian Siewior wrote:
> * Ivo van Doorn | 2008-02-23 20:50:34 [+0100]:
> 
> >Additionally, what part of the driver actually uses mac80211?
> >I just browsed to the code, and it seems to work completely without
> >using mac80211. Instead it seems to work directly by registering a
> >net_device structure...
>   CC      drivers/net/ps3_gelic_wireless.o
> /home/bigeasy/git/linux-2.6/drivers/net/ps3_gelic_wireless.c: In function 'gelic_wl_setup_netdev_ops':
> /home/bigeasy/git/linux-2.6/drivers/net/ps3_gelic_wireless.c:2660: error: 'struct net_device' has no member named 'wireless_data'
> /home/bigeasy/git/linux-2.6/drivers/net/ps3_gelic_wireless.c:2661: error: 'struct net_device' has no member named 'wireless_handlers'
> make[3]: *** [drivers/net/ps3_gelic_wireless.o] Error 1
> make[2]: *** [drivers/net] Error 2
> make[1]: *** [drivers] Error 2
> make[1]: *** Waiting for unfinished jobs....
> make: *** [sub-make] Error 2
> 
> 
> I add this to the patch desctiption and post a depends on patach

Looking at include/linux/netdevice.h:

#ifdef CONFIG_WIRELESS_EXT
	/* List of functions to handle Wireless Extensions (instead of ioctl).
	 * See <net/iw_handler.h> for details. Jean II */
	const struct iw_handler_def *	wireless_handlers;
	/* Instance data managed by the core of Wireless Extensions. */
	struct iw_public_data *	wireless_data;
#endif

There is no dependency on mac80211 but on WIRELESS_EXT.
That is a config option most other drivers select, so you best change your patch to
	select WIRELESS_EXT
instead of MAC80211.

Ivo
