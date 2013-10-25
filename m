From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Big performance loss from 3.4.63 to 3.10.13 when routing ipv4
Date: Fri, 25 Oct 2013 01:50:28 -0700
Message-ID: <1382691028.7572.78.camel@edumazet-glaptop.roam.corp.google.com>
References: <3244031.uQGDddGTLF@h2o.as.studentenwerk.mhn.de>
	 <3169911.kTmZ0BZVVr@h2o.as.studentenwerk.mhn.de>
	 <1382547992.7572.31.camel@edumazet-glaptop.roam.corp.google.com>
	 <5743349.5WGxWa1M1u@ei.h3.stusta.mhn.de>
	 <20131025080158.GC31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Walter <linux@stwm.de>,
	David Miller <davem@davemloft.net>, hannes@stressinduktion.org,
	netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:55955 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751855Ab3JYIud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 04:50:33 -0400
Received: by mail-ee0-f50.google.com with SMTP id l10so1750499eei.9
        for <netdev@vger.kernel.org>; Fri, 25 Oct 2013 01:50:32 -0700 (PDT)
In-Reply-To: <20131025080158.GC31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-25 at 10:01 +0200, Steffen Klassert wrote:

> We currently start the garbage collector if we have more than gc_thresh
> (1024) dst entries allocated and refuse new allocations at 2 * gc_thresh.
> 
> So maybe we should set gc_thresh to 32768. Than we can have 65536 dst
> entries in the system (cache + packets in flight) before we refuse
> new allocations. In paticular we can still cache another 32768 dst
> entries after the garbage collector was started. It looks like you
> had never more than 15000 dst entries cached, so a default of 32768
> looks reasonable and should also keep smaller embedded routers happy.


32768 as the default seems fine to me

448 bytes per dst -> thats less than 30 Mbytes of memory if we hit 65536
dst.
