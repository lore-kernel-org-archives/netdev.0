From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison
 overwritten
Date: Tue, 05 Jul 2011 18:47:21 +0200
Message-ID: <1309884441.2271.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1309839928.2720.23.camel@edumazet-laptop>
	 <CAB9v_DEOhZh37aqx1qrLnrz5+tqjcjgBx-DP6M_0NkygZ1LjcQ@mail.gmail.com>
	 <1309840708.2720.31.camel@edumazet-laptop>
	 <CAB9v_DFM8PcujUB-YzcK49DS7T6Bz2FLDtkVdEYt8an1oPYVFw@mail.gmail.com>
	 <1309842642.2720.36.camel@edumazet-laptop>
	 <CAB9v_DEiPFzQt-TgeVC3r3Y7YFwApLK_NHkDahFOKpibtABrZg@mail.gmail.com>
	 <1309844009.2720.39.camel@edumazet-laptop>
	 <1309845573.2720.41.camel@edumazet-laptop>
	 <20110705160531.GC2959@hmsreliant.think-freely.org>
	 <1309882352.2271.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110705164202.GD2959@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Zaytsev <alexey.zaytsev@gmail.com>,
	Michael =?ISO-8859-1?Q?B=FCsch?= <m@bues.ch>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46597 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755903Ab1GEQrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 12:47:36 -0400
Received: by wyg8 with SMTP id 8so4127899wyg.19
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 09:47:35 -0700 (PDT)
In-Reply-To: <20110705164202.GD2959@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 juillet 2011 =C3=A0 12:42 -0400, Neil Horman a =C3=A9crit :
> On Tue, Jul 05, 2011 at 06:12:32PM +0200, Eric Dumazet wrote:

> > So all descriptors before prod are guaranteed to be ready for host
> > consume... Fact that a dma access is running on 'next descriptor' s=
hould
> > be irrelevant.
> >=20
> But we handle more than one descriptor per b44_rx call - theres a whi=
le loop in
> there where we do advance to the next descriptor.

Yes, but we advance up to 'prod', which is the very last safe
descriptor.

If hardware advertises descriptor X being ready to be handled by host,
while DMA on this X descriptor is not yet finished, this would be a
really useless hardware ;)



