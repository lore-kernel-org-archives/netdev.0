From: Fan Du <fengyuleidian0615@gmail.com>
Subject: Re: [PATCH net-next 3/3] ipv4: Create probe timer for tcp PMTU as
 per RFC4821
Date: Mon, 16 Feb 2015 13:28:47 +0800
Message-ID: <54E1800F.1040604@gmail.com>
References: <1423815405-32644-1-git-send-email-fan.du@intel.com> <1423815405-32644-4-git-send-email-fan.du@intel.com> <54DDCB11.5050304@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fan Du <fan.du@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:59620 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224AbbBPFdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 00:33:22 -0500
Received: by mail-pa0-f52.google.com with SMTP id et14so6656446pad.11
        for <netdev@vger.kernel.org>; Sun, 15 Feb 2015 21:33:22 -0800 (PST)
In-Reply-To: <54DDCB11.5050304@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2015=E5=B9=B402=E6=9C=8813=E6=97=A5 17:59, Ying Xue =E5=86=99=
=E9=81=93:
>> +static void icsk_mtup_probe_timer(unsigned long arg)
>> >+{
>> >+	struct sock *sk =3D (struct sock *)arg;
>> >+	struct net *net =3D sock_net(sk);
>> >+	struct inet_connection_sock *icsk =3D inet_csk(sk);
>> >+
>> >+	/* Restore orignal search range */
>> >+	icsk->icsk_mtup.search_high =3D icsk->icsk_mtup.search_high_sav;
>> >+	icsk->icsk_mtup.search_low =3D icsk->icsk_mtup.search_low_sav;
>> >+	icsk->icsk_mtup.probe_size =3D 0;
>> >+}
>> >+
> As icsk_mtup_probe_timer() is run asynchronously, we may touch an inv=
alid socket
> instance if we don't hold socket's refcount before launching the time=
r.
>
> Therefore, in general we use the standard interfaces like sk_reset_ti=
mer() and
> sk_stop_timer() to operate timers associated with socket. So, the usa=
ge about
> timer in the patch seems unsafe for us. For instance, you can study h=
ow
> icsk_retransmit_timer, icsk_delack_timer and sk_timer, are implemente=
d.

right, socket layer has stander API wrapper to manipulate timers like y=
ou point out.
Thanks for the notice :)

> Regards,
> Ying
>
