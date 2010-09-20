From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: E1000E/82567LM-3: link reported up too soon
Date: Mon, 20 Sep 2010 22:09:16 +0200
Message-ID: <87y6awjhxv.fsf@small.ssi.corp>
References: <87bp7vnnpj.fsf@small.ssi.corp>
	<20100920.112213.42810338.davem@davemloft.net>
	<878w2wnsyd.fsf@small.ssi.corp>
	<20100920.125447.220082714.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: brian.haley@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:60697 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754531Ab0ITUIc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Sep 2010 16:08:32 -0400
In-Reply-To: <20100920.125447.220082714.davem@davemloft.net> (David Miller's
	message of "Mon, 20 Sep 2010 12:54:47 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

David Miller <davem@davemloft.net> writes:

> From: arno@natisbad.org (Arnaud Ebalard)
> Date: Mon, 20 Sep 2010 20:57:46 +0200
>
>> On some ethernet devices (at least), link may be reported up (NEWLINK
>> received by userspace with flags indicating UP and RUNNING) before the
>> interface is really usable. When sending packets as soon as the link is
>> available, the first one may be dropped. That's what you see on the
>> capture above.
>
> The link being up doesn't mean an address has been assigned to the
> interface for the protocol you are using yet.
>
> I think you have to schedule whatever it is you need to make sure it
> runs after dhcp successfully complete.

Maybe I was a bit unclear.

The packets sent are an IPv6 Router Solicitation (to get IPv6 subnet
prefixes from the router) and a DHCP Request (to get an IPv4 address
from the DHCP server). 

The former is sent from the unspecified address (::) and the latter from
0.0.0.0. The former is sent by UMIP Mobile IPv6 daemon. The second by my
DHCP client. They both use netlink to do that as soon as the link is up.
Both are for address configuration ...

Cheers,

a+
