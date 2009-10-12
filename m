From: Ben Greear <greearb@candelatech.com>
Subject: Re: Link bouncing with multiple drivers.
Date: Mon, 12 Oct 2009 14:08:56 -0700
Message-ID: <4AD39AE8.7000205@candelatech.com>
References: <4AD36DAE.8070908@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:42516 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755875AbZJLVJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 17:09:33 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id n9CL8ucp015892
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 12 Oct 2009 14:08:56 -0700
In-Reply-To: <4AD36DAE.8070908@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/2009 10:55 AM, Ben Greear wrote:
> I have a strange issue:
>
> In several different scenarios, when we run pktgen at line speed
> on 1G through our proprietary bridge-ish module, we see link go
> up and down every minute or so. This happens with e1000, e1000e,
> and have also seen it on ixgbe (though not line speed here...but
> we were driving it as hard as the systems could handle).
>
> We cannot reproduce this when a normal bridge is substituted for
> our proprietary module, so it must either be a bug in our code somewhere,
> or something to do with the fact that our module causes more work to
> be done than a bridge (backed up driver queues on rx/tx, time-stamps, etc).
>
> Since it happens across multiple drivers and hardware (and operating
> systems: F5, F8, F11,
> but all with kernels based on 2.6.31), it must be some general issue.
>
> If anyone has any ideas where I should start poking, I would
> be grateful. For now, I'm off to dig in the e1000e code...

Ahh, it was indeed my bug.  I forgot to update the txqueue trans_start and that
caused the watchdog to fire way too often.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

