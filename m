From: Mathieu Trudel-Lapierre <mathieu.tl@gmail.com>
Subject: net.ipv*.conf.all.* sysctls
Date: Fri, 2 Dec 2011 13:32:26 -0500
Message-ID: <CACfMzvppwC=-EaH4eQJfnQA51HrEc+3w-SwrohzXOyVhi3AEyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:45731 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752694Ab1LBSc1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 13:32:27 -0500
Received: by eaak14 with SMTP id k14so3175842eaa.19
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2011 10:32:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Rehashing something that's I've found quite a few times in a quick
search in the archives, but still a little unclear to me.

As previously discussed here and as I could test on my system (Ubuntu
3.2.0-2.5-generic 3.2.0-rc3), seems like the net.ipv6.conf.all sysctls
aren't actually being propagated to all devices. Is this indeed an
issue and something that needs to be fixed, or are these settings
really expected to be used as "global" parameters?

I've done a simple test: after applying
net.ipv6.conf.all.use_tempaddr=3D2 and
net.ipv6.conf.default.use_tempaddr=3D2 to sysctl.conf and rebooting, I
still see the value for
net.ipv6.conf.eth0.use_tempaddr as 0, while other devices (wlan0) are
properly set to 2. This is most likely caused by eth0 being
initialized prior to the sysctl.conf file being read and applied.

Connecting to a wired network still shows the interface eth0 as not
using temporary addresses, which should be happening if "all" is
really meant as a global value to override what might be set
per-interface.

Besides fixing up sysctls to be applied early enough to affect eth0 as
well on my system; isn't there something else that needs to be done to
clarify and fix the /all/ settings? I believe either the documentation
and actual functionality needs to be fixed to be a global value and
override per-interface values, or the functionality needs to be
corrected to propagate values to the underlying interfaces.

Am I missing something here? I'm totally new to kernel development,
but would be happy to provide simple patches once the expected
behaviour is clarified.

Regards,

Mathieu Trudel-Lapierre <mathieu.tl@gmail.com>
=46reenode: cyphermox, Jabber: mathieu.tl@gmail.com
4096R/EE018C93 1967 8F7D 03A1 8F38 732E =C2=A0FF82 C126 33E1 EE01 8C93
