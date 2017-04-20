From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [net-next 04/14] i40e: dump VF information in debugfs
Date: Thu, 20 Apr 2017 20:12:59 +0000
Message-ID: <BL2PR07MB23064B547F325DD002E513FC8D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <BL2PR07MB2306DEC60F085B88BA230C3A8D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
        <20170420.115153.1510206006505486594.davem@davemloft.net>
        <BL2PR07MB23063D7F1341E629E9345F578D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20170420.125841.799913763607507081.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "jiri@resnulli.us" <jiri@resnulli.us>,
        "gerlitz.or@gmail.com" <gerlitz.or@gmail.com>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
        "mitch.a.williams@intel.com" <mitch.a.williams@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>,
        "Dupuis, Chad" <Chad.Dupuis@cavium.com>,
        "Rangankar, Manish" <Manish.Rangankar@cavium.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0077.outbound.protection.outlook.com ([104.47.33.77]:18880
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1032023AbdDTUND (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 16:13:03 -0400
In-Reply-To: <20170420.125841.799913763607507081.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > the HW pipeline itself can't be abstracted in this case.
>=20
> I've heard that argument before, and I'm glad Jiri didn't drink the koola=
ide
> and instead wrote dpipe.

Perhaps "can't" was the wrong term to use, but I still believe there's an
inherent problem with applying the dpipe approach here.
dpipe abstraction is meant [And I admit that I'm not that familiar with its
fine-grain details, so feel free to correct me] to give an abstract
representation of functional things, I.e., bits in the HW pipeline the user
might care about and can gain something from sharing information
about it - decision-based statistics [such as in Jiri's initial submission]=
 being
an immediate candidate for benefiting from such.

For the case of debugging you *could* do the same, but at a huge
implementation and code-bloat costs -
Let's assume user doesn't use 'magic values' for debug gathering,
Instead having some HW abstraction it can manipulate intelligibly.
What it means is that level of configurability is limited by the complexity
of the abstraction, and you have to recall the vast majority of the
abstraction would be in-depth about HW-specific bridges and signals
the user cares nothing about [with the exception of debug-data collection].

I surely wouldn't want to write a million lines of code just to provide suc=
h
a detailed abstraction.


.
