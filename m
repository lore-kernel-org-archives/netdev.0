From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [net-next 08/12] ixgb: convert to new VLAN model
Date: Fri, 7 Jan 2011 12:30:31 -0700
Message-ID: <EA929A9653AAE14F841771FB1DE5A136602DB8ADDA@rrsmsx501.amr.corp.intel.com>
References: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1294360199-9860-9-git-send-email-jeffrey.t.kirsher@intel.com>
 <AANLkTik1rCFRtBWov5f8yfU+4JZnbzLHgcmRC1y_+TDP@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gosp@redhat.com" <gosp@redhat.com>,
	"bphilips@novell.com" <bphilips@novell.com>
To: Jesse Gross <jesse@nicira.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:20031 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753607Ab1AGTac convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jan 2011 14:30:32 -0500
In-Reply-To: <AANLkTik1rCFRtBWov5f8yfU+4JZnbzLHgcmRC1y_+TDP@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesse Gross wrote:
> On Thu, Jan 6, 2011 at 7:29 PM,  <jeffrey.t.kirsher@intel.com> wrote:
>> +static int ixgb_set_flags(struct net_device *netdev, u32 data) +{
>> + =A0 =A0 =A0 struct ixgb_adapter *adapter =3D netdev_priv(netdev); =
+ =A0 =A0 =A0
>> bool need_reset; + =A0 =A0 =A0 int rc;
>> +
>> + =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0* TX vlan insertion does not work per HW design whe=
n Rx
>> stripping is + =A0 =A0 =A0 =A0* disabled. =A0Disable txvlan when rxv=
lan is
>> off. + =A0 =A0 =A0 =A0*/ + =A0 =A0 =A0 if ((data & ETH_FLAG_RXVLAN) =
!=3D
>> (netdev->features & NETIF_F_HW_VLAN_RX)) + =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 data ^=3D
>> ETH_FLAG_TXVLAN;=20
>=20
> Does this really do the right thing?  If the RX vlan setting is
> changed, it will do the opposite of what the user requested for TX
> vlan?
>=20
> So if I start with both on (the default) and turn them both off in on=
e
> command (a valid setting), I will get RX off and TX on (an invalid
> setting).
>=20
> Why not:
>=20
> if (!(data & ETH_FLAG_RXVLAN))
> =A0 =A0 =A0 =A0 data &=3D ~ETH_FLAG_TXVLAN;

Ah, you're right. We missed this in testing.

I will spin another patch.

Thanks for all your help.

Emil