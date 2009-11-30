From: KOVACS Krisztian <hidden@balabit.hu>
Subject: Re: [tproxy,regression] tproxy broken in 2.6.32
Date: Mon, 30 Nov 2009 13:45:29 +0100
Message-ID: <1259585129.3992.13.camel@nienna.balabit>
References: <db81a9a20911260919w1ffded25ref5ae24ee73f8eda@mail.gmail.com>
	 <1259310417.3809.5.camel@nienna.balabit> <1259337932.3299.3.camel@bigi>
	 <20091128151515.GA20476@sch.bme.hu> <4B1145F1.3090704@trash.net>
	 <1259424278.3864.16.camel@bigi> <4B1158CE.90803@trash.net>
	 <1259429774.3864.41.camel@bigi> <20091128190500.GB12264@sch.bme.hu>
	 <1259437442.3864.61.camel@bigi>  <20091129203508.GB18259@sch.bme.hu>
	 <1259583359.873.17.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: KOVACS Krisztian <hidden@sch.bme.hu>,
	Patrick McHardy <kaber@trash.net>,
	Andreas Schultz <aschultz@warp10.net>, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from support.balabit.hu ([195.70.41.86]:58827 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751709AbZK3Mp0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Nov 2009 07:45:26 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id D439211E1EB
	for <netdev@vger.kernel.org>; Mon, 30 Nov 2009 13:45:31 +0100 (CET)
In-Reply-To: <1259583359.873.17.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, 2009-11-30 at 07:15 -0500, jamal wrote:
> On Sun, 2009-11-29 at 21:35 +0100, KOVACS Krisztian wrote:
> 
> > The story is that we really do want to deliver these packets locally, as
> > if the destination IP address was locally configured on the host. The only
> > way I know of to get the packet to ip_local_deliver() is by using a local
> > route.
> 
> Aha, now i understand where both you and Patrick are coming from. So
> you literally have to hit the main(or default) table in the reverse
> source validation. How does the workaround (that you suggested) work
> then? i.e you are going to fail the RTN_UNICAST test no matter what.

No, because by narrowing the rule to specific ingress interfaces the
lookup done in fib_validate_source() won't match the rule(s) (because
the flow used will have iif set to the loopback device), and thus it
will look up the main table and select a unicast route.

> Dave, give me some short time to mull this over. I am not sure i like
> the sysctl approach - we may have to just revert the whole thing
> instead.

I don't think it would be unreasonable to add a sysctl but disable the
feature by default. It's up to you, of course.

Cheers,
Krisztian

