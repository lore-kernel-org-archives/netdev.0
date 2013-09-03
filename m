From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: BQL support in gianfar causes network hiccup
Date: Tue, 3 Sep 2013 19:09:45 +0300
Message-ID: <522609C9.7030901@freescale.com>
References: <522490CB.60008@appeartv.com> <52249859.2040605@freescale.com>  <5224A2A8.6000306@appeartv.com> <5224B026.8090803@freescale.com>  <5224C1EB.3030307@appeartv.com> <52258A60.8040305@freescale.com>  <522595DD.1030600@appeartv.com> <1378222940.7360.34.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?UGVyIERhbMOpbg==?= <per.dalen@appeartv.com>,
	<netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe003.messaging.microsoft.com ([207.46.163.26]:13954
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752702Ab3ICQKG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 12:10:06 -0400
In-Reply-To: <1378222940.7360.34.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 9/3/2013 6:42 PM, Eric Dumazet wrote:
> On Tue, 2013-09-03 at 09:55 +0200, Per Dal=C3=A9n wrote:
>
>> Yes, it's weird. The only reason I removed the BQL commit
>> (d8a0f1b0af67679bba886784de10d8c21acc4e0e) was because the error Tin=
o
>> Keitel had was the similar as mine.
>
>
> I suspect a genuine race in this driver. BQL only makes this race hap=
pen
> more often.
>
> gfar_poll_sq() has the following :
>
> /* run Tx cleanup to completion */
> if (tx_queue->tx_skbuff[tx_queue->skb_dirtytx])
>          gfar_clean_tx_ring(tx_queue);
>
> While gfar_poll() has a different method :
>
> if (tx_queue->tx_skbuff[tx_queue->skb_dirtytx]) {
>      gfar_clean_tx_ring(tx_queue);
>      has_tx_work =3D 1;
> }
>
> Note the has_tx_work use in gfar_poll() only.
>
> Note that memory barriers seems to be missing.
>
> 1) In your cases, is it gfar_poll_sq() or gfar_poll() that is used ?
>

It's gfar_poll_sq(). P2020 single Tx/Rx queues.

I'm also seeing carrier errors and packet collisions in this case
(100/Half link).

> 2) Is the bug happening if only one CPU is used ?
>

I didn't try this. Maybe Per did?
