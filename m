From: Roland Dreier <roland@digitalvampire.org>
Subject: IPv6 default routes timing out?
Date: Wed, 29 Jul 2009 10:42:07 -0700
Message-ID: <874osv8jyo.fsf@shaolin.home.digitalvampire.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:35756
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751184AbZG2RsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 13:48:05 -0400
Received: from shaolin.home.digitalvampire.org (shaolin.home.digitalvampire.org [10.1.0.2])
	by hellmouth.digitalvampire.org (Postfix) with ESMTP id 2DF99130BD
	for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 10:42:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I recently set up IPv6 on home home network -- openbsd 4.5 box serving
as a router with wired and wireless ports, advertising routes via the
openbsd rtadvd daemon.  I have no problem on boxes on the wired
network, which gets a default route like:

    default via fe80::240:63ff:feda:3d15 dev eth0  proto kernel  metric 1024  expires 8630sec mtu 1500 advmss 1440 hoplimit 64

However on laptops on the wireless network, I've seen the route
timeout and apparently never reappear.  This happens running both old
kernels like 2.6.24 and also with 2.6.31-rc4, and on systems with both
ipw2200 and iwlagn wirelss.  The symptom is that if I leave my laptop
running, say, overnight, in the morning the ipv6 default route is
gone.  ipv4 networking still works fine, and if I try explicit
link-local ipv6 addresses on the laptop, they work fine too.  But the
ipv6 internet is gone because the kernel has no idea how to route
packets to it.

The openbsd rtadvd config is pretty basic, just:

    ral0:\  
            :addr="2001:470:8379:2::":prefixlen#64:rltime#9000:\
            :maxinterval#120:mininterval#60:

Any ideas as to what I'm doing wrong, or where the problem might be?

Thanks,
  Roland
