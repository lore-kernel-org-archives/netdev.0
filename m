From: Ben Greear <greearb@candelatech.com>
Subject: Re: Specifying netdev name on kernel boot?
Date: Thu, 15 Aug 2013 11:26:06 -0700
Message-ID: <520D1D3E.1010702@candelatech.com>
References: <520CF8BB.2080702@candelatech.com> <1376590143.2180.11.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:44848 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751903Ab3HOS0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 14:26:10 -0400
In-Reply-To: <1376590143.2180.11.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/15/2013 11:09 AM, Dan Williams wrote:
> On Thu, 2013-08-15 at 08:50 -0700, Ben Greear wrote:
>> It seems they finally broke udev in Fedora 19...it can no longer
>> rename ethX to ethY, for whatever reason.
>
> It's intentional AFAIK, it won't rename devices into the kernel
> namespace (eth, wlan, usb, wwan) because it's inherently race-prone and
> there's no way to know that the kernel didn't just detect a new eth2
> while you're about to rename your eth0 to eth2.  There actually have
> been a lot of problems with that in past, because bus enumeration order
> is not guaranteed.
>
> I'm pretty sure you drop a rule in /etc/udev/rules.d  to what you want:
>
> SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:xx:xx:xx:xx:xx", ATTR{dev_id}=="0x0", ATTR{type}=="1", KERNEL=="eth*", NAME="eth0"

This used to work, but no longer does in Fedora 19.  If you do NAME="eth0r" then
it does work.

It shouldn't actually race (or at least shouldn't cause problems) at
the kernel level, and user-space should be able to detect a conflict
and take evasive action.  Even if the rename itself fails due to a
race, user-space can just try again and it should work after a few tries.

I opened a bug against Fedora udev, for what that is worth.

> Or if you install biosdevname, you'll get the nice BIOS names for the
> interfaces which is usually something like "slot1nic0" or "builtin0" or
> something like that.
>
> (and yeah, one of my devices is "enp0s29f7u4" which is just f-king ugly.
> *I* know what that means and why udev is doing it, but I also sympathize
> with those who don't...)

Yeah, I really want to avoid those types of names.

I hacked up a perl script that does the rename, but it can cause
some churn because I can't find any useful way to make systemd
put the rename logic between udev and network bringup.  I am
mostly clueless on systemd, so perhaps it's easier than it looked.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
