From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] net: secure_seq: Move net_secret_init() definition into
 CONFIG_IPV6 if block
Date: Sat, 5 Oct 2013 17:26:59 -0300
Message-ID: <CAOMZO5ABxzh8iUKrkYy9sLbQhbcKHh-wheNDN+A8RmSyaVX+Ag@mail.gmail.com>
References: <1381003790-12731-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: edumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Olof Johansson <olof@lixom.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:42417 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752366Ab3JEU1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Oct 2013 16:27:01 -0400
Received: by mail-we0-f178.google.com with SMTP id q59so5088185wes.37
        for <netdev@vger.kernel.org>; Sat, 05 Oct 2013 13:26:59 -0700 (PDT)
In-Reply-To: <1381003790-12731-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 5, 2013 at 5:09 PM, Fabio Estevam <festevam@gmail.com> wrote:
> From: Fabio Estevam <fabio.estevam@freescale.com>
>
> Commit 9a3bab6b05 (net: net_secret should not depend on TCP) introduced
> the following build warning when CONFIG_IPV6 is not selected:
>
> net/core/secure_seq.c:17:13: warning: 'net_secret_init' defined but not used [-Wunused-function]
>
> Fix it by moving net_secret_init(void) inside the '#if IS_ENABLED(CONFIG_IPV6)'
> block.
>
> Reported-by: Olof Johansson <olof@lixom.net>
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Another solution would be:

--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -10,6 +10,7 @@

 #include <net/secure_seq.h>

+#if IS_ENABLED(CONFIG_IPV6)
 #define NET_SECRET_SIZE (MD5_MESSAGE_BYTES / 4)

 static u32 net_secret[NET_SECRET_SIZE] ____cacheline_aligned;
@@ -29,6 +30,7 @@ static void net_secret_init(void)
                cmpxchg(&net_secret[--i], 0, tmp);
        }
 }
+#endif

If this is preferred, I can send a v2 like that.
