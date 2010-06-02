From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: sysfs class/net/ problem
Date: Wed, 02 Jun 2010 09:17:16 -0700
Message-ID: <m1ljaxxvcj.fsf@fess.ebiederm.org>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	<20100602154608.GB12361@kroah.com>
	<1275493693.3915.12.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:48448 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932450Ab0FBQRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 12:17:24 -0400
In-Reply-To: <1275493693.3915.12.camel@jlt3.sipsolutions.net> (Johannes Berg's message of "Wed\, 02 Jun 2010 17\:48\:13 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg <johannes@sipsolutions.net> writes:

> On Wed, 2010-06-02 at 08:46 -0700, Greg KH wrote:
>
>> > # rmmod mac80211_hwsim mac80211 cfg80211
>> > # ip link
>> > 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN 
>> >     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>> > 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN qlen 1000
>> >     link/ether 52:54:00:12:34:56 brd ff:ff:ff:ff:ff:ff
>> > # ls -l /sys/class/net/
>> > total 0
>> > lrwxrwxrwx 1 root root 0 Jun  2 13:12 eth0 -> ../../devices/pci0000:00/0000:00:03.0/net/eth0
>> > lrwxrwxrwx 1 root root 0 Jun  2 13:12 lo -> ../../devices/virtual/net/lo
>> > lrwxrwxrwx 1 root root 0 Jun  2 13:14 wlan0 -> ../../devices/virtual/mac80211_hwsim/hwsim0/wlan0
>> > lrwxrwxrwx 1 root root 0 Jun  2 13:14 wlan1 -> ../../devices/virtual/mac80211_hwsim/hwsim1/wlan1
>> > lrwxrwxrwx 1 root root 0 Jun  2 13:14 wlan2 -> ../../devices/virtual/mac80211_hwsim/hwsim2/wlan2
>> 
>> Ah, so the network devices aren't getting removed?
>
> Well the netdevs are gone, just the links aren't going away. the
> mac80211_hwsim directory is gone too.
>
>> Do you have network namespaces enabled in your kernel or disabled?
>
> enabled
>
>> And this is 2.6.35-rc1, right?
>
> yes.
>
> Come to think of it, maybe somehow it ends up removing
> mac80211_hwsim/hwsim0 before wlan0, and thus the link stays around? I
> guess I could make it print messages about that somehow?

The wireless drivers are a little different, and come to think of it
network namespace support has been added to the wireless drivers since
last I looked closely.  Do you know what creates/deletes these links?
Is it the normal register_netdevice -> device_add path?

I definitely changed the symlink code a little making things network namespace
aware so it is reasonable to assume that something in my changes affected the
wireless drivers.

I took a quick look and with my patches against 2.6.33 I'm not seeing this.

I take a closer look at 2.6.35-rc1 and see if I can figure out what is
going on.  It would definitely be wrong if hwsim0 is removed before
wlan0.  Still on my todo it seems is to fix the lifetime issues of all
of the callers, grr.

Eric
