From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: RE: A Linux TCP SACK Question
Date: Tue, 8 Apr 2008 08:57:27 -0700
Message-ID: <1e41a3230804080857w12d4cc1dkc6b52e51e3335a3d@mail.gmail.com>
References: <fc471cb97cfd.47f5520e@fnal.gov>
	 <Pine.LNX.4.64.0804050031400.8186@wrl-59.cs.helsinki.fi>
	 <Pine.LNX.4.64.0804050037380.8186@wrl-59.cs.helsinki.fi>
	 <000f01c896a1$3022fec0$c95ee183@D2GT6T71>
	 <649aecc70804051417l4cf9b30asec8ca8d55e79e051@mail.gmail.com>
	 <fb8e9e4f102e.47f8ebfd@fnal.gov>
	 <649aecc70804061543v3ca3d0dau2ce303ecd2310bdc@mail.gmail.com>
	 <000701c898bf$99fc3f80$c95ee183@D2GT6T71>
	 <Pine.LNX.4.64.0804080007020.20936@wrl-59.cs.helsinki.fi>
	 <fbbce0572843.47fb038c@fnal.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	"Sangtae Ha" <sangtae.ha@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: "Wenji Wu" <wenji@fnal.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:14865 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755531AbYDHP5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 11:57:36 -0400
Received: by yw-out-2324.google.com with SMTP id 5so370417ywb.1
        for <netdev@vger.kernel.org>; Tue, 08 Apr 2008 08:57:28 -0700 (PDT)
In-Reply-To: <fbbce0572843.47fb038c@fnal.gov>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 8, 2008 at 5:33 AM, Wenji Wu <wenji@fnal.gov> wrote:
> > NewReno never retransmitted anything in them (except at the very end
>  > of
>  > the transfer). Probably something related to how tp->reordering behaves
>  > I suppose...
>
>  Yes, the adaptive tp->reordering will play a role here.

I remember several years ago when I first looked at chronic reordering
with a high BDP, the problem I had was that:
1) Only acks of new data can advance cwnd, and these only advance by
the normal amount per ack, so cwnd grows very slowly.
2) Reordering caused slow start to exit early, before the reordering
threshold had adapted
3) The "undo" code didn't work well because of cwnd moderation
4) There were bugs in the reordering calculation that caused the
threshold to be pulled back

Some of these shouldn't matter to you because your rtt is low, but I
thought i would be worth mentioning.  I'm not sure what is keeping
your cwnd from growing -- it always seems to be within a small range
in both cases, which is not right unless there's a bottleneck at the
sender.  The fact reno does a little better than sack seems like the
less important problem.

Also, what's the behavior when turning off reordering, in each or both
directions?

  -John
