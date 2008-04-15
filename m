From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: RE: A Linux TCP SACK Question
Date: Tue, 15 Apr 2008 10:23:56 -0700
Message-ID: <1e41a3230804151023s1658a83dye0a2e91d7a98c34@mail.gmail.com>
References: <fc471cb97cfd.47f5520e@fnal.gov> <fbbce0572843.47fb038c@fnal.gov>
	 <Pine.LNX.4.64.0804081623500.21784@wrl-59.cs.helsinki.fi>
	 <fba201de4228.47fb3b26@fnal.gov>
	 <Pine.LNX.4.64.0804081742270.21784@wrl-59.cs.helsinki.fi>
	 <000301c89e81$80124570$6b5ee183@D2GT6T71>
	 <1e41a3230804141748v2bf1f32bsc80307c9390c222@mail.gmail.com>
	 <fcb2d79550b4.480493e2@fnal.gov>
	 <1e41a3230804151001gc9fa670p511b16bb01e0bc93@mail.gmail.com>
	 <Pine.LNX.4.64.0804152005110.27927@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Wenji Wu" <wenji@fnal.gov>, Netdev <netdev@vger.kernel.org>
To: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.176]:64176 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755987AbYDORYA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 13:24:00 -0400
Received: by el-out-1112.google.com with SMTP id n30so259105elf.21
        for <netdev@vger.kernel.org>; Tue, 15 Apr 2008 10:23:57 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0804152005110.27927@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 15, 2008 at 10:08 AM, Ilpo J=E4rvinen
<ilpo.jarvinen@helsinki.fi> wrote:
> On Tue, 15 Apr 2008, John Heffner wrote:
>  > We can see that in both cases you are getting throttled by
>  > tcp_moderate_cwnd (X_OtherReductionsCM).  I'm not sure offhand why
>  > it's reaching this code - I would have thought that the high
>  > tp->reordering would prevent this.  Ilpo, do you have any insights=
?
>
>  What makes you think so? It's called from tcp_try_to_open as anyone =
can
>  read from the source, basically when our state is CA_Disorder (some =
very
>  small portion might happen in ca_recovery besides that).

This is what X_OtherReductionsCM instruments, and that was the only
thing holding back cwnd.

I just looked at the source, and indeed it will be called on every ack
when we are in the disorder state.  Limiting cwnd to
packets_in_flight() + 3 here is going to prevent cwnd from growing
when the reordering is greater than 3.  Making max_burst at least
tp->reordering should help some, though I'm not sure it's the right
thing to do.

  -John
