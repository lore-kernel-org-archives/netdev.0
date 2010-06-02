From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: sysfs class/net/ problem
Date: Wed, 02 Jun 2010 17:48:13 +0200
Message-ID: <1275493693.3915.12.camel@jlt3.sipsolutions.net>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	 <20100602154608.GB12361@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:50002 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757699Ab0FBPsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 11:48:14 -0400
In-Reply-To: <20100602154608.GB12361@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-02 at 08:46 -0700, Greg KH wrote:

> > # rmmod mac80211_hwsim mac80211 cfg80211
> > # ip link
> > 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN 
> >     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
> > 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN qlen 1000
> >     link/ether 52:54:00:12:34:56 brd ff:ff:ff:ff:ff:ff
> > # ls -l /sys/class/net/
> > total 0
> > lrwxrwxrwx 1 root root 0 Jun  2 13:12 eth0 -> ../../devices/pci0000:00/0000:00:03.0/net/eth0
> > lrwxrwxrwx 1 root root 0 Jun  2 13:12 lo -> ../../devices/virtual/net/lo
> > lrwxrwxrwx 1 root root 0 Jun  2 13:14 wlan0 -> ../../devices/virtual/mac80211_hwsim/hwsim0/wlan0
> > lrwxrwxrwx 1 root root 0 Jun  2 13:14 wlan1 -> ../../devices/virtual/mac80211_hwsim/hwsim1/wlan1
> > lrwxrwxrwx 1 root root 0 Jun  2 13:14 wlan2 -> ../../devices/virtual/mac80211_hwsim/hwsim2/wlan2
> 
> Ah, so the network devices aren't getting removed?

Well the netdevs are gone, just the links aren't going away. the
mac80211_hwsim directory is gone too.

> Do you have network namespaces enabled in your kernel or disabled?

enabled

> And this is 2.6.35-rc1, right?

yes.

Come to think of it, maybe somehow it ends up removing
mac80211_hwsim/hwsim0 before wlan0, and thus the link stays around? I
guess I could make it print messages about that somehow?

johannes

