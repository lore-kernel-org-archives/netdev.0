From: Julian Anastasov <ja@ssi.bg>
Subject: Re: send-to-self (was Re: routing bug report for 2.4)
Date: Wed, 2 Jul 2003 00:57:21 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307020030170.1076-100000@u.domain.uli>
References: <3EFFEDD7.5020205@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3EFFEDD7.5020205@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Mon, 30 Jun 2003, Ben Greear wrote:

> You should be able to easily test most of the changes your code
> if you have a machine with two ethernet interfaces and a loopback
> cable...

	ok, tested the 2.5 version, the patch files are updated:

http://www.ssi.bg/~ja/#loop

- added missing dev_put on ENETDOWN
- removed the checks that ignore oif for local routes as Alexey suggests

	I have tried simple tests: ICMP, telnet. What I see
is that the 2.5 rt_set_nexthop() does not set sysctl_ip_default_ttl if
res->fi is NULL and that causes the icmp echo packets to use
ttl=0. May be there are still some noisy places like arp_set_predefined,
it will need further investigation. I'm stopping here, for now.

> My requirements are:
>
> 1)  Both ethernet ports communicate over the exernal link, UDP & IP traffic.

	Done

>      Third-party programs if possible, thus I set the flag on the interface in
>      my patch, not on an individual socket, though I do have to BINDTODEVICE and
>      policy-base base route to get things working right...

	Now you have 2 options:

- bind to src IP: the app needs to be aware for that

- ip route replace local IP2 dev DEV2 ... src IP1 table local: the app
does not need to be aware to use this feature

	Now using BINDTODEVICE can cause problems with this feature,
because we do not ignore oif for local destinations, you risk to
miss the local route and arp_filter to break the things or worse (not
tested)

> 1b)  Allow both same-subnet comm (eth1 & eth2 are on same subnet), and also
>       routed traffic (eth1 & eth2 have their own default router, similar to the
>       previously discussed routing setup)

	all other routes remain unchanged, I hope

> 2)  Allow normal non-looped communication on the ports, including policy-based routing
>      based on source addr.

	hm, you better know what you mean. As expected, this feature
has its drawbacks. The safe way is to teach some apps to bind to
IP1 and the apps that are unaware for these loops to use the prefsrc
and thus to use lo. There is no much space for improvement here but
I'm open for suggestions.

> Thanks,
> Ben

Regards

--
Julian Anastasov <ja@ssi.bg>
