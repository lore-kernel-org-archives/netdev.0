From: Tomas Melin <tomas.melin@iki.fi>
Subject: Build error v3.9-rc when CONFIG_IPV6 configured as module
Date: Sun, 14 Apr 2013 12:45:57 +0300
Message-ID: <CACraW2pBKzCfpORkERDGddvguCWai3j49uM7rHLja0QTREkg4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: johannes@sipsolutions.net, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:41778 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751288Ab3DNJp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Apr 2013 05:45:58 -0400
Received: by mail-la0-f44.google.com with SMTP id fr10so3620633lab.17
        for <netdev@vger.kernel.org>; Sun, 14 Apr 2013 02:45:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems CONFIG_IPV6 cannot be built as a module, using "m"-option
leads to to the following linking error:

net/built-in.o: In function `ieee80211_unregister_hw':
(.text+0x10f0e1): undefined reference to `unregister_inet6addr_notifier'
net/built-in.o: In function `ieee80211_register_hw':
(.text+0x10f610): undefined reference to `register_inet6addr_notifier'
make: *** [vmlinux] Error 1

This happens since the caller net/mac80211/main.c is statically built
in but net/ipv6/addrconf.c is then built as a module. Is this expected
behaviour or should it be fixed?

Configuration:  v3.9-rc6 with defconfig but ipv6 set to be a module
instead of built in.

-Tomas
