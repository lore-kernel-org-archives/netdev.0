From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: pskb_copy() in tcp_transmit_skb()
Date: Tue, 13 Sep 2011 14:51:16 +0200
Message-ID: <CAL4Wiirw1kjBEDVHDNETb7MwEenq0x2XOtQKdzYtNkp1m3nrrA@mail.gmail.com>
References: <201109131221.37561.christoph.paasch@uclouvain.be>
	<201109131355.55588.christoph.paasch@uclouvain.be>
	<CAL4Wiio=2MO2u53dvU1fqjeKqgQuVBmgDpZeVROMaZYcPPDpzA@mail.gmail.com>
	<201109131541.08542.christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gaofeng <gaofeng@cn.fujitsu.com>, netdev@vger.kernel.org
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:35876 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753378Ab1IMMvR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2011 08:51:17 -0400
Received: by gyg10 with SMTP id 10so403748gyg.19
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2011 05:51:17 -0700 (PDT)
In-Reply-To: <201109131541.08542.christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 13 septembre 2011 14:41, Christoph Paasch
<christoph.paasch@uclouvain.be> a =E9crit :
> Eric,
>
> On Tuesday 13 September 2011 wrote Eric Dumazet:
>> I suggest you read dev_queue_xmit_nit() : Every xmit packet can be
>> cloned right here.
>>
>> By the time tcp_retransmit_skb() is called, cloned skb might still b=
e
>> in a AF_PACKET queue (or even a device TX queue)
>
> Thanks for the clear answer.
>
> So, basically every call to tcp_retransmit_skb on an skb that is also=
 still
> hold in an AF_PACKET queue will end up in pskb_copy, because:
> 1. it has been cloned previously in tcp_transmit_skb()
> 2. The data_ref > 1 because it's clone is still in an AF_PACKET queue=
=2E
>
> Please correct me, if I'm wrong.

Thats correct.
