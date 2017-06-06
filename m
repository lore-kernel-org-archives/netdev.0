From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next 00/16] nfp: ctrl vNIC
Date: Tue, 6 Jun 2017 09:35:08 +0000
Message-ID: <BLUPR0701MB2004F8E6F28C1181003BEA788DCB0@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <20170606000157.17556-1-jakub.kicinski@netronome.com>
 <20170606061610.GA1911@nanopsycho>
 <20170606002105.7a84432f@cakuba.netronome.com>
 <20170606082336.GB1911@nanopsycho>
 <20170606020945.05a9bcc5@cakuba.netronome.com>
 <20170606091757.GC1911@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "oss-drivers@netronome.com" <oss-drivers@netronome.com>
To: Jiri Pirko <jiri@resnulli.us>, Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0051.outbound.protection.outlook.com ([104.47.34.51]:50928
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751390AbdFFJfM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Jun 2017 05:35:12 -0400
In-Reply-To: <20170606091757.GC1911@nanopsycho>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> >> >What were your plans with pre-netdev config?
> >>
> >> We need to pass come initial resource division. Generally the
> >> consensus is to have these options exposed through devlink, let the
> >> user configure them all and then to have a trigger that would cause
> >> driver re-orchestration according to the new values. The flow would
> >> look like
> >> this:
> >>
> >> -driver loads with defaults, inits hw and instantiates netdevs
> >> -driver exposes config options via devlink -user sets up the options
> >> -user pushes the "go" trigger -upon the trigger command, devlink
> >> calls the driver re-init callback -driver shuts down the current
> >> instances, re-initializes hw,  re-instantiates the netdevs
> >>
> >> Makes sense?
> >
> >I like the idea of a "go"/apply/reload trigger and extending devlink.
> >Do you plan on adding a way to persist the settings?  I'm concerned NIC
> >users may want to boot into the right mode once it's set, without
> >reloads and reconfigs upon boot.  Also is there going to be a way to
> >query the pending/running config?  Sounds like we may want to expose
> >three value sets - persistent/default, running and pending/to be
> >applied.

> I don't think it is a good idea to introduce any kind of configuration
> persistency in HW. I believe that user is the master and he has all neede=
d
> info. He can store it persistently, but it is up to him.
>=20
> So basicaly during boot, we need the devlink configuration to happen earl=
y
> on, before the netdevices get configured. udev? Not sure how exactly to d=
o
> this. Have to ask around :)

Thinking about use cases where we'd want information available at probe tim=
e,
it might have been even better to have it separated from the netdevice,
e.g., providing clients with node to configure (generic?) information on to=
p of
their PCI nodes.
