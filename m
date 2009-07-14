From: Yinglin Sun <yinglinsun@cs.pitt.edu>
Subject: Re: [TCP_CA_CWR] Causes for entering TCP_CA_CWR state with 0
	retransmissions
Date: Tue, 14 Jul 2009 15:12:16 -0400
Message-ID: <46bf9ede0907141212x7a7a84f8l1882ffefbaf21e14@mail.gmail.com>
References: <46bf9ede0907141138q3b665aefv46a18591c3cfc2ce@mail.gmail.com>
	 <20090714.114211.254914419.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:65410 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753815AbZGNTMR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 15:12:17 -0400
Received: by ewy26 with SMTP id 26so3522709ewy.37
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2009 12:12:16 -0700 (PDT)
In-Reply-To: <20090714.114211.254914419.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

I use the total number of retransmissions reported by tcp_info. The
field name is tcpi_total_retrans. From the kernel source code, I found
that this number is for both fast retransmit and timeout
retransmissions. On the other hand, if fast retransmission happened,
ca_state should be TCP_CA_Recovery or TCP_CA_Disorder, but it's
TCP_CA_CWR.

Thanks.

Yinglin

On Tue, Jul 14, 2009 at 2:42 PM, David Miller<davem@davemloft.net> wrot=
e:
> From: Yinglin Sun <yinglin.s@gmail.com>
> Date: Tue, 14 Jul 2009 14:38:07 -0400
>
>> I have a question about tcp_ca_state "TCP_CA_CWR". =A0Under what
>> circumstances does it enter this state?
>> I'm doing some experiments and have trace from tcp_info. From tcp_in=
fo
>> trace, I found that many places show ca_state is 2 (TCP_CA_CWR). Und=
er
>> this state, the congestion window size decreases but the total numbe=
r
>> of retransmissions is still 0.
>
> What kind of "retransmissions"? =A0I bet the counter you are looking
> at is counting timeout based retransmissions, which means it isn't
> including the most predominant type of retransmissions, which are
> fast retransmissions which are triggered in response to ACKs.
>
