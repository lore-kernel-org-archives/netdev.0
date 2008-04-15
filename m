From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: RE: A Linux TCP SACK Question
Date: Tue, 15 Apr 2008 11:23:28 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804151114240.17123@wrl-59.cs.helsinki.fi>
References: <fc471cb97cfd.47f5520e@fnal.gov>
 <1e41a3230804040927j3ce53a84u6a95ec37dff1b5b0@mail.gmail.com>
 <000001c8967c$496efa20$c95ee183@D2GT6T71> <Pine.LNX.4.64.0804042253000.415@wrl-59.cs.helsinki.fi>
 <000b01c89699$00e99590$c95ee183@D2GT6T71> <Pine.LNX.4.64.0804050031400.8186@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0804050037380.8186@wrl-59.cs.helsinki.fi>
 <000f01c896a1$3022fec0$c95ee183@D2GT6T71> <649aecc70804051417l4cf9b30asec8ca8d55e79e051@mail.gmail.com>
 <fb8e9e4f102e.47f8ebfd@fnal.gov> <649aecc70804061543v3ca3d0dau2ce303ecd2310bdc@mail.gmail.com>
 <000701c898bf$99fc3f80$c95ee183@D2GT6T71> <Pine.LNX.4.64.0804080007020.20936@wrl-59.cs.helsinki.fi>
 <000001c89e4a$019f1330$6b5ee183@D2GT6T71> <Pine.LNX.4.64.0804141927060.28474@wrl-59.cs.helsinki.fi>
 <fbbd26f52a58.48038f49@fnal.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'Netdev' <netdev@vger.kernel.org>
To: Wenji Wu <wenji@fnal.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37053 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754222AbYDOIXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 04:23:32 -0400
In-Reply-To: <fbbd26f52a58.48038f49@fnal.gov>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Apr 2008, Wenji Wu wrote:

> 
> > Hmm, now there are even less retransmissions (barely some with
> > the SACK in the end).
> > 
> > I suppose the reordering detection is good enough to kill them. ...You 
> > 
> > could perhaps figure that out from MIBs if you would want to.
> > 
> 
> Yes, the web100 shows that the tcp_reordering could be as large as 127.

It should get large, though I suspect newreno's new value: tp->packets_out 
+ addend might have tp->packets_out too much.

> I just rerun the following experimetns to show why there are few 
> retransmissions in my previous posts.
> 
> (1) Flush the sytem routing cache by running "ip route flush cache" 
> before running and tcpdumping the traffic

I didn't know that works, tcp_no_metrics_save sysctl seems to prevent 
saving them from an running TCP flow when a flow ends.

> (2) Before running and tcpdumping the traffic, run a data transmission 
> test to generate tcp_reordering in the routing cache. Do not flush the 
> routing cache. Then running and tcpdumping the traffic.
> 
> Both experiments with sack off. 
> 
> The results is posted to
> https://plone3.fnal.gov/P0/WAN/Members/wenji/adaptive_tcp_reordering/
> 
> So, the few retransmissions in my previous post are really caused by the 
> routing cache. 

Yes. Remember however that initial metrics has also have effect on initial 
ssthresh, so one must be very careful to not cause unfairness through them 
if metrics are not cleared.

> But flushing cahce has nothing to do with SACK on/off. Still the 
> trhoughput with SACK off is better than that of with SACK on.

Yes, I think it alone would never explain it. Though difference in 
initial ssthresh might have been the explanation for the different level 
where outstanding data settled with the logs without any retransmissions.

-- 
 i.
