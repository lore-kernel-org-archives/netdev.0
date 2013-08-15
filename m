From: Dan Williams <dcbw@redhat.com>
Subject: Re: Specifying netdev name on kernel boot?
Date: Thu, 15 Aug 2013 13:09:03 -0500
Message-ID: <1376590143.2180.11.camel@dcbw.foobar.com>
References: <520CF8BB.2080702@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24440 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753334Ab3HOSF1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Aug 2013 14:05:27 -0400
In-Reply-To: <520CF8BB.2080702@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-15 at 08:50 -0700, Ben Greear wrote:
> It seems they finally broke udev in Fedora 19...it can no longer
> rename ethX to ethY, for whatever reason.

It's intentional AFAIK, it won't rename devices into the kernel
namespace (eth, wlan, usb, wwan) because it's inherently race-prone and
there's no way to know that the kernel didn't just detect a new eth2
while you're about to rename your eth0 to eth2.  There actually have
been a lot of problems with that in past, because bus enumeration order
is not guaranteed.

I'm pretty sure you drop a rule in /etc/udev/rules.d  to what you want:

SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:xx:xx:xx:xx:xx", ATTR{dev_id}=="0x0", ATTR{type}=="1", KERNEL=="eth*", NAME="eth0"

Or if you install biosdevname, you'll get the nice BIOS names for the
interfaces which is usually something like "slot1nic0" or "builtin0" or
something like that.

(and yeah, one of my devices is "enp0s29f7u4" which is just f-king ugly.
*I* know what that means and why udev is doing it, but I also sympathize
with those who don't...)

Dan

> Is there a way to specify the naming on the kernel command line?
> 
> I found something in google that made me think this might work:
> 
> ifname=eth0:00:30:48:fc:17:a2 ifname=eth1:00:30:48:fc:17:a3 ifname=eth2:00:e0:ed:1c:ec:e4 ifname=eth3:00:e0:ed:1c:ec:e5
> 
> but it doesn't seem to have any affect.
> 
> I'm using ixgbe and e1000e drivers, loaded as modules, in case that matters.
> 
> Thanks,
> Ben
> 
