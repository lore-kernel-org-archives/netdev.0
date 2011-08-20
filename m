From: Nandita Dukkipati <nanditad@google.com>
Subject: Re: [PATCH v2] Proportional Rate Reduction for TCP.
Date: Fri, 19 Aug 2011 18:28:58 -0700
Message-ID: <CAB_+Fg4z46iLv29jX6dXK6GSBbnPxWroq99V6Yr25vpCYrJBqw@mail.gmail.com>
References: <1313134197-5082-1-git-send-email-nanditad@google.com>
	<1313739212-2315-1-git-send-email-nanditad@google.com>
	<alpine.DEB.2.00.1108191312170.12780@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:25762 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142Ab1HTB3H convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 21:29:07 -0400
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p7K1T1el004649
	for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 18:29:01 -0700
Received: from ywf7 (ywf7.prod.google.com [10.192.6.7])
	by hpaq5.eem.corp.google.com with ESMTP id p7K1SxBp023958
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 18:29:00 -0700
Received: by ywf7 with SMTP id 7so3295481ywf.33
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 18:28:59 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1108191312170.12780@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46orgot to turn off gmail's rich formatting, so re-sending to the list=
=2E

On Fri, Aug 19, 2011 at 3:25 AM, Ilpo J=E4rvinen
<ilpo.jarvinen@helsinki.fi> wrote:
>
> On Fri, 19 Aug 2011, Nandita Dukkipati wrote:
>
> > +static void tcp_update_cwnd_in_recovery(struct sock *sk, int newly=
_acked_sacked,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 int fast_rexmit, int flag)
> > +{
> > + =A0 =A0 struct tcp_sock *tp =3D tcp_sk(sk);
> > + =A0 =A0 int sndcnt =3D 0;
> > + =A0 =A0 int delta =3D tp->snd_ssthresh - tcp_packets_in_flight(tp=
);
> > +
> > + =A0 =A0 if (tcp_packets_in_flight(tp) > tp->snd_ssthresh) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 if (WARN_ON(!tp->prior_cwnd))
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->prior_cwnd =3D 1;
>
> This should still be made larger to avoid problems if it ever will be
> needed.

I am letting the value remain at 1, mainly because this is the valid
lowest non-zero value for snd_cwnd to take on. The main purpose of
this code is to catch any lurking bug outside of PRR which results in
an undesirable divide by 0 in PRR. I would like to fix that bug if I
find this code is executed.

>
> > + =A0 =A0 =A0 =A0 =A0 =A0 sndcnt =3D DIV_ROUND_UP((u64)(tp->prr_del=
ivered *
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 tp->snd_ssthresh),
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 (u64)tp->prior_cwnd) - tp->prr_out;
>
> I think you should pick one from include/linux/math64.h instead of le=
tting
> gcc to do / operand all by itself. ...Obviosly then the ROUND_UP part
> needs to be done manually (either using the remainder or pre-addition
> like DIV_ROUND_UP does).

Done. patch v3 used div_u64.

Thanks
Nandita
