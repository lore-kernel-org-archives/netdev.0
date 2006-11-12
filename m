From: Michael Tokarev <mjt@tls.msk.ru>
Subject: airo driver: still can't deal with interface renames?
Date: Sun, 12 Nov 2006 19:15:36 +0300
Message-ID: <455748A8.2000205@tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.94.6]:17249 "EHLO hobbit.corpit.ru")
	by vger.kernel.org with ESMTP id S932950AbWKLQPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Nov 2006 11:15:41 -0500
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A long time ago, in kernel-2.4 days, I noticed that
airo module (for various aironet etc cards) can't
handle interface renames (at that time, the kernel
crashed after `ip link set eth1 name xxx' command
and some packets going to/from the interface).

The problem seems to be that the driver uses some
sort of private data in /proc/driver/airo/ethN/ which
gets created when the driver discovers an interface
and names it as usual, giving next available N in
ethN scheme.

And currently (2.6.18) the situation is still similar.
Well, it does not crashes, but still keeps the directory
in /proc/driver/airo named after the automatic interface
name, which leads to confusion at least, especially if
i load airo.ko, rename the iface, and next load some other
network driver module, which grabs THE SAME ethN as was
first grabbed by airo.

The fix seems to be to follow interface renames with name
change in /proc/driver/airo/.  Or, better longterm but
leads to incompatibilities, switch to using sysfs interface,
where the change will be made automagically.

I don't understand all the driver internals to a level when
I can fix the problem in the right way.  But I can fix it
with a hack, which seems to be simple enouth and will suit
at least my needs: by introducing another array of charp
for module parameters, giving the name(s) of interface(s)
it should create, just like currently it accepts "ssids"
and "rates" parameters.

Can someone comment on the situation, please?

Thanks.

/mjt
