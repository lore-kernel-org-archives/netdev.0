From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] tcp: SO_TIMESTAMP implementation for TCP
Date: Fri, 30 Apr 2010 22:40:38 -0700
Message-ID: <AANLkTimFjDNgXdMGpVpO7Gi38ROlww1Fa7IKA1ASBKOV@mail.gmail.com>
References: <alpine.DEB.1.00.1004292246440.12776@pokey.mtv.corp.google.com>
	 <20100429.233958.212393607.davem@davemloft.net>
	 <i2i65634d661004300058s5ee1b177oee249d3d22baad62@mail.gmail.com>
	 <20100430.164115.257514715.davem@davemloft.net>
	 <20100501010735.dfe097bc.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:23979 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059Ab0EAFkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 01:40:43 -0400
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id o415eenP024686
	for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 22:40:41 -0700
Received: from pxi19 (pxi19.prod.google.com [10.243.27.19])
	by kpbe15.cbf.corp.google.com with ESMTP id o415edKO008486
	for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 22:40:39 -0700
Received: by pxi19 with SMTP id 19so534419pxi.31
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 22:40:39 -0700 (PDT)
In-Reply-To: <20100501010735.dfe097bc.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Not being a kernel hacker, I will naively ask if the kernel tracing
> facility could somehow be used to provide the desired info (or could
> be modified to provide it).
>

We did consider kernel tracing (more in the context of implementing
RFC 4898).  In the case of trying get per packet timestamps,
correlating a ktrace event with an application message is probably too
high to make it practical.  If it weren't for the cost of
timestamp'ing every single skb being received, we'd probably have
SO_TIMESTAMP turned on permanently for many connections.  For now
we're settling for a percentage of messages for sampling.

Tom
