From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: Re: kernel 3.7.6, l2tp, =?UTF-8?Q?qdisc=5Ftx=20circular=20loc?=
 =?UTF-8?Q?king?=
Date: Sat, 16 Feb 2013 00:54:51 +0200
Message-ID: <f7eac976327ae563a2ab0fe313474128@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:59639 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751471Ab3BOWyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 17:54:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry accidentaly deleted my emails, i will try in next 2 days to 
update server with l2tp, and will test everything there, if i can 
reproduce bug.

>diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
>index dcfd64e..7baf88f 100644
>--- a/net/l2tp/l2tp_core.c
>+++ b/net/l2tp/l2tp_core.c
>@@ -1251,8 +1251,11 @@ int l2tp_xmit_skb(struct l2tp_session *session, 
> struct sk_buff *skb, int hdr_len
> 	}
>
> 	l2tp_skb_set_owner_w(skb, sk);
>+	bh_unlock_sock(sk);
>
> 	l2tp_xmit_core(session, skb, fl, data_len);
>+	return ret;
>+
> out_unlock:
> 	bh_unlock_sock(sk);

---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
