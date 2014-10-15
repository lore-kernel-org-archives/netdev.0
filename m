From: Cong Wang <cwang@twopensource.com>
Subject: Re: something is wrong in commit 971f10eca1 - tcp: better TCP_SKB_CB
 layout to reduce cache line misses
Date: Wed, 15 Oct 2014 14:22:48 -0700
Message-ID: <CAHA+R7PK=oXswV0PAkKtAqaeJh+Rx7ug0aaLKoJzJovR98dJpg@mail.gmail.com>
References: <CAFrEnehWNzmzZGV-ZGbZF=wJ1q0TjFtB1yG6Dp1yVrJmBj9B7Q@mail.gmail.com>
	<20141014.164705.1874094084240216813.davem@davemloft.net>
	<CAFrEnejET5wer6S6qx13tMKWMshmRj+JnQeZL-zdPGcs__9NoQ@mail.gmail.com>
	<20141014.171559.1355616486999711590.davem@davemloft.net>
	<CAHA+R7PyUZyjHPf-SJRiiOw=jQjJnXVaosYU7TuiVe6sQTC9Ww@mail.gmail.com>
	<1413323024.17109.11.camel@edumazet-glaptop2.roam.corp.google.com>
	<543E4DD8.80203@winsoft.pl>
	<CAHA+R7OEvTcZOm-OepWYvGP+pC_CJRoSen351nw8VJGdLTo0uA@mail.gmail.com>
	<543EDC2F.1090604@winsoft.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Krzysztof Kolasa <kkolasa@winsoft.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:59248 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776AbaJOVWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 17:22:49 -0400
Received: by mail-qc0-f182.google.com with SMTP id i17so1721657qcy.41
        for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 14:22:48 -0700 (PDT)
In-Reply-To: <543EDC2F.1090604@winsoft.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 15, 2014 at 1:42 PM, Krzysztof Kolasa <kkolasa@winsoft.pl> wrote:
> W dniu 15.10.2014 o 22:36, Cong Wang pisze:
>>
>> On Wed, Oct 15, 2014 at 3:35 AM, Krzysztof Kolasa <kkolasa@winsoft.pl>
>> wrote:
>>>
>>> one-line patch not resolve problem, fix created by Cong Wang resolves
>>> problem !!!
>>>
>>> tested on 64bit system and working OK
>>>
>> So my patch fixes your problem on 64bit but not on 32bit,
>> is this correct?
>
> Yes

Cool! Patches are coming.

Meanwhile Eric is debugging it, do you mind to try a followup quick
fix on your 32bit system?

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e13d778..12bd3f6 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1006,8 +1006,7 @@ static int tcp_transmit_skb(struct sock *sk,
struct sk_buff *skb, int clone_it,
        skb->tstamp.tv64 = 0;

        /* Cleanup our debris for IP stacks */
-       memset(skb->cb, 0, max(sizeof(struct inet_skb_parm),
-                              sizeof(struct inet6_skb_parm)));
+       memset(TCPCB(skb), 0, sizeof(*TCPCB(skb)));

        err = icsk->icsk_af_ops->queue_xmit(sk, skb, &inet->cork.fl);
