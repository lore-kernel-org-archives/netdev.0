From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet
 switch configuration API
Date: Fri, 6 Dec 2013 17:45:46 -0800
Message-ID: <CAGVrzcZd_gdKn7QK0qRW9XKMhPuLNm45J6oKqJut7ix2EZseFA@mail.gmail.com>
References: <5267BB53.8030703@openwrt.org> <5267C6B9.4000704@mojatatu.com>
 <5267CFAB.9090100@openwrt.org> <5267D8AE.7080009@mojatatu.com>
 <5267DDE6.70600@openwrt.org> <526A5949.6040404@mojatatu.com>
 <526A6BB3.7050507@openwrt.org> <526D4B06.8040505@mojatatu.com>
 <526D6EBA.3020903@openwrt.org> <526EEAE9.6090508@mojatatu.com>
 <20131030172756.GM8570@wantstofly.org> <52716252.9060502@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	John Crispin <blogic@openwrt.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Gary Thomas <gary@mlbassoc.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Chris Healy <cphealy@gmail.com>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:42112 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754026Ab3LGBq1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 20:46:27 -0500
Received: by mail-pd0-f169.google.com with SMTP id v10so1958640pde.14
        for <netdev@vger.kernel.org>; Fri, 06 Dec 2013 17:46:27 -0800 (PST)
In-Reply-To: <52716252.9060502@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/10/30 Felix Fietkau <nbd@openwrt.org>:
>> With DSA, you would bridge between port1.4 and port2.400.  I'm still
>> not sure what your argument is arguing for or against.
> I'm saying most switches that we support cannot do DSA-style packet port
> tagging for ingress/egress. That kind of setup can be done with some
> software bridging when setting up VLAN tables appropriately, but I'm not
> sure it's possible to emulate this if you're treating the switch as a
> 'bridge' and trying to do handle this via the FDB API, which is what we
> were discussing earlier.

DSA works nicely because it has its own Ethertype, and also because
the switches are configurable enough to allow for the insertion of a
custom Ethertype for which you can register a corresponding
dev_add_pack() handler. Even on some switches which support custom
tags appended or prepended such as those from Broadcom, a tag is
usually inserted between ethe Ethernet Source Address and the
Ethertype, but this tag has variable fields. I could imagine that we
extend the dev_add_pack() to include a mask to perform the matching,
but this is going to add an "and" logical operation in a hot-path,
would that be acceptable?

And this only works when the tag is prepended, if it is appended, we
are kind of stuck because we do not really have any way to look for it
at the end of the frame but assume that is here/not here...
-- 
Florian
