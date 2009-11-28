From: jamal <hadi@cyberus.ca>
Subject: Re: [tproxy,regression] tproxy broken in 2.6.32
Date: Sat, 28 Nov 2009 10:45:57 -0500
Message-ID: <1259423157.3864.9.camel@bigi>
References: <db81a9a20911230443h443b3c2l8fab5aef7b09cfa@mail.gmail.com>
	 <1259137434.9191.3.camel@nienna.balabit>
	 <db81a9a20911260919w1ffded25ref5ae24ee73f8eda@mail.gmail.com>
	 <1259310417.3809.5.camel@nienna.balabit> <1259337932.3299.3.camel@bigi>
	 <20091128151515.GA20476@sch.bme.hu>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: KOVACS Krisztian <hidden@balabit.hu>,
	Andreas Schultz <aschultz@warp10.net>, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org
To: KOVACS Krisztian <hidden@sch.bme.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:40853 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762AbZK1Ppy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2009 10:45:54 -0500
Received: by qw-out-2122.google.com with SMTP id 3so442783qwe.37
        for <netdev@vger.kernel.org>; Sat, 28 Nov 2009 07:46:00 -0800 (PST)
In-Reply-To: <20091128151515.GA20476@sch.bme.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-11-28 at 16:15 +0100, KOVACS Krisztian wrote:


> It's already on prerouting, so that's not the problem.

ok.

> The problem is that for tproxy to work we've used to have a rule like
> this:
> 
> # ip rule add fwmark 1 lookup 100
> 
> plus a few iptables rules setting mark values.
> 
> The issue is that previously fib_validate_source ignored the mark set on
> the skb, and thus when fib_validate_source() did a FIB lookup, it all went
> fine, because it found a result of type RTN_UNICAST.


Ok, that would be it ;-> 


>  However, with your
> change, and because of the ip rule above not being specific enough now
> it's returning with type RTN_LOCAL, and that's considered invalid and thus
> the skb is dropped.

Well, since we are validating a source address - only unicast routes
are legitimate imo. i.e it was wrong to allow local before.

> 
> The workaround is using more specific ip rules that include the ingress
> interface name:
> 
> # ip rule add dev eth0 fwmark 1 lookup 100
> 

Or adding routes into table 100 with type "unicast" would do it as
well.

cheers,
jamal

