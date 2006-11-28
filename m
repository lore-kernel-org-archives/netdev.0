From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Network virtualization/isolation
Date: Tue, 28 Nov 2006 09:51:57 -0700
Message-ID: <m1r6vnikeq.fsf@ebiederm.dsl.xmission.com>
References: <453F8800.9070603@fr.ibm.com> <45408397.8070404@fr.ibm.com>
	<20061026085659.33b4c6dd@freekitty>
	<200610271134.56830.dim@openvz.org> <4541CCF4.4050306@fr.ibm.com>
	<1162391707.5251.78.camel@jzny2> <4559DE01.5090109@fr.ibm.com>
	<m1y7pzoptr.fsf@ebiederm.dsl.xmission.com>
	<456C447E.5090703@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, Dmitry Mishin <dim@openvz.org>,
	Stephen Hemminger <shemminger@osdl.org>,
	netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:48514 "EHLO
	ebiederm.dsl.xmission.com") by vger.kernel.org with ESMTP
	id S935885AbWK1Qyv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Nov 2006 11:54:51 -0500
To: Daniel Lezcano <dlezcano@fr.ibm.com>
In-Reply-To: <456C447E.5090703@fr.ibm.com> (Daniel Lezcano's message of "Tue,
	28 Nov 2006 15:15:26 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I do not want to get into a big debate on the merits of various
techniques at this time.  We seem to be in basic agreement
about what we are talking about.

There is one thing I think we can all agree upon.
- Everything except isolation at the network device/L2 layer, does not
  allow guests to have the full power of the linux networking stack.

- There has been a demonstrated use for the full power of the linux
  networking stack in containers..

- There are a set of techniques which look as though they will give
  us full speed when we do isolation of the network stack at the
  network device/L2 layer.

Is there any reason why we don't want to implement network namespaces
without the full power of the linux network stack?

If there is a case where we clearly don't want the full power of the
linux network stack in a guest but we still need a namespace we can
start looking at the merits of the alternatives.

> What is this new paradigm you are talking about ?

The basic point is this.  The less like stock linux the inside of a
container looks, and the more of a special case it is the more
confusing it is.  The classic example is that for a system container
routing packets between containers over the loopback interface is
completely unexpected.


> There is not extra networking data structure instantiation in the
> Daniel's L3.
Nope just an extra field which serves the same purpose.

>> - Bind/Connect/Accept filtering.  There are so few places in
>>   the code this is easy to maintain without sharing code with
>>   everyone else.
>
> For isolation too ? Can we build network migration on top of that ?

As long as you can take your globally visible network address with you
when you migrate you can build network migration on top of it.  So yes
bind/accept filtering is sufficient to implement migration, if you are
only using IP based protocols.

Eric
