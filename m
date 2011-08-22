From: Nandita Dukkipati <nanditad@google.com>
Subject: Re: [PATCH v2] Proportional Rate Reduction for TCP.
Date: Sun, 21 Aug 2011 23:21:34 -0700
Message-ID: <CAB_+Fg68ZcU0ja30iOBZjJNcJA8C6onfZThaR4JOw0q9KD9HPQ@mail.gmail.com>
References: <1313134197-5082-1-git-send-email-nanditad@google.com>
	<1313739212-2315-1-git-send-email-nanditad@google.com>
	<alpine.DEB.2.00.1108191312170.12780@wel-95.cs.helsinki.fi>
	<CAB_+Fg4z46iLv29jX6dXK6GSBbnPxWroq99V6Yr25vpCYrJBqw@mail.gmail.com>
	<alpine.DEB.2.00.1108201534590.24318@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:28576 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752481Ab1HVGVh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 02:21:37 -0400
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p7M6LZWD011187
	for <netdev@vger.kernel.org>; Sun, 21 Aug 2011 23:21:36 -0700
Received: from gxk3 (gxk3.prod.google.com [10.202.11.3])
	by wpaz37.hot.corp.google.com with ESMTP id p7M6LYhL001117
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 21 Aug 2011 23:21:34 -0700
Received: by gxk3 with SMTP id 3so292656gxk.6
        for <netdev@vger.kernel.org>; Sun, 21 Aug 2011 23:21:34 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1108201534590.24318@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 20, 2011 at 5:41 AM, Ilpo J=E4rvinen
<ilpo.jarvinen@helsinki.fi> wrote:
> On Fri, 19 Aug 2011, Nandita Dukkipati wrote:
>
>> Forgot to turn off gmail's rich formatting, so re-sending to the lis=
t.
>>
>> On Fri, Aug 19, 2011 at 3:25 AM, Ilpo J=E4rvinen
>> <ilpo.jarvinen@helsinki.fi> wrote:
>> >
>> > On Fri, 19 Aug 2011, Nandita Dukkipati wrote:
>> >
>> > > +static void tcp_update_cwnd_in_recovery(struct sock *sk, int ne=
wly_acked_sacked,
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 int fast_rexmit, int flag)
>> > > +{
>> > > + =A0 =A0 struct tcp_sock *tp =3D tcp_sk(sk);
>> > > + =A0 =A0 int sndcnt =3D 0;
>> > > + =A0 =A0 int delta =3D tp->snd_ssthresh - tcp_packets_in_flight=
(tp);
>> > > +
>> > > + =A0 =A0 if (tcp_packets_in_flight(tp) > tp->snd_ssthresh) {
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 if (WARN_ON(!tp->prior_cwnd))
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->prior_cwnd =3D 1;
>> >
>> > This should still be made larger to avoid problems if it ever will=
 be
>> > needed.
>>
>> I am letting the value remain at 1, mainly because this is the valid
>> lowest non-zero value for snd_cwnd to take on. The main purpose of
>> this code is to catch any lurking bug outside of PRR which results i=
n
>> an undesirable divide by 0 in PRR. I would like to fix that bug if I
>> find this code is executed.
>
> NACK, until this value is at least 2 * tp->snd_ssthresh. Or alternati=
vely
> the fallback is removed so that we DBZ and do not end up wrecking the
> network.

If prior_cwnd is suspect at this point, snd_ssthresh cannot be trusted =
either.
So it appears to me that it's best to remove the fallback and spare
the network.
Done in patch v4.

Nandita

>
> Other than that I'm ok with the patch (assuming the branches I brough=
t
> up earlier is ok for everybody else).
>
>
> --
> =A0i.
