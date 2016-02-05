From: Lubomir Rintel <lkundrak@v3.sk>
Subject: Re: [PATCH 1/3] ifb: make device count build-time configurable
Date: Fri, 05 Feb 2016 16:02:12 +0100
Message-ID: <1454684532.2779.5.camel@v3.sk>
References: <1452599804-27284-1-git-send-email-lkundrak@v3.sk>
	 <5694F7BA.3040402@mojatatu.com> <20160112104437.0e1a841b@xeon-e3>
	 <20160112.155440.538873882796833417.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jhs@mojatatu.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shell.v3.sk ([92.60.52.57]:53795 "EHLO shell.v3.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750853AbcBEPC1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 10:02:27 -0500
In-Reply-To: <20160112.155440.538873882796833417.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-01-12 at 15:54 -0500, David Miller wrote:
> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Tue, 12 Jan 2016 10:44:37 -0800
>=20
> > On Tue, 12 Jan 2016 07:55:22 -0500
> > Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> >=C2=A0
> >> On 16-01-12 06:56 AM, Lubomir Rintel wrote:
> >> > The devices can be created at run-time for quite some time
> already and the
> >> > load-time device creation collides with attempts to create the
> device of
> >> > the same name:
> >> >
> >> >=C2=A0=C2=A0=C2=A0 # rmmod ifb
> >> >=C2=A0=C2=A0=C2=A0 # ip link add ifb0 type ifb
> >> >=C2=A0=C2=A0=C2=A0 RTNETLINK answers: File exists
> >> >
> >> > This is pretty much the same situation as was with the block
> loop devices
> >> > which was solved by adding a build-time configuration that the
> >> > distributions could use as they deem fit while keeping the
> default for
> >> > compatibility.
> >> >
> >> > Let's do that here as well.
> >> >
> >> > Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>
> >>=C2=A0
> >> I guess module options are frowned upon. so:
> >=C2=A0
> > I would prefer that this were done with a module parameter, the
> same as dummy.
> > Only developers build their own configured kernels. Having the
> value set later
> > at module load time is preferable.
>=20
> I like this even less, it means tools behave significantly
> differently
> based upon what module options were passed to the kernel.
>=20
> Module options really should not change kernel behavior like this..

The module option is already there. It's defaults (creating the devices
noone asked for and that potentially collide with what the user tried
to create) are what we find bothersome.

Lubo
