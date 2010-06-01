From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [PATCHv2] Refactor update of IPv6 flow destination address for srcrt (RH) option
Date: Tue, 01 Jun 2010 23:58:11 +0200
Message-ID: <87mxve8lfw.fsf@small.ssi.corp>
References: <87wruid8rx.fsf@small.ssi.corp> <8739x6d0ky.fsf@small.ssi.corp>
	<1275422925.19372.114.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:42624 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753044Ab0FAV61 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jun 2010 17:58:27 -0400
In-Reply-To: <1275422925.19372.114.camel@Joe-Laptop.home> (Joe Perches's
	message of "Tue, 01 Jun 2010 13:08:45 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Joe Perches <joe@perches.com> writes:

>> +static inline struct in6_addr *srcrt_dst_flow_update(struct in6_addr *final,
>> +						     struct in6_addr *fl6dst,
>> +						     const struct ipv6_txoptions *opt)
>> +{
>> +	if (opt && opt->srcrt) {
>> +		const struct rt0_hdr *rt0 = (struct rt0_hdr *)opt->srcrt;
>> +		ipv6_addr_copy(final, fl6dst);
>> +		ipv6_addr_copy(fl6dst, rt0->addr);
>> +		return final;
>> +	}
>> +	return NULL;
>> +}
>> +
>
> Should this be inline?  Maybe it'd be better moved to exthdrs.c

I thought it was small enough to keep it inline in ipv6.h but removing
the inline and moving it to exthdrs.c makes sense. 

> Perhaps this is clearer as something like:
>
> /**
>  * fl6_update_dst - update flow destination address
>  *
>  * @fl: flowlabel fl_dst to update
>  * @opt: struct ipv6_txoptions
>  * @orig: original fl_dst if modified
>  *
>  * Returns NULL if no txoptions or no srcrt, otherwise
>  * returns orig and initial value of fl->fl6_dst set in orig
>  */
> struct in6_addr *fl6_update_dst(struct ip6_flowlabel *fl,
> 				const struct ipv6_txoptions *opt,
> 				struct in6_addr *orig)
> {
> 	if (!opt || !opt->srcrt)
> 		return NULL;
>
> 	ipv6_addr_copy(orig, &fl->fl6_dst);
> 	ipv6_addr_copy(&fl->fl6_dst, ((struct rt0_hdr *)opt->srcrt)->addr);
> 	return orig;
> }

I'll send an updated new version tomorrow, i.e. in a few hours (with
s/ip6_flowlabel/flowi/).

Thanks for your feedback.

Cheers,

a+
