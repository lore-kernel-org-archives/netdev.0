From: Per =?iso-8859-1?Q?Dal=E9n?= <per.dalen@appeartv.com>
Subject: Re: BQL support in gianfar causes network hiccup
Date: Tue, 3 Sep 2013 21:33:37 +0200 (CEST)
Message-ID: <59220.62.16.236.213.1378236817.squirrel@webmail.m5.itpays.net>
References: <522490CB.60008@appeartv.com> <52249859.2040605@freescale.com>
    <5224A2A8.6000306@appeartv.com> <5224B026.8090803@freescale.com>
    <5224C1EB.3030307@appeartv.com> <52258A60.8040305@freescale.com>
    <522595DD.1030600@appeartv.com>
    <1378222940.7360.34.camel@edumazet-glaptop>
    <522609C9.7030901@freescale.com>
Reply-To: per.dalen@appeartv.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric Dumazet" <eric.dumazet@gmail.com>,
	Per =?iso-8859-1?Q?Dal=C3=A9n?= <per.dalen@appeartv.com>,
	netdev@vger.kernel.org
To: "Claudiu Manoil" <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail-out-1.ip.no ([193.107.29.119]:35870 "EHLO
	webmail-out-1.ip.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932315Ab3ICTdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 15:33:39 -0400
In-Reply-To: <522609C9.7030901@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
>
> On 9/3/2013 6:42 PM, Eric Dumazet wrote:
>> On Tue, 2013-09-03 at 09:55 +0200, Per Dal=C3=A9n wrote:
>>
>>> Yes, it's weird. The only reason I removed the BQL commit
>>> (d8a0f1b0af67679bba886784de10d8c21acc4e0e) was because the error Ti=
no
>>> Keitel had was the similar as mine.
>>
>>
>> I suspect a genuine race in this driver. BQL only makes this race ha=
ppen
>> more often.
>>
>> gfar_poll_sq() has the following :
>>
>> /* run Tx cleanup to completion */
>> if (tx_queue->tx_skbuff[tx_queue->skb_dirtytx])
>>          gfar_clean_tx_ring(tx_queue);
>>
>> While gfar_poll() has a different method :
>>
>> if (tx_queue->tx_skbuff[tx_queue->skb_dirtytx]) {
>>      gfar_clean_tx_ring(tx_queue);
>>      has_tx_work =3D 1;
>> }
>>
>> Note the has_tx_work use in gfar_poll() only.
>>
>> Note that memory barriers seems to be missing.
>>
>> 1) In your cases, is it gfar_poll_sq() or gfar_poll() that is used ?
>>
>
> It's gfar_poll_sq(). P2020 single Tx/Rx queues.
>
> I'm also seeing carrier errors and packet collisions in this case
> (100/Half link).
>
>> 2) Is the bug happening if only one CPU is used ?
>>
>
> I didn't try this. Maybe Per did?
>

I use both CPUs.
