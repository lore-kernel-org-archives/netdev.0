From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 1/2] 6lowpan: introduce new net/6lowpan directory
Date: Fri, 11 Jul 2014 13:35:10 +0200
Message-ID: <20140711113507.GA24370@omega>
References: <1405067059-18782-1-git-send-email-alex.aring@gmail.com>
 <1405067059-18782-2-git-send-email-alex.aring@gmail.com>
 <8A1EF84C-3EDC-4540-B8F4-1FCBF4BF8D93@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <8A1EF84C-3EDC-4540-B8F4-1FCBF4BF8D93-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Marcel,

On Fri, Jul 11, 2014 at 01:23:52PM +0200, Marcel Holtmann wrote:
> Hi Alexander,
> 
...
> > index cbbbe6d..7ed1970 100644
> > --- a/net/Makefile
> > +++ b/net/Makefile
> > @@ -57,7 +57,8 @@ obj-$(CONFIG_CAIF)		+= caif/
> > ifneq ($(CONFIG_DCB),)
> > obj-y				+= dcb/
> > endif
> > -obj-y				+= ieee802154/
> > +obj-$(CONFIG_6LOWPAN)		+= 6lowpan/
> > +obj-$(CONFIG_IEEE802154)	+= ieee802154/
> > obj-$(CONFIG_MAC802154)		+= mac802154/
> > 
> > ifeq ($(CONFIG_NET),y)
> > diff --git a/net/bluetooth/Kconfig b/net/bluetooth/Kconfig
> > index 06ec144..a54777d 100644
> > --- a/net/bluetooth/Kconfig
> > +++ b/net/bluetooth/Kconfig
> > @@ -6,7 +6,6 @@ menuconfig BT
> > 	tristate "Bluetooth subsystem support"
> > 	depends on NET && !S390
> > 	depends on RFKILL || !RFKILL
> > -	select 6LOWPAN_IPHC if BT_6LOWPAN
> > 	select CRC16
> > 	select CRYPTO
> > 	select CRYPTO_BLKCIPHER
> > @@ -42,7 +41,7 @@ menuconfig BT
> > 
> > config BT_6LOWPAN
> > 	bool "Bluetooth 6LoWPAN support"
> > -	depends on BT && IPV6
> > +	depends on BT && 6LOWPAN
> > 	help
> > 	  IPv6 compression over Bluetooth.
> 
> this will conflict with our changes in wireless-next tree. We converted out 6LoWPAN support into a separate module.
> 

oops, sorry I didn't check on this. I simple based it on net-next,
because the patch series adds a new branch.



btw. we need to talk about who branch will commit changes to iphc code
to avoid conflicts.

- Alex
