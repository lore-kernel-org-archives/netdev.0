From: "Sangtae Ha" <sangtae.ha@gmail.com>
Subject: Re: A Linux TCP SACK Question
Date: Sun, 6 Apr 2008 18:43:02 -0400
Message-ID: <649aecc70804061543v3ca3d0dau2ce303ecd2310bdc@mail.gmail.com>
References: <fc471cb97cfd.47f5520e@fnal.gov>
	 <1e41a3230804040927j3ce53a84u6a95ec37dff1b5b0@mail.gmail.com>
	 <000001c8967c$496efa20$c95ee183@D2GT6T71>
	 <Pine.LNX.4.64.0804042253000.415@wrl-59.cs.helsinki.fi>
	 <000b01c89699$00e99590$c95ee183@D2GT6T71>
	 <Pine.LNX.4.64.0804050031400.8186@wrl-59.cs.helsinki.fi>
	 <Pine.LNX.4.64.0804050037380.8186@wrl-59.cs.helsinki.fi>
	 <000f01c896a1$3022fec0$c95ee183@D2GT6T71>
	 <649aecc70804051417l4cf9b30asec8ca8d55e79e051@mail.gmail.com>
	 <fb8e9e4f102e.47f8ebfd@fnal.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	"John Heffner" <johnwheffner@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: "Wenji Wu" <wenji@fnal.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:56776 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539AbYDFWnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Apr 2008 18:43:03 -0400
Received: by yw-out-2324.google.com with SMTP id 5so180866ywb.1
        for <netdev@vger.kernel.org>; Sun, 06 Apr 2008 15:43:02 -0700 (PDT)
In-Reply-To: <fb8e9e4f102e.47f8ebfd@fnal.gov>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When our 40 students had the same lab experiment comparing between
TCP-SACK and TCP-NewReno, they had come up with similar results. The
settings are identical to your setting (one linux sender, one linux
receiver, and one nettem machine in between) . When we introduced some
loss using a nettem, TCP-SACK showed a bit better performance while
they had similar throughput most of cases.

I don't think reorderings frequently happened in your directly
connected networking scenario. Please post your tcpdump file for
clearing out all doubts.

Sangtae

On 4/6/08, Wenji Wu <wenji@fnal.gov> wrote:
>
>
> > Can you run the attached script and run your testing again?
> > I think it might be the problem of your dual cores balance the
> > interrupts on your testing NIC.
> > As we do a lot of things with SACK, cache misses and etc. might affect
> > your performance.
> >
> > In default setting, I disabled tcp segment offload and did a smp
> > affinity setting to CPU 0.
> > Please change "INF" to your interface name and let us know the results.
>
> I bound the network interrupts and iperf both the CPU0, and CPU0 will be ilde most of the time. The results are still the same.
>
> At this throughput level, the SACK processing won't take much CPU.
>
> It is not the interrupt/cpu affinity that cause the difference.
>
> I am beleving that it is the ACK reordering that cuase the confusion in the sender, which lead the sender uncecessarily to reduce CWND or REORDERING_THRESHOLD.
>
> wenji
>


-- 
----------------------------------------------------------------
 Sangtae Ha, http://www4.ncsu.edu/~sha2
 PhD. Student,
 Department of Computer Science,
 North Carolina State University, USA
----------------------------------------------------------------
