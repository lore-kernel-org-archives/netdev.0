From: Sangtae Ha <sangtae.ha@gmail.com>
Subject: Re: [PATCH 3/3] tcp_cubic: fix low utilization of CUBIC with HyStart
Date: Mon, 14 Mar 2011 03:36:24 -0400
Message-ID: <AANLkTinDWY2ZWE-y=OW1_-tbZFkuF73JP2fTfoj0icBt@mail.gmail.com>
References: <1300061073-24209-1-git-send-email-sangtae.ha@gmail.com>
	<AANLkTi=bO+7d7W0O-m4=62xcM5P2qao9pzOyPJ1-jtox@mail.gmail.com>
	<20110314062824.GA22755@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Injong Rhee <rhee@ncsu.edu>,
	Bill Fink <billfink@mindspring.com>, netdev@vger.kernel.org
To: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:64718 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752202Ab1CNHgZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 03:36:25 -0400
Received: by fxm17 with SMTP id 17so2617332fxm.19
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 00:36:24 -0700 (PDT)
In-Reply-To: <20110314062824.GA22755@xanadu.blop.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 14, 2011 at 2:28 AM, Lucas Nussbaum <lucas.nussbaum@loria.f=
r> wrote:
> On 13/03/11 at 19:07 -0500, Sangtae Ha wrote:
>> Hi Lucas,
>>
>> Thank you for reporting this problem and the results below show what
>> happened with low resolution clocks.
>> The detailed testing setup and results at
>> http://netsrv.csc.ncsu.edu/wiki/index.php/HyStart_testing_between_Pr=
inceton_and_NCSU
>> I will add the results in long rtt paths soon.
>
> Thanks. What do you use to generate those graphs?

I used net/ipv4/tcp_probe.c and gnuplot to generate the graphs.

>
> The graphs from HyStart(fixed) are a bit strange. Did HyStart really
> detect something? It seems that it exited slow start due to losses, n=
ot
> due to detection, since cwnd is decreased.

You can see green points which indicate that ssthresh is set before the=
 loss,
and right after that, the cwnd increases 20% per RTT since the
available bandwidth is still unknown.
This logic incurs far less number of losses compared to slow start and
hence more throughput.

> --
> | Lucas Nussbaum =A0 =A0 =A0 =A0 =A0 =A0 MCF Universit=E9 Nancy 2 |
> | lucas.nussbaum@loria.fr =A0 =A0 =A0 =A0 LORIA / AlGorille |
> | http://www.loria.fr/~lnussbau/ =A0+33 3 54 95 86 19 |
>

Sangtae
