From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [PATCH net-next 3/8] bonding: add downdelay netlink support
Date: Thu, 7 Nov 2013 13:59:56 -1000
Message-ID: <5C31F7A9-945E-4DA5-A2E2-92AE0A556970@cumulusnetworks.com>
References: <20131107094308.15846.58301.stgit@monster-03.cumulusnetworks.com> <3470.1383843910@death.nxdomain>
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1816\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Veaceslav Falico <vfalico@redhat.com>, andy@greyhouse.net,
	netdev@vger.kernel.org,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:51239 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085Ab3KHAAI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 19:00:08 -0500
In-Reply-To: <3470.1383843910@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Nov 7, 2013, at 7:05 AM, Jay Vosburgh <fubar@us.ibm.com> wrote:

> Scott Feldman <sfeldma@cumulusnetworks.com> wrote:
>=20
>> +int bond_option_downdelay_set(struct bonding *bond, int downdelay)
>> +{
>> +	if (!(bond->params.miimon)) {
>> +		pr_err("%s: Unable to set down delay as MII monitoring is disable=
d\n", bond->dev->name);
>> +		return -EPERM;
>> +	}
>=20
> 	I would argue that it is better to permit this option to be set
> at any time, regardless of whether miimon is enabled or not.  This
> removes an ordering constraint and makes things generally easier to d=
eal
> with.  Setting the option has no effect if miimon is not set, but tha=
t's
> ok.
>=20
> 	My comment here would also apply to other options that are
> "secondary," in the sense that they affect the behavior of other opti=
ons
> or modes, e.g., updelay, arp_validate (in another path of this series=
),
> arp_ip_targets, etc.
>=20
> 	I'm aware that this is simply duplicating the existing behavior
> of the sysfs API, but I'd be in favor of changing that, too.  These
> limitations are a holdover from the module paramters days, and should
> have been made more flexible a long time ago.

What I=92d like to propose, and I hope that you=92ll agree, is we tackl=
e this in two phases.  The first phase is to finish the current duplica=
tion effort to enable netlink equivalents of the attributes in sysfs.  =
This is a fairly mechanical process, preserving existing behavior as yo=
u point out, and keeps the patches single-minded and easy to review.

The second phase is to revisit ordering constraints and find places whe=
re we can remove constraints or streamline the dependency checks.

Sound like a plan?

-scott
