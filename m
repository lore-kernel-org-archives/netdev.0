From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: RE: A Linux TCP SACK Question
Date: Tue, 15 Apr 2008 10:01:25 -0700
Message-ID: <1e41a3230804151001gc9fa670p511b16bb01e0bc93@mail.gmail.com>
References: <fc471cb97cfd.47f5520e@fnal.gov>
	 <000701c898bf$99fc3f80$c95ee183@D2GT6T71>
	 <Pine.LNX.4.64.0804080007020.20936@wrl-59.cs.helsinki.fi>
	 <fbbce0572843.47fb038c@fnal.gov>
	 <Pine.LNX.4.64.0804081623500.21784@wrl-59.cs.helsinki.fi>
	 <fba201de4228.47fb3b26@fnal.gov>
	 <Pine.LNX.4.64.0804081742270.21784@wrl-59.cs.helsinki.fi>
	 <000301c89e81$80124570$6b5ee183@D2GT6T71>
	 <1e41a3230804141748v2bf1f32bsc80307c9390c222@mail.gmail.com>
	 <fcb2d79550b4.480493e2@fnal.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>
To: "Wenji Wu" <wenji@fnal.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.176]:34163 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755043AbYDORB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 13:01:27 -0400
Received: by el-out-1112.google.com with SMTP id n30so250986elf.21
        for <netdev@vger.kernel.org>; Tue, 15 Apr 2008 10:01:26 -0700 (PDT)
In-Reply-To: <fcb2d79550b4.480493e2@fnal.gov>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 15, 2008 at 9:39 AM, Wenji Wu <wenji@fnal.gov> wrote:
>  SlowStart            0
>  CongAvoid            0
>  CongestionSignals    3
>  OtherReductions      13166
>  X_OtherReductionsCV  0
>  X_OtherReductionsCM  13166
>  CongestionOverCount  37
>  CurCwnd              10136
>
> MaxCwnd              173760
>  CurSsthresh          94894680
>  LimCwnd              4294965848
>  MaxSsthresh          94894680
>  MinSsthresh          46336


We can see that in both cases you are getting throttled by
tcp_moderate_cwnd (X_OtherReductionsCM).  I'm not sure offhand why
it's reaching this code - I would have thought that the high
tp->reordering would prevent this.  Ilpo, do you have any insights?

It's not all that surprising that packets_in_flight is a higher value
with newreno than sack, which would explain the higher window with
newreno.

Wenji, the web100 kernel has a sysctl - WAD_MaxBurst.  I suspect it
may make a significant difference if you set this to a large value.

  -John
