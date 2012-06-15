From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next.git 1/4 (v5)] phy: add the EEE support and the way to
 access to the MMD registers.
Date: Fri, 15 Jun 2012 17:37:28 +0100
Message-ID: <1339778248.2555.9.camel@bwh-desktop.uk.solarflarecom.com>
References: <1339574463-1207-1-git-send-email-peppe.cavallaro@st.com>
	  <1339574463-1207-2-git-send-email-peppe.cavallaro@st.com>
	 <1339630137.2612.83.camel@bwh-desktop.uk.solarflarecom.com>
	 <4FDAD0C8.6000307@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <eric.dumazet@gmail.com>,
	<rayagond@vayavyalabs.com>, <davem@davemloft.net>,
	<yuvalmin@broadcom.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29426 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750910Ab2FOQhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2012 12:37:33 -0400
In-Reply-To: <4FDAD0C8.6000307@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-06-15 at 08:06 +0200, Giuseppe CAVALLARO wrote:
> Hello Ben
>=20
> On 6/14/2012 1:28 AM, Ben Hutchings wrote:
[...]
> > But you also use this condition to decide whether to enable TX LPI,=
 so
> > it's important that it does match the specification (=C2=A778.3) fo=
r whether
> > EEE is supported - but it doesn't.  You need to work out what mode =
was
> > autonegotiated, then check that the relevant bit is set in both our=
 EEE
> > advertising (*not* supported) and the LP EEE advertising masks.
>=20
> I've some doubts and, before resending the patch, I kindly ask you so=
me
> further details just on this point.
>=20
> In the code, I check if the EEE is supported and on GMII, MII and RGM=
II
> and duplex mode; in case of success the Ethernet driver can enable th=
e
> TX LPI.
> Indeed, I am only using the 3.20 and 7.61 registers w/o looking at th=
e
> 7.60. So this should be fixed, shouldn't it?
> Am I missing anything else?
> What do you mean when say that it doesn't match the specification
> (=C2=A778.3)? I'm pointing to the '78.3 Capabilities Negotiation' cha=
pter of
> the IEEE802-3az, is it ok?

Yes that's what I mean.  As I read it, you need to check which link mod=
e
was autonegotiated, then the corresponding bit in 7.60 and 7.61.  If
they're both set then EEE is supported on the current link.  (But, let
me repeat, I have not done any work on implementing EEE, so it's
entirely possible that I have misunderstood some things.)

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
