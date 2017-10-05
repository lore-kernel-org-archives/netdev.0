From: Rodney Cummings <rodney.cummings@ni.com>
Subject: RE: [next-queue PATCH v4 3/4] net/sched: Introduce Credit Based
 Shaper (CBS) qdisc
Date: Thu, 5 Oct 2017 18:41:48 +0000
Message-ID: <CY1PR0401MB1536A44D0AB459BB9618664A92700@CY1PR0401MB1536.namprd04.prod.outlook.com>
References: <20171004002831.18371-4-vinicius.gomes@intel.com>
        <20171004063650.GA1895@nanopsycho>
        <CAEYbN3RjUXGMyxo0t88-ASNVEVQdfXkMzBbMtMHAhqWScOO=Cg@mail.gmail.com>
 <20171005.112909.2052593524154643514.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "jiri@resnulli.us" <jiri@resnulli.us>,
        "vinicius.gomes@intel.com" <vinicius.gomes@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "andre.guedes@intel.com" <andre.guedes@intel.com>,
        "ivan.briano@intel.com" <ivan.briano@intel.com>,
        "jesus.sanchez-palencia@intel.com" <jesus.sanchez-palencia@intel.com>,
        "boon.leong.ong@intel.com" <boon.leong.ong@intel.com>,
        "richardcochran@gmail.com" <richardcochran@gmail.com>,
        "henrik@austad.us" <henrik@austad.us>
To: David Miller <davem@davemloft.net>,
        "levipearson@gmail.com" <levipearson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00010702.pphosted.com ([148.163.156.75]:52082 "EHLO
        mx0b-00010702.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751432AbdJESmB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 14:42:01 -0400
In-Reply-To: <20171005.112909.2052593524154643514.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The IEEE Std 802.1Q specs for credit-based shaper require precise transmit =
decisions
within a 125 microsecond window of time.

Even with the Preempt RT patch or similar enhancements, that isn't very pra=
ctical
as software-only. I doubt that software would conform to the standard's
requirements.

This is analogous to memory, or CPU.
.

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, October 5, 2017 1:29 PM
> To: levipearson@gmail.com
> Cc: jiri@resnulli.us; vinicius.gomes@intel.com; netdev@vger.kernel.org;
> intel-wired-lan@lists.osuosl.org; jhs@mojatatu.com;
> xiyou.wangcong@gmail.com; andre.guedes@intel.com; ivan.briano@intel.com;
> jesus.sanchez-palencia@intel.com; boon.leong.ong@intel.com;
> richardcochran@gmail.com; henrik@austad.us; Rodney Cummings
> <rodney.cummings@ni.com>
> Subject: Re: [next-queue PATCH v4 3/4] net/sched: Introduce Credit Based
> Shaper (CBS) qdisc
>=20
> From: Levi Pearson <levipearson@gmail.com>
> Date: Thu, 5 Oct 2017 12:09:32 -0600
>=20
> > It would be a shame if this were blocked due to a missing software
> > implementation.
>=20
> Quite the contrary, I think a software implementation is a minimum
> requirement for inclusion of this feature.
>=20
> Without a software implementation, there is no clear definition of
> what is supposed to happen, and no clear way for people to test those
> expectations unless they have the specific hardware.
>=20
> I completely agree with Jiri.  Hardware offload first is _not_ how
> we do things in the Linux networking.
