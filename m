From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/4] Namespacify inet_peer_* sysctl knobs
Date: Wed, 17 Feb 2016 13:15:37 -0600
Message-ID: <87si0r4086.fsf@x220.int.ebiederm.org>
References: <1455703798-15258-1-git-send-email-kernel@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Nikolay Borisov <kernel@kyup.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:53529 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161059AbcBQTZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 14:25:36 -0500
In-Reply-To: <1455703798-15258-1-git-send-email-kernel@kyup.com> (Nikolay
	Borisov's message of "Wed, 17 Feb 2016 12:09:54 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Borisov <kernel@kyup.com> writes:

> This series make the inet_peer ttl sysctls to be namespace aware. 
>
> Patch 1 adds a namespace association to the inet_peer_base struct, 
> which in turn is used to make the sysctls namespace aware. The 
> rest of the patches are straightforward.

At a quick skim I am not certain I am comfortable with this change.

The issue is that these are not packet parameters you are tuning but
lifetimes for data structures.

Generally there are challenges making this kind of thing per namespace
because resource control can lead to DOS attack from one namespace
being able to arbitrarly control it's own resource consumption.

Is this something that is actually worth making per namespace?

Eric

> Nikolay Borisov (4):
>   inetpeer: Add net namespace assosication in inet_peer_base
>   inetpeer: Namespacify inet_peer_maxttl sysctl knob
>   inetpeer: Namespacify inet_peer_minttl sysctl knob
>   inetpeer: Namespacify inet_peer_threshold sysctl knob
>
>  include/net/inetpeer.h     |  1 +
>  include/net/ip.h           |  5 -----
>  include/net/netns/ipv4.h   |  4 ++++
>  net/ipv4/inetpeer.c        | 15 ++++++---------
>  net/ipv4/route.c           |  1 +
>  net/ipv4/sysctl_net_ipv4.c | 47 ++++++++++++++++++++++++----------------------
>  6 files changed, 37 insertions(+), 36 deletions(-)
