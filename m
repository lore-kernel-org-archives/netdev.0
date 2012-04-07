From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH net-next V2] tcp: Fix bug when gap in rcv sequence is filled
Date: Sat, 7 Apr 2012 11:58:09 -0700
Message-ID: <CAGK4HS-Z_sOOeFp-5bh+C8iCoX_86Vp6vSeXAmpfutAi3Gieqg@mail.gmail.com>
References: <1333733810-2381-1-git-send-email-subramanian.vijay@gmail.com>
	<CAAsGZS4w=2_e9O=cRK6r+gxirohhSPHpgkNpWw_ZvC-+Q-pHkA@mail.gmail.com>
	<CAGK4HS-FZ038=Yik4DEQ26y4-9Zx9Gp80CU5_JS0U-anxjh9Wg@mail.gmail.com>
	<CADVnQy==-AbEfge3ZgmzSzMEjMXsGdRWVvw=Tb2dosP9StifJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: chetan loke <loke.chetan@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, ilpo.jarvinen@helsinki.fi
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:53936 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752463Ab2DGS6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Apr 2012 14:58:11 -0400
Received: by vbbff1 with SMTP id ff1so1670832vbb.19
        for <netdev@vger.kernel.org>; Sat, 07 Apr 2012 11:58:10 -0700 (PDT)
In-Reply-To: <CADVnQy==-AbEfge3ZgmzSzMEjMXsGdRWVvw=Tb2dosP9StifJg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the review Neal.

>
> If you have some packet traces documenting that there is actually a
> bug here, can you please share them?
>
No. My claim was based only on an audit of the code.

> AFAICT the code correctly generates immediate ACKs in these cases by:
>
> (a) having __tcp_ack_snd_check() call tcp_send_ack() to send an
> immediate ack if out_of_order_queue is non-empty.
>
> (b) having tcp_data_queue set icsk_ack.pingpong to 0 when
> out_of_order_queue transitions from non-empty to empty
>

I noted that  icsk_ack.pingpong is set to 0 in event (b) and also when
data is added to ofo queue
but I completely missed the check in __tcp_ack_snd_check().


>
> .798 B>A . 50001:60001(10000) ack 1001 win 20000
> .838 A>B . ack 60001 win 10000
> .848 B>A . 61001:62001(1000) ack 1001 win 20000
> .848 A>B . ack 60001 win 10000 <nop,nop,sack 1 {61001:62001}>
> .858 B>A . 63001:64001(1000) ack 1001 win 20000
> .858 A>B . ack 60001 win 10000 <nop,nop,sack 2 {63001:64001}{61001:62001}>
> .868 B>A . 60001:61001(1000) ack 1001 win 20000
> .868 A>B . ack 62001 win 10000 <nop,nop,sack 1 {63001:64001}>
>

For your trace it is clear acks are sent correctly and there is no bug.
I should have checked the behavior on the wire. Sorry for the noise.

Thanks,
Vijay
