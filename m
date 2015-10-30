From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch] tcp: attach SYNACK messages to request sockets instead
 of listener
Date: Fri, 30 Oct 2015 16:52:22 -0700
Message-ID: <1446249142.6254.47.camel@edumazet-glaptop2.roam.corp.google.com>
References: <BN1PR0301MB07704A8D81E0AD6A358D6D53CA200@BN1PR0301MB0770.namprd03.prod.outlook.com>
	 <1446159521.6254.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <BN1PR0301MB0770DDDA95027A39BF078CE6CA2F0@BN1PR0301MB0770.namprd03.prod.outlook.com>
	 <1446235356.6254.33.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1446236331.6254.36.camel@edumazet-glaptop2.roam.corp.google.com>
	 <BN1PR0301MB07705F68B22ED84061E37337CA2F0@BN1PR0301MB0770.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "edumazet@google.com" <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33156 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752870AbbJ3XwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 19:52:25 -0400
Received: by padhy1 with SMTP id hy1so81399514pad.0
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2015 16:52:24 -0700 (PDT)
In-Reply-To: <BN1PR0301MB07705F68B22ED84061E37337CA2F0@BN1PR0301MB0770.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-10-30 at 21:42 +0000, Haiyang Zhang wrote:
> 

> 
> With your 2nd patch, I saw:
> [   19.242104] Wow ! headroom=164 while hh_len(eth0)=240
> 
> After adding the 3rd patch with increased LL_MAX_HEADER,
> the warning and stack trace no longer show up.
> 
> Also, could you fix the net core code so that it doesn't 
> panic even with reallocated header?

Well, the reason we have a net-next tree, is that we can let
new features settling for a while, and eventually detect and fix
old bugs.

In your case, having the proper LL_MAX_HEADER will likely improve
performance of TCP_RR like workloads by a nice number :

Re-allocating/copying all TCP packets without notice was _not_ a nice
feature.

Panicing while in net-next mode certainly is something a developer will
notice and report.

BTW, it is possible we have to revert the SYNACK attachment to request
sockets, if it turns out we have too many bugs to fix.

Thanks.
