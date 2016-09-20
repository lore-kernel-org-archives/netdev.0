From: "Elior, Ariel" <Ariel.Elior@cavium.com>
Subject: RE: [RFC 02/11] Add RoCE driver framework
Date: Tue, 20 Sep 2016 15:04:12 +0000
Message-ID: <CY1PR0701MB13376438A5767BC844EA35C290F70@CY1PR0701MB1337.namprd07.prod.outlook.com>
References: <516b98c7-477a-4890-0d92-529dc32f2c4e@mellanox.com>
 <CY4PR11MB1720F9B74BBF82D0779FAC8F97FF0@CY4PR11MB1720.namprd11.prod.outlook.com>
 <20160913063806.GP8812@leon.nu>
 <BL2PR07MB2306937C8C495DB80DA776CA8DFE0@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20160913101616.GT8812@leon.nu>
 <BL2PR07MB2306533A710B9EC40F56E8678DF10@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20160914130032.GB26069@leon.nu>
 <BL2PR07MB23066BBC4A019365A632E2FA8DF10@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20160915043716.GD26069@leon.nu>
 <BL2PR07MB23060C776EDAE92B84FCFB768DF00@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20160915054235.GK26069@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "dledford@redhat.com" <dledford@redhat.com>,
        Mark Bloch <markb@mellanox.com>,
        Ram Amrani <Ram.Amrani@qlogic.com>,
        David Miller <davem@davemloft.net>,
        Ariel Elior <Ariel.Elior@qlogic.com>,
        Michal Kalderon <Michal.Kalderon@qlogic.com>,
        Rajesh Borundia <rajesh.borundia@qlogic.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Leon Romanovsky <leon@kernel.org>,
        "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0054.outbound.protection.outlook.com ([104.47.42.54]:57408
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932340AbcITPhv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 11:37:51 -0400
In-Reply-To: <20160915054235.GK26069@leon.nu>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Leon Romanovsky [mailto:leon@kernel.org]
> On Thu, Sep 15, 2016 at 05:11:03AM +0000, Mintz, Yuval wrote:
> > > As a summary, I didn't see in your responses any real life example wh=
ere you will
> > > need global debug level for your driver.
> >
> > Not sure what you you're expecting - a list of BZs /private e-mails whe=
re
> > user reproductions were needed?
> > You're basically ignoring my claims that such are used, instead wanting
> > "evidence". I'm not going to try and produce any such.
>=20
> I asked an example and not evidence, where "modprobe your_driver
> debug=3D1" will be superior to "modprobe your_driver dyndbg=3D=3Dpmf".
>=20
> https://www.kernel.org/doc/Documentation/dynamic-debug-howto.txt
Hi,

dyndbg vs module param:
Dynamic debug has two very nice features: dynamic activation/configuration =
and per line/file/module/format activation. The module param has neither, b=
ut it does have a few merits which I am not sure dyndbg has:
(1)
It can activate printouts according to *flow*. A lot of thought has been pu=
t into associating the right printout in our driver at the right verbosity =
level with the right "flow tag" (e.g. QEDR_MSG_INIT, QEDR_MSG_QP). The modu=
le parameter accepts a bitmask which allows setting any subset of these flo=
ws. This means that with the correct values for the parameter I can open on=
ly "init" printouts, or only "Memory Region" printouts, even if these cross=
 multiple files / functions and don't share a common format. Presumably, on=
e would claim that we could add the "flow tag" to the format to every print=
out according to its flow, but that would encumber the printouts, and also =
doesn't scale well to printouts which belong to multiple flows, where the c=
urrent approach allows this (QEDR_MSG_SQ | QEDR_MSG_RQ).
(2)
As Yuval pointed out, there are users out there which have no trouble loadi=
ng a driver with a module parameter, at probe or at kernel boot, but would =
be at a loss in mounting debugfs and dumping a matchspec script into a node=
 there. As kernel developers, educating users is part of what we do, but it=
 comes with a cost.
(3)
debugfs can be compiled out of the kernel in some codesize sensitive enviro=
nments, or may not exist in an emergency shell or kdump kernel, whereas the=
 module parameter would always be there.

Simply allowing our module parameter mechanism to be dynamically activated =
is very straightforward - we planned on adding a debugfs node for that anyw=
ay. But I would keep the module parameter for the sake of those less capabl=
e users and also for when debugfs is not available as detailed in (3) above=
.

I certainly see the merits of joining an existing infrastructure instead of=
 implementing our own thing, but I would like to know if there are ways of =
obtaining the merits I listed for our approach via that infrastructure.

Leon, aside of commenting on the above, can you give an example of a driver=
 which in your opinion does a good job of using dyndbg?

Thanks,
Ariel
