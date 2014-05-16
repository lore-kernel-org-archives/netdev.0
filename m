From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] xen-netfront: try linearizing SKB if it
 occupies too many slots
Date: Fri, 16 May 2014 10:00:33 -0700
Message-ID: <1400259633.7973.217.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1400238496-2471-1-git-send-email-wei.liu2@citrix.com>
		 <1400245474.7973.154.camel@edumazet-glaptop2.roam.corp.google.com>
		 <20140516131145.GK18551@zion.uk.xensource.com>
		 <1400250068.7973.171.camel@edumazet-glaptop2.roam.corp.google.com>
		 <20140516143653.GL18551@zion.uk.xensource.com>
		 <1400253739.7973.183.camel@edumazet-glaptop2.roam.corp.google.com>
		 <20140516153452.GM18551@zion.uk.xensource.com>
		 <53763CD1.6060500@citrix.com>
	 <1400258829.7973.209.camel@edumazet-glaptop2.roam.corp.google.com>
	 <53764222.6070705@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, netdev@vger.kernel.org,
	xen-devel@lists.xen.org, David Vrabel <david.vrabel@citrix.com>,
	Konrad Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Stefan Bader <stefan.bader@canonical.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:61088 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753287AbaEPRAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 13:00:36 -0400
Received: by mail-pb0-f52.google.com with SMTP id rr13so2845314pbb.39
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 10:00:35 -0700 (PDT)
In-Reply-To: <53764222.6070705@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-16 at 17:51 +0100, Zoltan Kiss wrote:

> But reducing the gso_max_size would have a bad impact on the general 
> network throughput, right?

Not really.

Sending TSO packets with 44 MSS in them instead of 45 might in fact help
a bit. I never could detect any difference.

LRO/GRO receivers aggregate at most 17 or 22 segments anyway.

I said 56000 only as a quick way to test the thing

If you want an explicit formula, it might be :

SKB_WITH_OVERHEAD(65535 - LL_MAX_HEADER) or something like that...
