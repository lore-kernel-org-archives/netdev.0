From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC 0/2] xfrm: Remove ancient sleeping code
Date: Thu, 10 Oct 2013 10:57:03 +0200
Message-ID: <20131010085703.GR7660@secunet.com>
References: <20131010063301.GO7660@secunet.com>
 <525650F6.305@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:42243 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751635Ab3JJI5G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Oct 2013 04:57:06 -0400
Content-Disposition: inline
In-Reply-To: <525650F6.305@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 10, 2013 at 03:02:14PM +0800, Fan Du wrote:
>=20
>=20
> On 2013=E5=B9=B410=E6=9C=8810=E6=97=A5 14:33, Steffen Klassert wrote:
> >Does anyone still rely on the ancient sleeping when the SA is in
> >acquire state? It is disabled by default since more that five years,
> >but can cause indefinite task hangs if enabled and the needed state
> >does not get resolved.
>=20
> I saw that "can_sleep" is set true in ip_route_connect which upper la=
yer
> protocol relies on it, which ensure not dropping *any* skb.

'Any' means one per task in this context. Also, we can't ensure that
this packet reaches it's destination. So where is the difference
between dropping the packet locally or on the network?

> And acquire timer will make sure the task will not hangs indefinitely=
=2E
>=20

Did you try that? It makes sure that the task wakes up from time to tim=
e,
but it goes immediately back to sleep if the needed state is not resolv=
ed.
The only terminating contition is when the task gets a signal to exit.

> In xfrm policy queue, XFRM_MAX_QUEUE_LEN is 100, which means 101th sk=
b
> will be dropped, how about make it configurable?

IMO we would have yet another useless knob then. Currently we send all
packets by default to a blackhole as long as the state is not resolved
and most people are fine with it. The queueing is mostly to speed up
tcp handshakes, so 100 packets should be enough. If it really turnes
out that we need more that 100 packets in some cases, we can add a
sysctl then.
