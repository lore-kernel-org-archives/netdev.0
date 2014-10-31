From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next v2 1/2] syncookies: remove ecn_ok validation when
 decoding option timestamp
Date: Fri, 31 Oct 2014 08:47:40 -0700
Message-ID: <1414770460.27538.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414757602-27637-1-git-send-email-fw@strlen.de>
	 <1414757602-27637-2-git-send-email-fw@strlen.de>
	 <1414762333.499.16.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141031133948.GJ10069@breakpoint.cc>
	 <1414764287.27538.1.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141031141503.GL10069@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:64542 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756174AbaJaPrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 11:47:42 -0400
Received: by mail-ie0-f171.google.com with SMTP id x19so1536138ier.2
        for <netdev@vger.kernel.org>; Fri, 31 Oct 2014 08:47:42 -0700 (PDT)
In-Reply-To: <20141031141503.GL10069@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-31 at 15:15 +0100, Florian Westphal wrote:

> So if you have a per route ecn setting, and syncookies are used,
> and tcp_ecn sysctl is 0:

This part I do not understand.

Why should tcp_ecn be 0 here, and not 2 (default value) ?

> 
> 1. we receive syn with ecn on and timestamps
> 2. we send cookie synack, with timestamp and ecn (route allowed it),
> the lower bits of the timestamp have a "magic" bit set that allows
> us to infer that ecn was negotiated successfully.
> 3. we drop the ack from the client, since timestamp decoding sees
> "ecn is on according to timestamp, but the tcp_ecn sysctl is off".
> 
> So to fix this, step 3 either has to check the dst setting
> in addition to the global sysctl, or to rely on the timestamp alone
> that ecn was requested by the original client and allowed by our host
> at the time synack timestamp was generated/sent.
> 
> I hope that explains the reason behind patch #1 up.
