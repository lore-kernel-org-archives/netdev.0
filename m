From: Nandita Dukkipati <nanditad@google.com>
Subject: Re: [PATCH] Proportional Rate Reduction for TCP.
Date: Fri, 19 Aug 2011 00:34:34 -0700
Message-ID: <CAB_+Fg6O8bsuromuPns8G3q+LSV-bqvJL11H6GoJGEpqhyrU=w@mail.gmail.com>
References: <1313134197-5082-1-git-send-email-nanditad@google.com>
	<m262m0lh0q.fsf@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Matt Mathis <mattmathis@google.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:39427 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513Ab1HSHeh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 03:34:37 -0400
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p7J7YaSg023976
	for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 00:34:36 -0700
Received: from yxk36 (yxk36.prod.google.com [10.190.3.164])
	by hpaq1.eem.corp.google.com with ESMTP id p7J7YYXH030068
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 00:34:35 -0700
Received: by yxk36 with SMTP id 36so1014588yxk.24
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 00:34:34 -0700 (PDT)
In-Reply-To: <m262m0lh0q.fsf@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 13, 2011 at 10:05 PM, Andi Kleen <andi@firstfloor.org> wrot=
e:
> Nandita Dukkipati <nanditad@google.com> writes:
>> +
>> + =A0 =A0 if (tcp_packets_in_flight(tp) > tp->snd_ssthresh) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (WARN_ON(!tp->prr_cwnd))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->prr_cwnd =3D 1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 sndcnt =3D DIV_ROUND_UP(tp->prr_delivered =
* tp->snd_ssthresh,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 tp->prr_cwnd) - tp->prr_out;
>> + =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 sndcnt =3D min_t(int, delta,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0max_t(int, =
tp->prr_delivered -
>> tp->prr_out,
>
> u32s here? This will likely do bad things with large enough windows.

=46ixed in patch v2.

>
> The rest looks good to me as code, but I don't claim to fully underst=
and the
> algorithm. Perhaps a sysctl to turn it off and a linux mib counter wh=
en
> it triggers would be useful in addition.

There already exists a mib counter when entering Recovery state, so
this will be incremented when PRR is triggered.

Thanks
Nandita
