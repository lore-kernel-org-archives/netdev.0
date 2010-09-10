From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [RFC] bnx2x: Insane RX rings
Date: Fri, 10 Sep 2010 14:16:14 +0300
Message-ID: <1284117374.30831.2.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1284065105.4782.11.camel@edumazet-laptop>
 <4C894FBD.2020109@ans.pl>
 <20100909.143001.104050644.davem@davemloft.net>
 <4C8953D3.9060204@hp.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "ole@ans.pl" <ole@ans.pl>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>,
	"Rick Jones" <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2501 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751191Ab0IJLQg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 07:16:36 -0400
In-Reply-To: <4C8953D3.9060204@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-09-09 at 14:38 -0700, Rick Jones wrote:
> David Miller wrote:
> > From: Krzysztof Ol=C4=99dzki <ole@ans.pl>
> > Date: Thu, 09 Sep 2010 23:21:01 +0200
> >=20
> >=20
> >>On 2010-09-09 22:45, Eric Dumazet wrote:
> >>
> >>>Problem is : With 16 RX queues per device , thats 4078*16*2Kbytes =
per
> >>>ethernet port.
> >>>
> >>>Total :
> >>>
> >>>skbuff_head_cache 130747 131025 256 15 1 : tunables 120 60 8 :
> >>>slabdata 8735 8735 40
> >>>size-2048 130866 130888 2048 2 1 : tunables 24 12 8 : slabdata 654=
44
> >>>65444 28
> >>>
> >>>Thats about 300 Mbytes of memory, just in case some network trafic
> >>>will occur.
> >>>
> >>>Lets do something about that ?
> >>
> >>Yep, it is ~8MB per queue, not so much alone, but a lot together. F=
or
> >>this reason I use something like bnx2.num_queues=3D2 on servers whe=
re I
> >>don't need much CPU power for network workload.
> >=20
> >=20
> > I think simply that the RX queue size should be scaled by the numbe=
r
> > of queues we have.

There are few factors that can be considered when scaling the ring
sizes:
- Number of queues per device
- Number of devices
- Available amount of memory
- Others...

I'm thinking about adding a factor only according to the number of
queues - this will still cause issues for systems with many ports. Does
that sound reasonable or not enough? Do you think the number of devices
or even the amount of free memory should be considered?

Thanks,
Eilon

> > If people want enormous RX ring sizes even when there are many queu=
es,
> > they can use ethtool to get that.
> >=20
> > Taking up 130MB of memory per-card, just for RX packet buffers, is
> > certainly over the top.
>=20
> It gets even better if one consideres JumboFrames...  that said, I've=
 had=20
> customer contacts (indirect) where they were quite keep to have a rin=
g size of=20
> at least 2048 packets - I never could get it confirmed, but I suspect=
 they had=20
> applications/systems that might "go out to lunch" for long-enough per=
iods of=20
> time they wanted that degree of FIFO.
>=20
> Doesn't necessarily change "what should be the defaults" much but the=
re it is.
>=20
> rick jones
>=20



