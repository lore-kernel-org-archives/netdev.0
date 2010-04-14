From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v3] net: batch skb dequeueing from softnet input_pkt_queue
Date: Thu, 15 Apr 2010 07:13:30 +0800
Message-ID: <j2w412e6f7f1004141613r71823766i7045d631fa7dd064@mail.gmail.com>
References: <1271238738-8386-1-git-send-email-xiaosuo@gmail.com>
	<1271258409.16881.1701.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f198.google.com ([209.85.211.198]:57740 "EHLO
	mail-yw0-f198.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755297Ab0DNXNw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 19:13:52 -0400
Received: by ywh36 with SMTP id 36so354450ywh.4
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 16:13:51 -0700 (PDT)
In-Reply-To: <1271258409.16881.1701.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 14, 2010 at 11:20 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le mercredi 14 avril 2010 =C3=A0 17:52 +0800, Changli Gao a =C3=A9cri=
t :
>> batch skb dequeueing from softnet input_pkt_queue
>>
>> batch skb dequeueing from softnet input_pkt_queue to reduce potentia=
l lock
>> contention and irq disabling/enabling.
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>
> Adding stop_machine() with no explanation ?

stop_machine() is added to flush the processing_queue. Because the old
flush_backlog() runs in IRQ context, it can't touch the things, which
are only valid in softirq context.

>
> No ack from my previous comments, suggestions, and still same logic ?

In this patch, the volatile variable flush_processing_queue is
removed, and the corresponding lines are removed too.

Oh, I should splice the old message back, as stop_machine is used
instead. So, the processing queue will be removed from softnet_data,
and a single int counter will be used instead to count the packets
which are being processing.

one issue you concern is potential cache miss when summing in enqueue
function. It won't happen all the time, in fact, I think it should
happen seldom, and it is the responsibility of hardware to cache the
data frequently used.

>
> Are we supposed to read patch, test it, make some benches, correct bu=
gs,
> say Amen ?
>

OK, I'll test it.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
