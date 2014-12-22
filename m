From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Regression with commit 971f10eca186 ("tcp: better TCP_SKB_CB layout
 to reduce cache line misses")
Date: Mon, 22 Dec 2014 16:17:38 +0100
Message-ID: <54983612.8000600@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>, Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:36845 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754768AbaLVPRl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 10:17:41 -0500
Received: by mail-wg0-f47.google.com with SMTP id n12so6939201wgh.20
        for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 07:17:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One of our engineer (Huaibin Wang <huaibin.wang@6wind.com>) has reported and
analysed this bug:

This commit introduces a regression with IPv6 + IPsec transport + TCP.

In TCP (net/ipv6/tcp_ipv6.c), xfrm6_policy_check() is called and thus, after
some intermediate functions, _decode_session6() is also called.

This function uses IP6CB() (u8 nexthdr = nh[IP6CB(skb)->nhoff]), which is wrong
becauses it has been moved to the end of TCP_SKB_CB().

Not sure what is the best way to fix this, any suggestion?

Regards,
Nicolas
