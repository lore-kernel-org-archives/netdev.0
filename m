From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp: randomize TCP source ports
Date: Thu, 07 Nov 2013 18:04:54 -0800
Message-ID: <1383876294.9412.136.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383872049.9412.124.camel@edumazet-glaptop2.roam.corp.google.com>
	 <527C3942.509@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:33124 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752511Ab3KHCE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 21:04:57 -0500
Received: by mail-pd0-f170.google.com with SMTP id v10so1463369pde.29
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 18:04:57 -0800 (PST)
In-Reply-To: <527C3942.509@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-07 at 17:07 -0800, Rick Jones wrote:

> For perhaps most definitions of well deployed.  There is at least one 
> load balancer which, while it offers TCP Window Scaling, does not also 
> offer TCP Time Stamps...
> 
> By rights they should (must) be offering TCP Time Stamps, and they are, 
> I am told, "working on it."
> 
> Is all going to be "well" when it is the (non-Linux) remote system which 
> has the TIME_WAIT endpoint?

Hey, tell us why netperf does a bind(port=0, addr=ANY) and SO_REUSEADDR
tricks before connect()

It seems you do request randomization, but you do not want it for
applications written by innocent people...

Current implementation is lazy at best, as a single @hint variable is
shared for all cpus, all users, so at moderate load there is actually no
guarantee of sequential allocations.

RFC 6056 has an interesting list of alternatives
