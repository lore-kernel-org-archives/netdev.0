From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v3] net: batch skb dequeueing from softnet input_pkt_queue
Date: Wed, 14 Apr 2010 20:13:20 +0800
Message-ID: <o2k412e6f7f1004140513h8de62790tb775bb357e2db6b1@mail.gmail.com>
References: <1271238738-8386-1-git-send-email-xiaosuo@gmail.com>
	<1271246304.3943.60.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f199.google.com ([209.85.210.199]:38966 "EHLO
	mail-yx0-f199.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755073Ab0DNMNu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 08:13:50 -0400
Received: by yxe37 with SMTP id 37so19910yxe.21
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 05:13:49 -0700 (PDT)
In-Reply-To: <1271246304.3943.60.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 14, 2010 at 7:58 PM, jamal <hadi@cyberus.ca> wrote:
>
> It seems we are now going to generate a lot more IPIs with such a
> change. At least this is what i am imagining.
> CPU0: packet comes in,queue empty, generate an IPI to CPU1
> CPU0: second packet comes in, enqueue
> CPU1: grab two packets to process and run with them
> CPU0: packet comes in,queue empty, generate an IPI to CPU1

No extra IPI is needed.

+       qlen =3D queue->input_pkt_queue.qlen + queue->processing_queue.=
qlen;
+       if (qlen <=3D netdev_max_backlog) {
+               if (qlen) {

the packets in processing_queue are counted too.

>
> IPIs add to latency (refer to my other email). Did you test this
> to reach some conclusion that it improves thing or was it just by
> inspection?
>

:( only insepection.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
