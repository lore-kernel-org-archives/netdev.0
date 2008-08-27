From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Wed, 27 Aug 2008 19:27:07 +0200
Message-ID: <48B58E6B.1030302@cosmosbay.com>
References: <200808220457.40892.denys@visp.net.lb> <20080826201406.GA24827@2ka.mipt.ru> <48B46B48.7030609@cosmosbay.com> <20080826205158.GA15266@2ka.mipt.ru> <87vdxmr53f.fsf@basil.nowhere.org> <48B57BD3.5050206@hp.com> <20080827162735.GW26610@one.firstfloor.org> <48B58586.3080806@hp.com> <20080827165635.GY26610@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp20.orange.fr ([193.252.22.31]:36935 "EHLO smtp20.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750798AbYH0R1P convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 13:27:15 -0400
In-Reply-To: <20080827165635.GY26610@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen a =E9crit :
> On Wed, Aug 27, 2008 at 09:49:10AM -0700, Rick Jones wrote:
>> Andi Kleen wrote:
>>>> Those banks really want to crank down on latency - to the point th=
ey=20
>>>> start disabling interrupt coalescing.  I bet they'd toss anything =
out=20
>>>> they could to shave another microsecond.
>>>
>>> This change would actually likely lower their latency.
>> I'm guessing you mean increase their latency?  I agree, it could -=20
>> depends entirely on the PPS in production I suspect.
>=20
> No, moving the time stamps into the socket decreases latency
> for all packets that don't need time stamps. And they likely=20
> have some packets which don't need time stamps too.
>=20
> As a secondary effect if they use a RT kernel it might
> be also beneficial to do the (depending on the platform)
> costly time stamp in the lower priority socket context
> than in the high priority interrupt thread.
>

Doing the expensive timestamping in a possibly delayed thread (ie some =
milliseconds
 after hardware notification) is wrong/useless.

Better use plain xtime instead of getnstimeofday() in this case.

We could provide a sysctl setting so that admin can chose between preci=
se timestamps
(current behavior) or fast but low resolution timestamping (xtime based=
)





