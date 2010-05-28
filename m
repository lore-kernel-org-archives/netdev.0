From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [REGRESSION,BISECTED] MIPv6 support broken by f4f914b58019f0
Date: Fri, 28 May 2010 23:15:55 +0200
Message-ID: <87ljb3ohh0.fsf@small.ssi.corp>
References: <87zkzmppfg.fsf@small.ssi.corp> <4BFDC14F.6050407@hp.com>
	<8739xdqsuz.fsf@small.ssi.corp> <4BFECA65.7030102@hp.com>
	<87sk5d2h4u.fsf@small.ssi.corp> <4C000E37.7080306@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brian Haley <brian.haley@hp.com>,
	David Miller <davem@davemloft.net>,
	Jiri Olsa <jolsa@redhat.com>,
	Scott Otto <scott.otto@alcatel-lucent.com>,
	netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:56986 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753022Ab0E1VQN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 May 2010 17:16:13 -0400
In-Reply-To: <4C000E37.7080306@linux-ipv6.org> (YOSHIFUJI Hideaki's message of
	"Sat, 29 May 2010 03:40:55 +0900")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org> writes:

>>> I guess I always believed setting SO_BINDTODEVICE should always force
>>> traffic out that interface, but from Yoshifuji's email it seems that
>>> maybe wasn't the intention, at least for things that don't meet
>>> the rt_need_strict() criteria like globals.  I don't know the history
>>> behind the setsockopt.
>>
>> The behavior I would expect from a combination of RFC 4191 and
>> SO_BINDTODEVICE sockopt would be the use of the interface as outgoing
>> interface and then the use of the best router (using router preference
>> info, reachability, ...) available on the subnet. IIRC, the router
>> preference info is per default router list in the RFC, i.e. per
>> interface.
>
> Good point.
>
> Whatever our original intention/thought was,
> current RFC says that we should honor outgoing interface
> specified by user (by IPV6_PKTINFO etc.), as we do for
> SO_BINDTODEVICE in IPv4 as well.
>
> In this sense, checking sk->sk_bound_dev_if in
> ip6_route_output() is not enough because we need to
> take outgoing interface specified in ancillary data
> into account, which is set to fl->oif.
>
> How about adding additional "flags" parameter
> for ip6_route_output()?

I think this may provide a better long term solution but getting all
combinations of cases (SO_BINDTODEVICE and other IPv6 sockopts) work
together (possibly with external info like RFC 4191 ones gathered from
RA or specific local routing config) will be a bit tricky.

Meanwhile, regarding the regression, as Brian's fix handles most
cases, I think it would be useful to apply it and push it to the
stable team.

Cheers,

a+
