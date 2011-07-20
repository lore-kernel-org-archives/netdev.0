From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] pktgen: Clone skb to avoid corruption of skbs in
 ndo_start_xmit methods
Date: Tue, 19 Jul 2011 22:07:38 -0400
Message-ID: <20110720020737.GB2692@neilslaptop.think-freely.org>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
 <1311105738.3113.11.camel@edumazet-laptop>
 <20110719202922.GA2352@minipsycho>
 <1311108107.3113.22.camel@edumazet-laptop>
 <20110720001904.GA1992@neilslaptop.think-freely.org>
 <1311122593.3113.46.camel@edumazet-laptop>
 <4E2626E1.6030005@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51497 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752723Ab1GTCHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 22:07:51 -0400
Content-Disposition: inline
In-Reply-To: <4E2626E1.6030005@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 19, 2011 at 05:52:49PM -0700, Ben Greear wrote:
> On 07/19/2011 05:43 PM, Eric Dumazet wrote:
> >Le mardi 19 juillet 2011 =E0 20:19 -0400, Neil Horman a =E9crit :
>=20
> >>I'm sensitive to the performance impact, but I would much rather se=
e a lower
> >>performing pktgen that doesn't randomly crash, and bring the perfor=
mance back up
> >>in a safe, reliable way.  To that end, I've been starting to think =
about
> >>pre-allocating a ring buffer of skbs with a skb->users count biased=
 up to
> >>prevent driver freeing.  That way we could detect 'unused skb's' by=
 a user count
> >>that was at the bias level.  Thoughts?
> >>
> >
> >I dont know. I use pktgen maybe once per week and never got a single
> >crash like this. We probably are very few pktgen users in the world,=
 and
> >we use it exactly to avoid calling skb_clone() or other expensive pe=
r
> >xmit setup.
> >
> >Just remove pktgen from RedHat kernels, if you dont trust sysadmins.
> ># CONFIG_PKTGEN is not set
> >
> >Alternatively, add a check to problematic drivers to _not_ mess skb =
if
> >skb_shared(skb) is true : eventually use skb_share_check()
>=20
> When the features-flags work gets completed so that we can start addi=
ng
> new flags, we could add a CANT_DO_MULTI_SKB flag to drivers with know=
n
> issues and then restrict pktgen config accordingly.
>=20
I think this is a good idea.  It lets pktgen dynamically make the clone=
/share
decision dynamically and only impacts performance for those systems.

> Upstream code already clears skb memory to avoid leaking kernel memor=
y
> contents, so if you take away multi-skb too, pktgen is going to suck
> at what it is supposed to do:  run fast as possible.
>=20
I don't want to take away multi-skb, but I do want pktgen to work relia=
bly.  I
think flagging drivers that need unshared skbs is the way to go.

> If you want real fun, use pktgen on a wlan0 device...it will crash
> regardless of whether you use multi-skb or not because of xmit-queue
> number issues :P
>=20
I'll try that, thanks :)

Regards
Neil

