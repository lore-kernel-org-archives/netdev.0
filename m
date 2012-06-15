From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next.git 1/4 (v5)] phy: add the EEE support and the way
 to access to the MMD registers.
Date: Fri, 15 Jun 2012 08:06:00 +0200
Message-ID: <4FDAD0C8.6000307@st.com>
References: <1339574463-1207-1-git-send-email-peppe.cavallaro@st.com>  <1339574463-1207-2-git-send-email-peppe.cavallaro@st.com> <1339630137.2612.83.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	rayagond@vayavyalabs.com, davem@davemloft.net,
	yuvalmin@broadcom.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:57389 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751379Ab2FOGGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2012 02:06:46 -0400
In-Reply-To: <1339630137.2612.83.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Ben

On 6/14/2012 1:28 AM, Ben Hutchings wrote:

[snip]

>> > + */
>> > +int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
>> > +{
>> > +	int ret =3D -EPROTONOSUPPORT;
>> > +
>> > +	/* According to 802.3az,the EEE is supported only in full duplex=
-mode.
>> > +	 * Also EEE feature is active when core is operating with MII, G=
MII
>> > +	 * or RGMII.
>> > +	 */
>> > +	if ((phydev->duplex =3D=3D DUPLEX_FULL) &&
>> > +	    ((phydev->interface =3D=3D PHY_INTERFACE_MODE_MII) ||
>> > +	    (phydev->interface =3D=3D PHY_INTERFACE_MODE_GMII) ||
>> > +	    (phydev->interface =3D=3D PHY_INTERFACE_MODE_RGMII))) {
>> > +		int eee_cap, eee_link;
>> > +
>> > +		/* EEE ability must be supported in both local and remote
>> > +		 * PHY devices.
>> > +		 */
>> > +		eee_cap =3D phy_read_mmd_indirect(phydev->bus, MDIO_AN_EEE_LPAB=
LE,
>> > +						MDIO_MMD_AN, phydev->addr);
>> > +		if (eee_cap < 0)
>> > +			return eee_cap;
>> > +
>> > +		eee_link =3D phy_read_mmd_indirect(phydev->bus, MDIO_PCS_EEE_AB=
LE,
>> > +						 MDIO_MMD_PCS, phydev->addr);
>> > +		if (eee_link < 0)
>> > +			return eee_link;
>> > +
>> > +		if (eee_cap && eee_link) {
> I don't see any harm in setting the 'clock stop' bit if requested, ev=
en
> if EEE is not supported and therefore we will never receive LPI from =
the
> link partner.

ok

> But you also use this condition to decide whether to enable TX LPI, s=
o
> it's important that it does match the specification (=C2=A778.3) for =
whether
> EEE is supported - but it doesn't.  You need to work out what mode wa=
s
> autonegotiated, then check that the relevant bit is set in both our E=
EE
> advertising (*not* supported) and the LP EEE advertising masks.

I've some doubts and, before resending the patch, I kindly ask you some
further details just on this point.

In the code, I check if the EEE is supported and on GMII, MII and RGMII
and duplex mode; in case of success the Ethernet driver can enable the
TX LPI.
Indeed, I am only using the 3.20 and 7.61 registers w/o looking at the
7.60. So this should be fixed, shouldn't it?
Am I missing anything else?
What do you mean when say that it doesn't match the specification
(=C2=A778.3)? I'm pointing to the '78.3 Capabilities Negotiation' chapt=
er of
the IEEE802-3az, is it ok?=02=03=03=03=04=05=06=07=04=08

=03=03=03=04Thanks for your feedback in advance.

peppe
