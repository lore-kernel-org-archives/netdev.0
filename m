From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: tcp_bbr: Forcing set of BBR congestion control as default
Date: Mon, 2 Jan 2017 06:05:11 +0100
Message-ID: <CA+icZUXd8fN5BAZuCna=zpgSJcXivSG1S6cV1eMMJMWwL7RrLA@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: "David S. Miller <davem@davemloft.net> Neal Cardwell"
        <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f170.google.com ([209.85.217.170]:35029 "EHLO
        mail-ua0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750803AbdABFFM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 00:05:12 -0500
Received: by mail-ua0-f170.google.com with SMTP id v2so119454539uac.2
        for <netdev@vger.kernel.org>; Sun, 01 Jan 2017 21:05:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am trying to force the set of BBR congestion control as default.
My old linux-config uses CUBIC as default.
I want both BBR and CUBIC to be built but BBR shall be my default.

I tried the below snippet.

I refresh my new linux-config like this...

$ MAKE="make V=1" ; COMPILER="mycompiler" ; MAKE_OPTS="CC=$COMPILER
HOSTCC=$COMPILER" ; yes "" | $MAKE $MAKE_OPTS oldconfig && $MAKE
$MAKE_OPTS silentoldconfig < /dev/null

What am I doing wrong?

Thanks in advance.

Regards,
- Sedat -

P.S.: Patch snippet

--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -642,7 +642,7 @@ config TCP_CONG_CDG

 config TCP_CONG_BBR
        tristate "BBR TCP"
-       default n
+       default y
        ---help---

        BBR (Bottleneck Bandwidth and RTT) TCP congestion control aims to
@@ -657,7 +657,7 @@ config TCP_CONG_BBR

 choice
        prompt "Default TCP congestion control"
-       default DEFAULT_CUBIC
+       default DEFAULT_BBR
        help
          Select the TCP congestion control that will be used by default
          for all connections.
@@ -716,7 +716,7 @@ config DEFAULT_TCP_CONG
        default "dctcp" if DEFAULT_DCTCP
        default "cdg" if DEFAULT_CDG
        default "bbr" if DEFAULT_BBR
-       default "cubic"
+       default "bbr"

 config TCP_MD5SIG
        bool "TCP: MD5 Signature Option support (RFC2385)"

- EOT -
