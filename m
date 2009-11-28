From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: Re: [tproxy,regression] tproxy broken in 2.6.32
Date: Sat, 28 Nov 2009 19:50:19 +0100
Message-ID: <20091128185019.GA12264@sch.bme.hu>
References: <db81a9a20911230443h443b3c2l8fab5aef7b09cfa@mail.gmail.com> <1259137434.9191.3.camel@nienna.balabit> <db81a9a20911260919w1ffded25ref5ae24ee73f8eda@mail.gmail.com> <1259310417.3809.5.camel@nienna.balabit> <1259337932.3299.3.camel@bigi> <20091128151515.GA20476@sch.bme.hu> <1259423157.3864.9.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: KOVACS Krisztian <hidden@sch.bme.hu>,
	KOVACS Krisztian <hidden@balabit.hu>,
	Andreas Schultz <aschultz@warp10.net>, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from centaur.sch.bme.hu ([152.66.208.5]:53619 "EHLO
	centaur.sch.bme.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753149AbZK1SuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2009 13:50:14 -0500
Content-Disposition: inline
In-Reply-To: <1259423157.3864.9.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On szo, nov 28, 2009 at 10:45:57 -0500, jamal wrote:
> >  However, with your
> > change, and because of the ip rule above not being specific enough now
> > it's returning with type RTN_LOCAL, and that's considered invalid and thus
> > the skb is dropped.
> 
> Well, since we are validating a source address - only unicast routes
> are legitimate imo. i.e it was wrong to allow local before.
> 
> > 
> > The workaround is using more specific ip rules that include the ingress
> > interface name:
> > 
> > # ip rule add dev eth0 fwmark 1 lookup 100
> > 
> 
> Or adding routes into table 100 with type "unicast" would do it as
> well.

Well, the only route we're interested in is the following (see
Documentation/networking/tproxy.txt for the details):

ip route add local 0.0.0.0/0 dev lo table 100

Adding a unicast route is not really an option, so I'd say the only
workaround is modifying rules to include the ingress device names.

-- 
KOVACS Krisztian
