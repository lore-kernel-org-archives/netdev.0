From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH] ipv6: address preservation on link down
Date: Fri, 9 Jan 2009 10:02:06 +0200
Message-ID: <200901091002.07224.remi.denis-courmont@nokia.com>
References: <20090108135614.23aed603@extreme> <20090108.140339.00980764.davem@davemloft.net> <20090108171415.1d282743@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: "ext Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:29724 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751492AbZAIICu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 03:02:50 -0500
In-Reply-To: <20090108171415.1d282743@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 09 January 2009 03:14:15 ext Stephen Hemminger, you wrote:
> When an interface goes down, IPV6 deletes all addresses unlike IPV4. =
This
> is a problem since it can break routing protocols and other applicati=
ons.
> It looks like this was done to handle DAD, but is a big stick solutio=
n when
> other code is possible.
>
> The following patch changes the behaviour to delete link local addres=
ses
> but keep all configured addresses and restart DAD when interface come=
s back
> up.

Let alone the backward compatibility problem for a minute. I have two _=
other_=20
problems with this:

1/ If DAD should fail when the interface is brought back up, wouldn't a=
ll the=20
EAU-64 autoconfigured address become invalid, rather than just the link=
-local=20
one?

2/ In some case the link-local address is assigned by userland, no diff=
erent=20
from the other ones. At least miredo is behaving this way.

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
