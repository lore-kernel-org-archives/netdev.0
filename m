From: Wenji Wu <wenji@fnal.gov>
Subject: Re: A Linux TCP SACK Question
Date: Sun, 06 Apr 2008 15:27:57 -0500
Message-ID: <fb8e9e4f102e.47f8ebfd@fnal.gov>
References: <fc471cb97cfd.47f5520e@fnal.gov>
 <1e41a3230804040927j3ce53a84u6a95ec37dff1b5b0@mail.gmail.com>
 <000001c8967c$496efa20$c95ee183@D2GT6T71>
 <Pine.LNX.4.64.0804042253000.415@wrl-59.cs.helsinki.fi>
 <000b01c89699$00e99590$c95ee183@D2GT6T71>
 <Pine.LNX.4.64.0804050031400.8186@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0804050037380.8186@wrl-59.cs.helsinki.fi>
 <000f01c896a1$3022fec0$c95ee183@D2GT6T71>
 <649aecc70804051417l4cf9b30asec8ca8d55e79e051@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: =?iso-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	John Heffner <johnwheffner@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: Sangtae Ha <sangtae.ha@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.fnal.gov ([131.225.111.11]:43674 "EHLO mailgw1.fnal.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753038AbYDFU3u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Apr 2008 16:29:50 -0400
Received: from mailav1.fnal.gov (mailav1.fnal.gov [131.225.111.18])
 by mailgw1.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with SMTP id <0JYX00IWP7IL3B@mailgw1.fnal.gov> for netdev@vger.kernel.org;
 Sun, 06 Apr 2008 15:27:57 -0500 (CDT)
Received: from mailgw1.fnal.gov ([131.225.111.11])
 by mailav1.fnal.gov (SAVSMTP 3.1.7.47) with SMTP id M2008040615275708816 for
 <netdev@vger.kernel.org>; Sun, 06 Apr 2008 15:27:57 -0500
Received: from conversion-daemon.mailgw1.fnal.gov by mailgw1.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 id <0JYX0000178MKB@mailgw1.fnal.gov> (original mail from wenji@fnal.gov)
 for netdev@vger.kernel.org; Sun, 06 Apr 2008 15:27:57 -0500 (CDT)
In-reply-to: <649aecc70804051417l4cf9b30asec8ca8d55e79e051@mail.gmail.com>
Content-language: en
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> Can you run the attached script and run your testing again?
> I think it might be the problem of your dual cores balance the
> interrupts on your testing NIC.
> As we do a lot of things with SACK, cache misses and etc. might affect
> your performance.
> 
> In default setting, I disabled tcp segment offload and did a smp
> affinity setting to CPU 0.
> Please change "INF" to your interface name and let us know the results.

I bound the network interrupts and iperf both the CPU0, and CPU0 will be ilde most of the time. The results are still the same.

At this throughput level, the SACK processing won't take much CPU. 

It is not the interrupt/cpu affinity that cause the difference. 

I am beleving that it is the ACK reordering that cuase the confusion in the sender, which lead the sender uncecessarily to reduce CWND or REORDERING_THRESHOLD.

wenji
