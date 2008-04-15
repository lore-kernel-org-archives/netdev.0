From: Matt Mathis <mathis@psc.edu>
Subject: Re: RE: A Linux TCP SACK Question
Date: Tue, 15 Apr 2008 14:00:06 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0804151340580.31800@tesla.psc.edu>
References: <fc471cb97cfd.47f5520e@fnal.gov> <fbbce0572843.47fb038c@fnal.gov>
  <Pine.LNX.4.64.0804081623500.21784@wrl-59.cs.helsinki.fi>
 <fba201de4228.47fb3b26@fnal.gov>  <Pine.LNX.4.64.0804081742270.21784@wrl-59.cs.helsinki.fi>
  <000301c89e81$80124570$6b5ee183@D2GT6T71>  <1e41a3230804141748v2bf1f32bsc80307c9390c222@mail.gmail.com>
  <fcb2d79550b4.480493e2@fnal.gov>  <1e41a3230804151001gc9fa670p511b16bb01e0bc93@mail.gmail.com>
  <Pine.LNX.4.64.0804152005110.27927@wrl-59.cs.helsinki.fi>
 <1e41a3230804151023s1658a83dye0a2e91d7a98c34@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1233065670-1527586771-1208281875=:31800"
Cc: John Heffner <johnwheffner@gmail.com>, Wenji Wu <wenji@fnal.gov>,
	Netdev <netdev@vger.kernel.org>
To: =?X-UNKNOWN?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:57526 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752179AbYDOSPI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 14:15:08 -0400
In-Reply-To: <1e41a3230804151023s1658a83dye0a2e91d7a98c34@mail.gmail.com>
Content-ID: <Pine.LNX.4.64.0804151352210.31800@tesla.psc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1233065670-1527586771-1208281875=:31800
Content-Type: TEXT/PLAIN; CHARSET=X-UNKNOWN; FORMAT=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <Pine.LNX.4.64.0804151352211.31800@tesla.psc.edu>

In some future kernel release, I would consider changing it to limit cwnd t=
o=20
be less than packets_in_flight() + reorder + 3(?).  If the network is=20
reordering packets, then it has to accept bursts, otherwise TCP can never o=
pen=20
the window.  The +3 (or some other constant) is still needed because TCP ha=
s=20
to send extra packets at the point where the window changes.

As an alternative, you could write a research paper on how the network coul=
d=20
do LIFO packet scheduling so the reordering serves as a congestion signal t=
o=20
the stacks.  I bet it would have some really interesting properties.  Oh wa=
it,=20
April 1st was 2 weeks ago.

Thanks,
--MM--

On Tue, 15 Apr 2008, John Heffner wrote:

> On Tue, Apr 15, 2008 at 10:08 AM, Ilpo J=E4rvinen
> <ilpo.jarvinen@helsinki.fi> wrote:
>> On Tue, 15 Apr 2008, John Heffner wrote:
>> > We can see that in both cases you are getting throttled by
>> > tcp_moderate_cwnd (X_OtherReductionsCM).  I'm not sure offhand why
>> > it's reaching this code - I would have thought that the high
>> > tp->reordering would prevent this.  Ilpo, do you have any insights?
>>
>>  What makes you think so? It's called from tcp_try_to_open as anyone can
>>  read from the source, basically when our state is CA_Disorder (some ver=
y
>>  small portion might happen in ca_recovery besides that).
>
> This is what X_OtherReductionsCM instruments, and that was the only
> thing holding back cwnd.
>
> I just looked at the source, and indeed it will be called on every ack
> when we are in the disorder state.  Limiting cwnd to
> packets_in_flight() + 3 here is going to prevent cwnd from growing
> when the reordering is greater than 3.  Making max_burst at least
> tp->reordering should help some, though I'm not sure it's the right
> thing to do.
>
>  -John
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
---1233065670-1527586771-1208281875=:31800--
