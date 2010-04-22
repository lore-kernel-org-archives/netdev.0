From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v4] net: batch skb dequeueing from softnet input_pkt_queue
Date: Thu, 22 Apr 2010 14:30:33 +0800
Message-ID: <p2i412e6f7f1004212330y6f3e2a92oa295e528afde3cd4@mail.gmail.com>
References: <1271915513-2966-1-git-send-email-xiaosuo@gmail.com>
	<20100421231843.4c284991@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, jamal <hadi@cyberus.ca>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f178.google.com ([209.85.223.178]:46180 "EHLO
	mail-iw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561Ab0DVGay convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 02:30:54 -0400
Received: by iwn8 with SMTP id 8so1684756iwn.16
        for <netdev@vger.kernel.org>; Wed, 21 Apr 2010 23:30:53 -0700 (PDT)
In-Reply-To: <20100421231843.4c284991@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 22, 2010 at 2:18 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Thu, 22 Apr 2010 13:51:53 +0800
> Changli Gao <xiaosuo@gmail.com> wrote:
>
>> + =C2=A0 =C2=A0 struct sk_buff =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*in=
put_pkt_queue_head;
>> + =C2=A0 =C2=A0 struct sk_buff =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0**i=
nput_pkt_queue_tailp;
>> + =C2=A0 =C2=A0 unsigned int =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
input_pkt_queue_len;
>> + =C2=A0 =C2=A0 unsigned int =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
process_queue_len;
>
> Why is opencoding a skb queue a step forward?
> Just keep using sk_queue routines, just not the locked variants.
>

I want to keep the critical section of rps_lock() as small as possible
to reduce the potential lock contention, when RPS is used.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
