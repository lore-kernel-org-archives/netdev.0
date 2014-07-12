From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 1/2] 6lowpan: introduce new net/6lowpan directory
Date: Sat, 12 Jul 2014 11:17:14 +0200
Message-ID: <20140712091712.GA15269@omega>
References: <1405067059-18782-1-git-send-email-alex.aring@gmail.com>
 <1405067059-18782-2-git-send-email-alex.aring@gmail.com>
 <8A1EF84C-3EDC-4540-B8F4-1FCBF4BF8D93@holtmann.org>
 <20140711113507.GA24370@omega>
 <E54EDE3F-99A2-49C0-842B-D15E8B7826D2@holtmann.org>
 <20140711225340.GA7561@omega>
 <07699E7C-9AA6-4BF7-9E52-996D69C499C1@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jukka Rissanen <jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <07699E7C-9AA6-4BF7-9E52-996D69C499C1-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Marcel,

On Sat, Jul 12, 2014 at 01:58:26AM +0200, Marcel Holtmann wrote:
> Hi Alexander,
> 
> >>>>> index cbbbe6d..7ed1970 100644
> >>>>> --- a/net/Makefile
> >>>>> +++ b/net/Makefile
> >>>>> @@ -57,7 +57,8 @@ obj-$(CONFIG_CAIF)		+= caif/
> >>>>> ifneq ($(CONFIG_DCB),)
> >>>>> obj-y				+= dcb/
> >>>>> endif
> >>>>> -obj-y				+= ieee802154/
> >>>>> +obj-$(CONFIG_6LOWPAN)		+= 6lowpan/
> >>>>> +obj-$(CONFIG_IEEE802154)	+= ieee802154/
> >>>>> obj-$(CONFIG_MAC802154)		+= mac802154/
> >>>>> 
> >>>>> ifeq ($(CONFIG_NET),y)
> >>>>> diff --git a/net/bluetooth/Kconfig b/net/bluetooth/Kconfig
> >>>>> index 06ec144..a54777d 100644
> >>>>> --- a/net/bluetooth/Kconfig
> >>>>> +++ b/net/bluetooth/Kconfig
> >>>>> @@ -6,7 +6,6 @@ menuconfig BT
> >>>>> 	tristate "Bluetooth subsystem support"
> >>>>> 	depends on NET && !S390
> >>>>> 	depends on RFKILL || !RFKILL
> >>>>> -	select 6LOWPAN_IPHC if BT_6LOWPAN
> >>>>> 	select CRC16
> >>>>> 	select CRYPTO
> >>>>> 	select CRYPTO_BLKCIPHER
> >>>>> @@ -42,7 +41,7 @@ menuconfig BT
> >>>>> 
> >>>>> config BT_6LOWPAN
> >>>>> 	bool "Bluetooth 6LoWPAN support"
> >>>>> -	depends on BT && IPV6
> >>>>> +	depends on BT && 6LOWPAN
> >>>>> 	help
> >>>>> 	  IPv6 compression over Bluetooth.
> >>>> 
> >>>> this will conflict with our changes in wireless-next tree. We converted out 6LoWPAN support into a separate module.
> >>>> 
> >>> 
> >>> oops, sorry I didn't check on this. I simple based it on net-next,
> >>> because the patch series adds a new branch.
> >>> 
> >>> 
> >>> 
> >>> btw. we need to talk about who branch will commit changes to iphc code
> >>> to avoid conflicts.
> >> 
> >> a few years back we decided to merge bluetooth-next via John's wireless-next tree so that any interaction with 802.11 and Bluetooth can be sorted out in John's tree. We are now also merging NFC into the wireless-next tree.
> >> 
> >> So it might be a good idea to include the 6LoWPAN parts into the wireless-next tree as well. If there are conflicts with 802.15.4, maybe that should also go through his trees.
> >> 
> > 
> > Ok. I am maintainer since three days ago and I need some time to setup
> > my infrastructure, then I will ask him. At the end I need to update the
> > MAINTAINERS file to the new infrastructure.
> > 
> >> If you want I can also take the net/6lowpan stuff through bluetooth-next tree.
> >> 
> > 
> > Yes, please Marcel. This is one file at the moment. I have in my local
> > branch also some patches (most of them use IPv6 API for address scopes
> > instead using the self builded macros). There is also a issue with error
> > handling which should be a long overdue fix. You will get some patches
> > for these issues in the next days.
> 
> I resolved the conflict locally in bluetooth-next and applied both of your patches to bluetooth-next tree.
> 
ok. Thanks.

I notice there is a patch in net-next for the old file
4710d806fcb825156e0a7b3a81104915c5e90f5d ("6lowpan: mac802154: fix coding
style issues").

It's not in bluetooth-next currently and the movement patch should not
occur any conflicts (I think). But I can't send you patches until this
is in bluetooth-next.

I wait until the next sync of bluetooth-next with net-next and you should not
apply any patches to "net/6lowpan/iphc.c" until that.

- Alex
