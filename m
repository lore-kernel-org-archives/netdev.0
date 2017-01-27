From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: adjust skb->truesize in pskb_expand_head()
Date: Thu, 26 Jan 2017 18:34:58 -0800
Message-ID: <1485484498.6360.2.camel@edumazet-glaptop3.roam.corp.google.com>
References: <201701271009.NCgqcrWI%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Slava Shwartsman <slavash@mellanox.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36123 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753097AbdA0CfW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 21:35:22 -0500
Received: by mail-pf0-f194.google.com with SMTP id 19so17536540pfo.3
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 18:35:00 -0800 (PST)
In-Reply-To: <201701271009.NCgqcrWI%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-01-27 at 10:22 +0800, kbuild test robot wrote:
> Hi Eric,
> 
> [auto build test WARNING on net-next/master]
> 
> url:    https://github.com/0day-ci/linux/commits/Eric-Dumazet/net-adjust-skb-truesize-in-pskb_expand_head/20170127-082517
> config: i386-randconfig-x0-01270914 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386 

Hmm... I thought sock_edemux was safe, but apparently it uses a
parameter for no good reason.

I will add this to v2

diff --git a/include/net/sock.h b/include/net/sock.h
index 7144750d14e56b9d5392e43dc46cb40a87e3d397..94e65fd703548dd40e16c30207fd55c879ed0b60 100644
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
