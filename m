From: Jesse Gross <jesse@nicira.com>
Subject: Re: [net-next 08/12] ixgb: convert to new VLAN model
Date: Fri, 7 Jan 2011 10:41:18 -0500
Message-ID: <AANLkTik1rCFRtBWov5f8yfU+4JZnbzLHgcmRC1y_+TDP@mail.gmail.com>
References: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1294360199-9860-9-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Emil Tantilov <emil.s.tantilov@intel.com>,
	netdev@vger.kernel.org, gosp@redhat.com, bphilips@novell.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:51997 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753484Ab1AGPlT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jan 2011 10:41:19 -0500
Received: by pzk35 with SMTP id 35so1981386pzk.19
        for <netdev@vger.kernel.org>; Fri, 07 Jan 2011 07:41:19 -0800 (PST)
In-Reply-To: <1294360199-9860-9-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 6, 2011 at 7:29 PM,  <jeffrey.t.kirsher@intel.com> wrote:
> +static int ixgb_set_flags(struct net_device *netdev, u32 data)
> +{
> + =A0 =A0 =A0 struct ixgb_adapter *adapter =3D netdev_priv(netdev);
> + =A0 =A0 =A0 bool need_reset;
> + =A0 =A0 =A0 int rc;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* TX vlan insertion does not work per HW design when=
 Rx stripping is
> + =A0 =A0 =A0 =A0* disabled. =A0Disable txvlan when rxvlan is off.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if ((data & ETH_FLAG_RXVLAN) !=3D (netdev->features & N=
ETIF_F_HW_VLAN_RX))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 data ^=3D ETH_FLAG_TXVLAN;

Does this really do the right thing?  If the RX vlan setting is
changed, it will do the opposite of what the user requested for TX
vlan?

So if I start with both on (the default) and turn them both off in one
command (a valid setting), I will get RX off and TX on (an invalid
setting).

Why not:

if (!(data & ETH_FLAG_RXVLAN))
=A0 =A0 =A0 =A0 data &=3D ~ETH_FLAG_TXVLAN;
