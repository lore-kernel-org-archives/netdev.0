From: Wenji Wu <wenji@fnal.gov>
Subject: RE: about Linux adaptivly adjusting dupthresh
Date: Thu, 28 Aug 2008 14:30:40 -0500
Message-ID: <000001c90944$8edb4290$a05ee183@D2GT6T71>
References: <1e41a3230804151540i1f7cee4dva6adc6ef25dae546@mail.gmail.com>
 <20080416.012732.152357000.davem@davemloft.net>
 <Pine.LNX.4.64.0804161203590.17123@wrl-59.cs.helsinki.fi>
 <20080416.023551.70464279.davem@davemloft.net>
 <000001c90852$a1c19a50$a05ee183@D2GT6T71>
 <1e41a3230808271548w15164eadt1042f37bf2df7e6f@mail.gmail.com>
 <fb62ce3717a7.48b5b0a8@fnal.gov>
 <Pine.LNX.4.64.0808280928450.5170@wrl-59.cs.helsinki.fi>
 <001101c90919$313d67b0$a05ee183@D2GT6T71>
 <Pine.LNX.4.64.0808282135350.7618@wrl-59.cs.helsinki.fi>
Reply-To: wenji@fnal.gov
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: 'John Heffner' <johnwheffner@gmail.com>,
	'David Miller' <davem@davemloft.net>,
	'Netdev' <netdev@vger.kernel.org>
To: =?iso-8859-1?Q?'Ilpo_J=E4rvinen'?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.fnal.gov ([131.225.111.11]:33605 "EHLO mailgw1.fnal.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753427AbYH1Tar convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 15:30:47 -0400
Received: from mailav2.fnal.gov (mailav2.fnal.gov [131.225.111.20])
 by mailgw1.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with SMTP id <0K6B008MMR9F6T@mailgw1.fnal.gov> for netdev@vger.kernel.org;
 Thu, 28 Aug 2008 14:30:47 -0500 (CDT)
Received: from mailgw2.fnal.gov ([131.225.111.12])
 by mailav2.fnal.gov (SAVSMTP 3.1.7.47) with SMTP id M2008082814304624545 for
 <netdev@vger.kernel.org>; Thu, 28 Aug 2008 14:30:46 -0500
Received: from conversion-daemon.mailgw2.fnal.gov by mailgw2.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 id <0K6B00C01SPXG8@mailgw2.fnal.gov> (original mail from wenji@fnal.gov)
 for netdev@vger.kernel.org; Thu, 28 Aug 2008 14:30:47 -0500 (CDT)
In-reply-to: <Pine.LNX.4.64.0808282135350.7618@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks,

-----Original Message-----
=46rom: Ilpo J=E4rvinen [mailto:ilpo.jarvinen@helsinki.fi]=20
Sent: Thursday, August 28, 2008 1:53 PM
To: Wenji Wu
Cc: 'John Heffner'; 'David Miller'; 'Netdev'
Subject: Re: about Linux adaptivly adjusting dupthresh

On Thu, 28 Aug 2008, Wenji Wu wrote:

> Sorry, I made a mistake in the last post, what I mean is "algorithms
> adaptively adjust TCP reordering threshold dupthresh".=20

Ah, that makes much more sense. :-)

> I understand that "Eifel algorithm" or "DSACK TCP" will adaptively ad=
just
> dupthresh to deal with packet reordering. Are there any other
> reordering-tolerant algorithms implemented in Linux?=20

=46irst about adaptive dupthresh:

In addition to DSACK, we use never-retransmitted block's cumulative ACK=
s=20
to increase the dupthresh (see tcp_clean_rtx_queue). Then there's some=20
newreno thing when dupacks > packets_out but I've never really figured =
it=20
fully out if that's doing the correct thing when doing + tp->packets_ou=
t=20
besides the most simple case (see tcp_check_reno_reordering).

I don't think that eifel adjusts dupthresh though it can remove ambigui=
ty=20
problem and thus we can use the never-retransmitted block acked detecti=
on=20
more often.

Also, there's some added logic for small-windowed case to reduce dupthr=
esh=20
temporarily (at the smallest to 3 or whatever the default is) if window=
 is=20
not large enough to generate the incremented (see tcp_time_to_recover).


Again, I'm not too sure what you mean by "reordering tolerant", but her=
e=20
are some things that may be related:

=46ACK -> RFC3517 auto-fallback if reordering is detected (basically ho=
les=20
are only counted with FACK in the more-than-dupthresh check).

I guess Eifel like timestamp checking belongs to this category (in=20
tcp_try_undo_partial).

If latency spike + reordering occurs, SACK FRTO might help but I think
it depends on scenario.

--=20
 i.


