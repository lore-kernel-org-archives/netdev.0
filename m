From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: stable/linux-4.10.y build: 203 builds: 3 failed, 200 passed, 3
 errors, 5 warnings (v4.10.16)
Date: Mon, 15 May 2017 14:57:08 +0200
Message-ID: <CAK8P3a2gFXScsizfvd-2=yEWBvPoE7L-r5CCf63MzPuWejPzAQ@mail.gmail.com>
References: <5918603a.118d1c0a.d6026.6b1a@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Kernel Build Reports Mailman List
        <kernel-build-reports@lists.linaro.org>,
        Eric Dumazet <edumazet@google.com>,
        gregkh <gregkh@linuxfoundation.org>, stable@vger.kernel.org,
        Networking <netdev@vger.kernel.org>
To: "kernelci.org bot" <bot@kernelci.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:35134 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932839AbdEOM5O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 08:57:14 -0400
In-Reply-To: <5918603a.118d1c0a.d6026.6b1a@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 14, 2017 at 3:48 PM, kernelci.org bot <bot@kernelci.org> wrote:
>
> stable/linux-4.10.y build: 203 builds: 3 failed, 200 passed, 3 errors, 5 warnings (v4.10.16)
> Full Build Summary: https://kernelci.org/build/stable/branch/linux-4.10.y/kernel/v4.10.16/
> Tree: stable
> Branch: linux-4.10.y
> Git Describe: v4.10.16
> Git Commit: 6e8e9958691907e8d7eb3b2107619dddbdaeb175
> Git URL: http://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
> Built: 4 unique architectures
>
> Build Failures Detected:
>
> arm: gcc version 5.3.1 20160412 (Linaro GCC 5.3-2016.05)
> spear3xx_defconfig FAIL
> spear6xx_defconfig FAIL
> tct_hammer_defconfig FAIL
> Errors summary:
> 3 net/core/skbuff.c:1575:37: error: 'sock_edemux' undeclared (first use in this function)
> Warnings summary:

This is a regression against v4.10.15, caused by the backport of
c21b48cc1bbf ("net: adjust skb->truesize in ___pskb_trim()") by Eric
Dumazet.

Part of another commit that Eric did earlier fixes it:

158f323b9868 ("net: adjust skb->truesize in pskb_expand_head()")
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1534,7 +1534,7 @@ void sock_efree(struct sk_buff *skb);
 #ifdef CONFIG_INET
 void sock_edemux(struct sk_buff *skb);
 #else
-#define sock_edemux(skb) sock_efree(skb)
+#define sock_edemux sock_efree
 #endif

 int sock_setsockopt(struct socket *sock, int level, int op,

This commit is not marked 'Cc: stable' upstream, but is referenced
in the one that was backported and looks like it might be appropriate
for stable as well. Eric, can you clarify?

       Arnd
