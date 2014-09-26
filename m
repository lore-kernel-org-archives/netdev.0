From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 2/3] ipv6: mld: do not overwrite uri when receiving
 an mldv2 query
Date: Fri, 26 Sep 2014 11:29:30 +0200
Message-ID: <542531FA.2070701@redhat.com>
References: <1411455828-5196-1-git-send-email-dborkman@redhat.com> <1411455828-5196-3-git-send-email-dborkman@redhat.com> <54243C89.6060405@oracle.com> <542475E3.6030508@redhat.com> <5424A408.5000208@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hannes@stressinduktion.org,
	netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52568 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753275AbaIZJ3j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Sep 2014 05:29:39 -0400
In-Reply-To: <5424A408.5000208@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2014 01:23 AM, David L Stevens wrote:
...
> Now, probably that discussion should've happened when the tunables were put in, but
> having the sysctl's is still useful for setting the values when there is no querier
> present.
>
> When there is a querier, however, the original code IMO makes more sense, especially
> in the absence of any input from an administrator.
>
> I'm generally for allowing administrators complete flexibility, even if they use it
> for evil, so I think I'd prefer something along the lines of:
>
> 1) have an initial default of 1sec (v2) or 10sec (v1)
> 2) if an administrator sets the sysctl, override any
> 	other choice with that setting
> 3) if an administator has not set it, use the querier value
>
> That combination allows the querier to effectively set an appropriate interval for
> the entire network, allows an admin to change it per-host if desired, and uses the
> suggested defaults when there is no querier or admin intervention.
>
> Or maybe split the sysctls into one that forces the value and one that just sets
> a default which can be overridden by queriers.
>
> I don't think your patches are incorrect, but I don't think the original behavior
> is either. With your interpretation, the URI (but not the MRD or QRV), must be
> changed on every individual host to tune a network away from the default values.
> The current code doesn't have that problem.

I'm fine with either suggestion. Actually the _current_ situation we're in is
that in IPv4 we _always_ use the current, uncached _sysctl_ tuned setting of URI
(independent of any protocol version); while in IPv6 we use the _cached_ sysctl
URI in case of MLDv1 and _always_ overwrite the URI in case of MLDv2 (even for
MLDv1). Are you suggesting that, we then better adapt using the maxdelay value
everywhere and adapt URI to it, plus having a boolean knob defaulting to off for
an admin to enforce always using the provided sysctl default setting and not
the snooped MLD?
