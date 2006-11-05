From: Paul Moore <paul.moore@hp.com>
Subject: Re: linux-2.6.19-rc4-g10b1fbdb build #114 failed
Date: Sun, 5 Nov 2006 16:24:07 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0611051621450.30121@sockpuppet.zko.hp.com>
References: <200611051943.27210.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1947206514-330610727-1162761847=:30121"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:60827 "EHLO atlrel7.hp.com")
	by vger.kernel.org with ESMTP id S965888AbWKEVKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Nov 2006 16:10:06 -0500
To: Toralf =?iso-8859-1?q?F=F6rster?= <toralf.foerster@gmx.de>
In-Reply-To: <200611051943.27210.toralf.foerster@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--1947206514-330610727-1162761847=:30121
Content-Type: TEXT/PLAIN; charset=X-UNKNOWN; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Sun, 5 Nov 2006, Toralf F=F6rster wrote:
>
> Hello,
>
> the build with the attached .config failed, make ends with:
> ...
> : undefined reference to `cipso_v4_sock_getattr'
> net/built-in.o: In function `netlbl_socket_getattr':

Ah ha!  Why did you have to go and build a kernel without TCP/IP
networking ;)

It looks like I was stupid and made NetLabel depend on CONFIG_NET and not
CONFIG_INET, the patch below should fix this by making NetLabel depend on
CONFIG_INET and CONFIG_SECURITY.  Please review and apply for 2.6.19.

Signed-off-by: Paul Moore <paul.moore@hp.com>

diff --git a/net/Kconfig b/net/Kconfig
index a81aca4..67e39ad 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -63,6 +63,7 @@ config INET
  if INET
  source "net/ipv4/Kconfig"
  source "net/ipv6/Kconfig"
+source "net/netlabel/Kconfig"

  endif # if INET

@@ -249,8 +250,6 @@ source "net/ieee80211/Kconfig"
  config WIRELESS_EXT
  =09bool

-source "net/netlabel/Kconfig"
-
  config FIB_RULES
  =09bool

diff --git a/net/netlabel/Kconfig b/net/netlabel/Kconfig
index 9f7121a..56958c8 100644
--- a/net/netlabel/Kconfig
+++ b/net/netlabel/Kconfig
@@ -4,7 +4,7 @@ #

  config NETLABEL
  =09bool "NetLabel subsystem support"
-=09depends on NET && SECURITY
+=09depends on SECURITY
  =09default n
  =09---help---
  =09  NetLabel provides support for explicit network packet labeling

--
paul moore
linux security @ hp

--1947206514-330610727-1162761847=:30121--
