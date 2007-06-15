From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [IPV6] addrconf: Fix IPv6 on tuntap tunnels
Date: Fri, 15 Jun 2007 16:42:22 -0400
Message-ID: <4672F9AE.6070400@hp.com>
References: <20070614081607.GA22931@gondor.apana.org.au> <20070614.130358.90120374.davem@davemloft.net> <467259DD.7030703@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	koster@debian.org.tw, socketcan@hartkopp.net,
	urs@isnogud.escape.de, florz@florz.de
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:60485 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753894AbXFOUmg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jun 2007 16:42:36 -0400
In-Reply-To: <467259DD.7030703@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oliver Hartkopp wrote:
> Hallo David, hello Herbert,
> 
> indeed i have some concerns about reverting the patch as i do not see
> that the MTU is the right thing to distinguish whether a netdevice is
> capable to have IPv4/IPv6. E.g. is decnet able to run IPv6?
> 
> IMHO the autoconf (in any case) should only handle netdevices that are
> capable to be auto configured (e.g. with IPv6).
> 
> So the question looks like:
> "Is this device capable to be auto configured with IPv6?"
> and not
> "Is the devices MTU >= IPV6_MIN_MTU ?"

No, the questions should really be:

1.  Is IPV6 supported over this media type.
	yes: got to 2
	no:  stop

2.  Is the device MTU >= IPV6_MIN_MTU
	yes: continue
	no:  stop

Autoconfiguration is a layer on top of IPv6.  Whether it's enabled
or not should not dictate whether IPv6 addressed may be configured or not.

-vlad
