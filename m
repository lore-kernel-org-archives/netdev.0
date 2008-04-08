From: Wenji Wu <wenji@fnal.gov>
Subject: Re: RE: A Linux TCP SACK Question
Date: Tue, 08 Apr 2008 05:33:00 -0700
Message-ID: <fbbce0572843.47fb038c@fnal.gov>
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
 <649aecc70804061543v3ca3d0dau2ce303ecd2310bdc@mail.gmail.com>
 <000701c898bf$99fc3f80$c95ee183@D2GT6T71>
 <Pine.LNX.4.64.0804080007020.20936@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: 'Sangtae Ha' <sangtae.ha@gmail.com>,
	'John Heffner' <johnwheffner@gmail.com>,
	'Netdev' <netdev@vger.kernel.org>
To: =?iso-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.fnal.gov ([131.225.111.11]:60061 "EHLO mailgw1.fnal.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751778AbYDHMdH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2008 08:33:07 -0400
Received: from mailav2.fnal.gov (mailav2.fnal.gov [131.225.111.20])
 by mailgw1.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with SMTP id <0JZ000LZ3AV0XV@mailgw1.fnal.gov> for netdev@vger.kernel.org;
 Tue, 08 Apr 2008 07:33:01 -0500 (CDT)
Received: from mailgw2.fnal.gov ([131.225.111.12])
 by mailav2.fnal.gov (SAVSMTP 3.1.7.47) with SMTP id M2008040807330025777 for
 <netdev@vger.kernel.org>; Tue, 08 Apr 2008 07:33:00 -0500
Received: from conversion-daemon.mailgw2.fnal.gov by mailgw2.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 id <0JZ0003019YKHD@mailgw2.fnal.gov> (original mail from wenji@fnal.gov)
 for netdev@vger.kernel.org; Tue, 08 Apr 2008 07:33:00 -0500 (CDT)
In-reply-to: <Pine.LNX.4.64.0804080007020.20936@wrl-59.cs.helsinki.fi>
Content-language: en
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> NewReno never retransmitted anything in them (except at the very end 
> of 
> the transfer). Probably something related to how tp->reordering behaves
> I suppose...

Yes, the adaptive tp->reordering will play a role here. 

> This is probably far fetched but could you tell us how you make sure 
> that 
> earlier connection's metrics are not affecting the latter connection? 
> 
> Ie., the discovered reordering is not transferred across the flows (in 
> CBI 
> like manner) and thus newreno has unfair advantage?

You can reverse the order of the tests, with SACK option on/off. The results are still the same.

Also, according to the source code, tp->reordering will be initialized to "/proc/sys/net/ipv4/tcp_reordering" (default 3), when the new connection is established. After that, tp->reordering is controlled by the the adaptive algorithm

wenji






