From: Julian Anastasov <ja@ssi.bg>
Subject: Re: return of ip_rt_bug()
Date: Fri, 5 Aug 2011 19:36:41 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1108051931250.29588@ja.ssi.bg>
References: <20110802170942.GA17164@redhat.com> <alpine.LFD.2.00.1108041422510.1495@ja.ssi.bg> <CAFiZG+X0oyTOXqm4b0g_UEGYK_0JCW3=WOR5d_7GfbJrTMhMzg@mail.gmail.com> <alpine.LFD.2.00.1108042034540.1495@ja.ssi.bg> <CAFiZG+W9-vV6o9EbuVEwztW4sQ1QV-MxD+xCHFw7TbNAryzN6A@mail.gmail.com>
 <CAFiZG+UY+Rn=wqi6b9CM0CcARHJUGiqh_jpfEveGLhm+D2hNhA@mail.gmail.com> <alpine.LFD.2.00.1108051048160.1494@ja.ssi.bg> <CAFiZG+Wmv_FEx2ZX3qZt0tAr-QVQD_javX1gbRWujr9xyf7nbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org
To: Tom London <selinux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:41268 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751655Ab1HEQcL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Aug 2011 12:32:11 -0400
In-Reply-To: <CAFiZG+Wmv_FEx2ZX3qZt0tAr-QVQD_javX1gbRWujr9xyf7nbQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 5 Aug 2011, Tom London wrote:

> I'd like to conclude that this is due to UDP casting on the wlan.
> I'll reboot with the radio on and in debug mode to see what happens.

	Sending to 255.255.255.255 without binding to source address
or output device will succeed only if there is a route that matches
the 255.255.255.255 address (default route as last option).
If no route matches, the result is ENETUNREACH and packet
should be dropped. But how input route is attached, I still don't know.

	Your ip monitor does not show fatal event that can
invalidate the source address or the default route (that
will match for 255.255.255.255) while sending packet.
It is almost impossible such problem to occur, i.e. between routing
and following re-routing the address/route to disappear.

	Such events:

3: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP>
    link/ether
3: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP>
    link/ether
3: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP>
    link/ether

	are may be for link, not sure. Events for addresses/routes
would show addresses and routes in a way similar to
ip addr and ip route list.

	Not sure where your logs go, may be you can add
"kern.* /var/log/kernel.log" in your /etc/rsyslog.conf. But if
you don't see the WARNING then the problem does not happen.
You can also see the ip_rt_bug line with 'dmesg'. So, can
you confirm the problem occurs only when default route
points to wlan? Even if so, I still don't see good explanation
for the error message.

Regards

--
Julian Anastasov <ja@ssi.bg>
