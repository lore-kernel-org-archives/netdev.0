From: Douglas Leith <Doug.Leith@nuim.ie>
Subject: Re: [RFC] tcp: make H-TCP the default congestion control
Date: Wed, 03 Dec 2008 11:04:54 +0000
Message-ID: <F1D86787-CBC8-435C-A937-ED6A521F8D86@nuim.ie>
References: <0EC70CEA-0C16-411E-9A50-6A0F23EA273F@nuim.ie>
 <2860327B-6E7F-435F-AB4A-36E66A49F7DE@nuim.ie>
 <649aecc70811281528v70876fdo787ee8a707e7e12b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Sangtae Ha <sangtae.ha@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from banyan.nuim.ie ([149.157.1.4]:60920 "EHLO banyan.nuim.ie"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751505AbYLCLEy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2008 06:04:54 -0500
Received: from [10.8.0.6] ([149.157.192.252])
 by mango.nuim.ie (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3
 2007; 32bit)) with ESMTPSA id <0KBA00KK9S43YC00@mango.nuim.ie> for
 netdev@vger.kernel.org; Wed, 03 Dec 2008 11:04:52 +0000 (GMT)
In-reply-to: <649aecc70811281528v70876fdo787ee8a707e7e12b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> The slow convergence of CUBIC had been addressed through CUBIC v2.1
> and CUBIC v2.2 by removing the clamping of CUBIC growth function and
> making CUBIC more aggressive for fast convergence.
> So, I expect you talk about the latest update (CUBICv2.3) which
> integrates a new slow start, called HyStart.
>
> The second parameter of HyStart, which is a delay parameter, is
> designed to respect the existing flows.
> Which means that the later joining flow starts from the congestion
> window where it is believed to be safe not incurring packet losses to
> the existing flows.
> After that, it tries to share the link progressively (not depriving
> all of others bandwidth at once during slow start).
>
My comments related to the current cubic implementation, not the  
proposed new version.   I (not anyone else I don't think) has carried  
out any tests on this new version yet.

That said, even under best case circumstances is not at all clear  
that *any* change in slow start can properly address the slow  
convergence issues in cubic (or other proposals for that matter).   
All it needs is for an early packet loss to lead to an exit from slow  
start and then convergence is back to being determined by congestion  
avoidance behaviour, which remains slow.    Similarly, recovery to  
fairness following a UDP disturbance (or anything else that does not  
cause slow start to kick in) will be determined by the congestion  
avoidance behaviour, and so remain slow.

That is under best case conditions.  If the modified slow start makes  
a mistake (which seems like a reasonable concern since its trying to  
so dome quite fancy stuff based on limited information about the  
network, often early in the flow lifetime) then its not clear what  
the impact on convergence might be even when everything is otherwise  
going our way.
>
--snip-
>
> Could you try your testings with the following changes? We definitely
> will have testings like you mentioned and post the results.
>
Will do.  Got a deadline this week but I'll try to make some time  
next week.

Doug
