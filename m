From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [d80211 rfc] link master interface from wiphy
Date: Wed, 16 Aug 2006 19:05:20 +0200
Message-ID: <20060816190520.57cb676f@griffin.suse.cz>
References: <44E02F41.2060300@sipsolutions.net>
	<44E03051.8030808@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jouni Malinen <jkm@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:15753 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751212AbWHPRFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 13:05:23 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <44E03051.8030808@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 14 Aug 2006 10:12:01 +0200, Johannes Berg wrote:
> I'd like to see a link from the wiphy to the master interface that 
> belongs to it so one can tell this easily on systems that have multiple 
> wireless devices.

As wiphy and master interface are closely bind to each other, this makes
sense.

Btw, we will probably need some way to ask d80211 about all interfaces
belonging to given wiphy anyway. Crawling all network interfaces and
searching for correct wiphy symlinks is probably not the best way. I
think a new netlink interface can be used for this.

> wpa_supplicant could use this, I guess. I think 
> another link to wlan#ap should be created (or does wpa_supplicant set 
> the name of that so it knows which one it will get?), or something like 
> that anyway.

wmgmt# will go away in future. There is an ioctl to get its ifindex, so
no need for the link.

> On the other hand, is there any real reason we have this code:
>         ndev->base_addr = dev->base_addr;
>         ndev->irq = dev->irq;
>         ndev->mem_start = dev->mem_start;
>         ndev->mem_end = dev->mem_end;
>         ndev->flags = dev->flags & IFF_MULTICAST;
>         SET_NETDEV_DEV(ndev, dev->class_dev.dev);
> 
> in ieee80211_if_add? Maybe we should make the virtual devices all 
> children of the wiphy (struct ieee80211_local) instead of making them 
> children of the physical device? I don't really know though. This is too 
> dark magic for me ;)

What do you mean by "making the virtual devices all children of the
wiphy"? Currently, all virtual devices (of one physical device) have the
same pointer to ieee80211_local in their net_dev structure and pointers
to them are stored in the linked list in ieee80211_local.

> However, I do know that I can trivially rename the wmaster0 interface 
> using just 'ip link set wmaster0 name wlan3' and things will probably be 
> very confusing for any program that relies on the naming to know which 
> device is which.

Any program that relies on particular device names is broken.

> Comments welcome. Userspace comments as well, I'm programming something 
> that'll use a bunch of interfaces (wmaster, a monitor one and a sta one 
> probably) and I want the user to just select the physical interface, not 
> all these three logical ones... (in fact, I'm creating the logical 
> monitor interface myself in code).

Do you know about /sys/class/net/X/wiphy symlinks? But as I said,
crawling sysfs is not the best idea - among other things, it is subject
to race conditions.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
