From: Nandita Dukkipati <nanditad@google.com>
Subject: Re: [PATCH v2] Proportional Rate Reduction for TCP.
Date: Fri, 19 Aug 2011 18:29:15 -0700
Message-ID: <CAB_+Fg6YE0knqjNKfYHR5+kGezjVCz_J+zEXb=5pJi46fnRbmw@mail.gmail.com>
References: <1313134197-5082-1-git-send-email-nanditad@google.com>
	<1313739212-2315-1-git-send-email-nanditad@google.com>
	<20110819.032651.405436165608502880.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, therbert@google.com, mattmathis@google.com,
	ycheng@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:25060 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142Ab1HTB3T convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 21:29:19 -0400
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p7K1THLS020569
	for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 18:29:17 -0700
Received: from ywa12 (ywa12.prod.google.com [10.192.1.12])
	by wpaz33.hot.corp.google.com with ESMTP id p7K1SpL4032042
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 18:29:16 -0700
Received: by ywa12 with SMTP id 12so1724139ywa.20
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 18:29:16 -0700 (PDT)
In-Reply-To: <20110819.032651.405436165608502880.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 19, 2011 at 3:26 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Nandita Dukkipati <nanditad@google.com>
> Date: Fri, 19 Aug 2011 00:33:32 -0700
>
>> @@ -2830,9 +2830,14 @@ static int tcp_try_undo_loss(struct sock *sk)
>> =A0static inline void tcp_complete_cwr(struct sock *sk)
>> =A0{
>> =A0 =A0 =A0 struct tcp_sock *tp =3D tcp_sk(sk);
>> - =A0 =A0 /* Do not moderate cwnd if it's already undone in cwr or r=
ecovery */
>> - =A0 =A0 if (tp->undo_marker && tp->snd_cwnd > tp->snd_ssthresh) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 tp->snd_cwnd =3D tp->snd_ssthresh;
>> +
>> + =A0 =A0 /* Do not moderate cwnd if it's already undone in cwr or r=
ecovery. */
>> + =A0 =A0 if (tp->undo_marker) {
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (inet_csk(sk)->icsk_ca_state =3D=3D TCP=
_CA_CWR)
>
> Please get rid of that empty line before the TCP_CA_CWR case.

Done.
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 sndcnt =3D DIV_ROUND_UP((u64)(tp->prr_deli=
vered *
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 tp->snd_ssthresh),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 (u64)tp->prior_cwnd) - tp->prr_out;
>
> This won't link on 32-bit unless __divdi3 libgcc routine is provided
> by the architecture. =A0To portably do 64-bit division you need to us=
e
> do_div() or something based upon it. =A0Perhaps DIV_ROUND_UP_LL() wil=
l
> work best in this case.

patch v3 uses div_u64 which is based on do_div() for 32-bit archs.

Thanks
Nandita
