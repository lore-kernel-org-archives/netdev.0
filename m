From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next v2 1/2] syncookies: remove ecn_ok validation when
 decoding option timestamp
Date: Fri, 31 Oct 2014 17:00:39 +0100
Message-ID: <20141031160039.GM10069@breakpoint.cc>
References: <1414757602-27637-1-git-send-email-fw@strlen.de>
 <1414757602-27637-2-git-send-email-fw@strlen.de>
 <1414762333.499.16.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141031133948.GJ10069@breakpoint.cc>
 <1414764287.27538.1.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141031141503.GL10069@breakpoint.cc>
 <1414770460.27538.9.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:41278 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751271AbaJaQAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 12:00:40 -0400
Content-Disposition: inline
In-Reply-To: <1414770460.27538.9.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2014-10-31 at 15:15 +0100, Florian Westphal wrote:
> 
> > So if you have a per route ecn setting, and syncookies are used,
> > and tcp_ecn sysctl is 0:
> 
> This part I do not understand.
> 
> Why should tcp_ecn be 0 here, and not 2 (default value) ?

Because admin might have changed it.
There is no problem if tcp_ecn sysctl is nonzero (1 or 2).

This problem will only manifest itself iff tcp_ecn sysctl was set to 0,
and the remote peer requests ecn and a route specific setting enabled
ecn for the source network and syncookies are used.

Current timestamp cookie validation will think "client is lying about
ecn in the timestamp as sysctl is off", since it does not consider a
per-route ecn knob.
