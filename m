From: Wenji Wu <wenji@fnal.gov>
Subject: Re: RE: A Linux TCP SACK Question
Date: Mon, 14 Apr 2008 17:07:21 -0500
Message-ID: <fbbd26f52a58.48038f49@fnal.gov>
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
 <000001c89e4a$019f1330$6b5ee183@D2GT6T71>
 <Pine.LNX.4.64.0804141927060.28474@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: 'Netdev' <netdev@vger.kernel.org>
To: =?iso-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.fnal.gov ([131.225.111.11]:37095 "EHLO mailgw1.fnal.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754762AbYDNWOW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 18:14:22 -0400
Received: from mailav1.fnal.gov (mailav1.fnal.gov [131.225.111.18])
 by mailgw1.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with SMTP id <0JZC00LCR5CPTM@mailgw1.fnal.gov> for netdev@vger.kernel.org;
 Mon, 14 Apr 2008 17:07:21 -0500 (CDT)
Received: from mailgw1.fnal.gov ([131.225.111.11])
 by mailav1.fnal.gov (SAVSMTP 3.1.7.47) with SMTP id M2008041417072122589 for
 <netdev@vger.kernel.org>; Mon, 14 Apr 2008 17:07:21 -0500
Received: from conversion-daemon.mailgw1.fnal.gov by mailgw1.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 id <0JZC001014USFF@mailgw1.fnal.gov> (original mail from wenji@fnal.gov)
 for netdev@vger.kernel.org; Mon, 14 Apr 2008 17:07:21 -0500 (CDT)
In-reply-to: <Pine.LNX.4.64.0804141927060.28474@wrl-59.cs.helsinki.fi>
Content-language: en
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Hmm, now there are even less retransmissions (barely some with
> the SACK in the end).
> 
> I suppose the reordering detection is good enough to kill them. ...You 
> 
> could perhaps figure that out from MIBs if you would want to.
> 

Yes, the web100 shows that the tcp_reordering could be as large as 127.

I just rerun the following experimetns to show why there are few retransmissions in my previous posts.

(1) Flush the sytem routing cache by running "ip route flush cache" before running and tcpdumping the traffic
(2) Before running and tcpdumping the traffic, run a data transmission test to generate tcp_reordering in the routing cache.
Do not flush the routing cache. Then running and tcpdumping the traffic.

Both experiments with sack off. 

The results is posted to
https://plone3.fnal.gov/P0/WAN/Members/wenji/adaptive_tcp_reordering/

So, the few retransmissions in my previous post are really caused by the routing cache. 

But flushing cahce has nothing to do with SACK on/off. Still the trhoughput with SACK off is better than that of with SACK on.

wenji
