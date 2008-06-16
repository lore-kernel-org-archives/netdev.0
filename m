From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: packetloss, on e1000e worse than r8169?
Date: Tue, 17 Jun 2008 01:08:41 +0300
Message-ID: <20080616220841.M50112@visp.net.lb>
References: <20080616193501.M64730@visp.net.lb> <4856C3A7.9070703@cosmosbay.com> <20080616202210.M84100@visp.net.lb> <4856CEDC.6010706@intel.com> <20080616204411.M52834@visp.net.lb> <4856D1D6.7040207@intel.com> <20080616211213.M76390@visp.net.lb> <4856DB1D.80503@cosmosbay.com> <20080616213419.M212@visp.net.lb> <4856DE1F.4090001@cosmosbay.com> <4856DEA7.9060506@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:37494 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756521AbYFPWMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 18:12:50 -0400
In-Reply-To: <4856DEA7.9060506@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Jun 2008 23:44:07 +0200, Eric Dumazet wrote
> 
> ALso please try to lower the copybreak value of e1000e driver
> (module parameter copybreak=20 for example)
Already tried, but over sysfs

MegaRouter-KARAM ~ # echo 20 > /sys/module/e1000e/parameters/copybreak

Doesn't change anything. I am preparing profiling now.

I dont think it is CPU load issue. I have motherboard DP35DP working on
similar workload(less routes, but conntrack + ifb + htb without hysteresis)
perfectly, but it doesn't have Intel AMT, maybe that's the key.

Why CPU load not the issue? I don't think mpstat is lying. 98-99% CPU is idle.
But i will try oprofile, maybe it can help and will show something.
I will try also PREEMPT kernel now, maybe it is some locking issue, and
preemption can help with that. Because "bursty" and clearly periodic character
of errors means or counters updated each 1-2 seconds or it is something
happening each 1-2 seconds. I am not sure oprofile can catch that.

MegaRouter-KARAM ~ # mpstat 1
Linux 2.6.26-rc6-git2-build-0029 (MegaRouter-KARAM)     06/17/08

00:54:23     CPU   %user   %nice    %sys %iowait    %irq   %soft  %steal  
%idle    intr/s
00:54:24     all    0.51    0.00    0.00    0.00    0.00    1.02    0.00  
98.48  18902.00
00:54:25     all    0.00    0.00    0.00    0.00    0.00    0.51    0.00  
99.49  18735.00
00:54:26     all    0.00    0.00    0.00    0.00    0.00    0.48    0.00  
99.52  19057.00


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

