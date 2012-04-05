From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [net-next 3/3] ixgbe: add syfs interface for to export read
 only driver information
Date: Thu, 5 Apr 2012 23:52:40 +0000
Message-ID: <81212BCD-D022-4B71-955A-96B6C8E2A5DC@intel.com>
References: <1333622878-3855-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1333622878-3855-4-git-send-email-jeffrey.t.kirsher@intel.com>
 <4F7D8DD4.5080205@openwrt.org>
 <1333643525.2652.10.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <florian@openwrt.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"<davem@davemloft.net>" <davem@davemloft.net>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	"<gospo@redhat.com>" <gospo@redhat.com>,
	"<sassmann@redhat.com>" <sassmann@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:24106 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753260Ab2DEXwn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 19:52:43 -0400
In-Reply-To: <1333643525.2652.10.camel@bwh-desktop.uk.solarflarecom.com>
Content-Language: en-US
Content-ID: <B2E5C56598FCBB439062E308BB7782D4@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Apr 5, 2012, at 9:32 AM, Ben Hutchings wrote:

> On Thu, 2012-04-05 at 14:19 +0200, Florian Fainelli wrote:
>> Hi,
>>=20
>> Le 04/05/12 12:47, Jeff Kirsher a =E9crit :
>>> From: Don Skidmore<donald.c.skidmore@intel.com>
>>>=20
>>> This patch exports non-thermal (which was done via hwmon in an earl=
ier
>>> patch) data to syfs.  All of the fields are read only as this inter=
face
>>> is to only export driver data.
>>>=20
>>> Signed-off-by: Don Skidmore<donald.c.skidmore@intel.com>
>>> Tested-by: Stephen Ko<stephen.s.ko@intel.com>
>>> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
>>> ---
>>=20
>> I only looked briefly at the exported attributes, but most of them c=
an=20
>> already be queried using ethtool, can't they?
> [...]
>=20
> I agree, it looks like most of these are:
>=20
> (1) already exposed through ethtool commands (ETHTOOL_GSET,
> ETHTOOL_GDRVINFO, ETHTOOL_GLINK and ETHTOOL_GPERMADDR), or
> (2) already exposed through rtnetlink or the net device in sysfs, or
> (3) statistics that should be exposed through ETHTOOL_GSTATS
>=20
> I imagine there are some that don't fall into those categories, but I
> don't see why they should *all* be exposed in a non-standard and/or
> redundant way.


The redundancy with ethtool doesn't bother me much, because I think sys=
fs is a more general way to export driver information, and I find it ve=
ry convenient to get as much as is practical from a single source. I re=
ally like doing "grep . * */*" in sysfs and getting as much information=
 as possible about a driver.

That said, there does appear to be duplication with some existing sysfs=
 statistics, which should not be needed, and I think the volume of code=
 in the implementation can be reduced as well.

--=20
Mark Rustad, LAN Access Division, Intel Corporation
