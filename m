From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [RFC][PATCH] IP: Make ping sockets optional
Date: Fri, 25 Apr 2014 19:37:02 +0900
Message-ID: <CAKD1Yr0X5vqhdmFkwfgd0WJ0Jw7GGm8=iHNPeyfNKoODN4=1Mw@mail.gmail.com>
References: <1398266428.7767.140.camel@deadeye.wl.decadent.org.uk>
 <20140423153018.GA13717@breakpoint.cc> <1398268542.7767.145.camel@deadeye.wl.decadent.org.uk>
 <20140423162712.GB13717@breakpoint.cc> <20140424151748.GH1960@order.stressinduktion.org>
 <1398355320.7767.175.camel@deadeye.wl.decadent.org.uk> <20140424163712.GJ1960@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Ben Hutchings <ben@decadent.org.uk>,
	Florian Westphal <fw@strlen.de>,
	netdev <netdev@vger.kernel.org>,
	Vasiliy Kulikov <segoon@openwall.com>,
	Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:64148 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593AbaDYKhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 06:37:23 -0400
Received: by mail-ie0-f181.google.com with SMTP id y20so1731009ier.40
        for <netdev@vger.kernel.org>; Fri, 25 Apr 2014 03:37:22 -0700 (PDT)
In-Reply-To: <20140424163712.GJ1960@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 25, 2014 at 1:37 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> The origins of this interface are in the openwall project. I assume
> embedded devices were not that high up on their agenda.

One of the original discussion threads I posted above has a link to a
lengthy discussion on why the original designers of this code thought
capabilities were not a good idea from a security standpoint.

> We absolutely cannot abandon the interface as it already is in use by
> android, as Lorenzo stated.

Well, the fact that it's in use by Android doesn't mean it can't be
made optional - Android can just turn the feature on in their kernels.
It would be unfortunate if it were to be removed entirely.

> Will android switch to file based capabilities
> in some time? Is that possible?

I think Android does support file capabilities. But this socket type
is not just for the ping binary. The fact that this socket type is
available to any binary allows any application developer to write an
app that can send ping packets. That seems like a useful capability
for a diagnostic app.

On the other hand, it seems to me that giving that same diagnostic app
CAP_NET_RAW would be unacceptable from a security point of view since
that app would now be able to sniff all traffic on the system, with
obvious privacy implications. There are also the usual security
concerns such as what if an exploit is discovered in the ping binary,
etc. etc.

What's the problem with this code? Is it just the 10KB in size?
