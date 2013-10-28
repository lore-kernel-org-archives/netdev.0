From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Big performance loss from 3.4.63 to 3.10.13 when routing ipv4
Date: Sun, 27 Oct 2013 23:17:31 -0700
Message-ID: <1382941051.13037.13.camel@edumazet-glaptop.roam.corp.google.com>
References: <3244031.uQGDddGTLF@h2o.as.studentenwerk.mhn.de>
	 <3169911.kTmZ0BZVVr@h2o.as.studentenwerk.mhn.de>
	 <1382547992.7572.31.camel@edumazet-glaptop.roam.corp.google.com>
	 <5743349.5WGxWa1M1u@ei.h3.stusta.mhn.de>
	 <20131025080158.GC31491@secunet.com>
	 <1382691028.7572.78.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131025092043.GD31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Walter <linux@stwm.de>,
	David Miller <davem@davemloft.net>, hannes@stressinduktion.org,
	netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:58982 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751737Ab3J1GRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 02:17:32 -0400
Received: by mail-pd0-f177.google.com with SMTP id p10so6561128pdj.36
        for <netdev@vger.kernel.org>; Sun, 27 Oct 2013 23:17:32 -0700 (PDT)
In-Reply-To: <20131025092043.GD31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-25 at 11:20 +0200, Steffen Klassert wrote:
> On Fri, Oct 25, 2013 at 01:50:28AM -0700, Eric Dumazet wrote:
> > 
> > 32768 as the default seems fine to me
> > 
> > 448 bytes per dst -> thats less than 30 Mbytes of memory if we hit 65536
> > dst.
> > 
> 
> Ok, I'll add the patch below to to the ipsec tree if everyone is fine
> with that threshold.
> 
> Subject: [PATCH RFC] xfrm: Increase the garbage collector threshold
> 
> With the removal of the routing cache, we lost the
> option to tweak the garbage collector threshold
> along with the maximum routing cache size. So git
> commit 703fb94ec ("xfrm: Fix the gc threshold value
> for ipv4") moved back to a static threshold.
> 
> It turned out that the current threshold before we
> start garbage collecting is much to small for some
> workloads, so increase it from 1024 to 32768. This
> means that we start the garbage collector if we have
> more than 32768 dst entries in the system and refuse
> new allocations if we are above 65536.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---

Sure please add :

Reported-by: Wolfgang Walter <linux@stwm.de>

Thanks !
