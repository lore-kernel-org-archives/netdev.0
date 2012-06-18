From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next.git 1/4 (v5)] phy: add the EEE support and the way
 to access to the MMD registers.
Date: Mon, 18 Jun 2012 08:23:30 +0200
Message-ID: <4FDEC962.4040904@st.com>
References: <1339574463-1207-1-git-send-email-peppe.cavallaro@st.com>   <1339574463-1207-2-git-send-email-peppe.cavallaro@st.com>  <1339630137.2612.83.camel@bwh-desktop.uk.solarflarecom.com>  <4FDAD0C8.6000307@st.com> <1339778248.2555.9.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	rayagond@vayavyalabs.com, davem@davemloft.net,
	yuvalmin@broadcom.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:41252 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751104Ab2FRGYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 02:24:19 -0400
In-Reply-To: <1339778248.2555.9.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/15/2012 6:37 PM, Ben Hutchings wrote:
> On Fri, 2012-06-15 at 08:06 +0200, Giuseppe CAVALLARO wrote:
>> Hello Ben
>>
>> On 6/14/2012 1:28 AM, Ben Hutchings wrote:
> [...]
>>> But you also use this condition to decide whether to enable TX LPI,=
 so
>>> it's important that it does match the specification (=C2=A778.3) fo=
r whether
>>> EEE is supported - but it doesn't.  You need to work out what mode =
was
>>> autonegotiated, then check that the relevant bit is set in both our=
 EEE
>>> advertising (*not* supported) and the LP EEE advertising masks.
>>
>> I've some doubts and, before resending the patch, I kindly ask you s=
ome
>> further details just on this point.
>>
>> In the code, I check if the EEE is supported and on GMII, MII and RG=
MII
>> and duplex mode; in case of success the Ethernet driver can enable t=
he
>> TX LPI.
>> Indeed, I am only using the 3.20 and 7.61 registers w/o looking at t=
he
>> 7.60. So this should be fixed, shouldn't it?
>> Am I missing anything else?
>> What do you mean when say that it doesn't match the specification
>> (=C2=A778.3)? I'm pointing to the '78.3 Capabilities Negotiation' ch=
apter of
>> the IEEE802-3az, is it ok?
>=20
> Yes that's what I mean.  As I read it, you need to check which link m=
ode
> was autonegotiated, then the corresponding bit in 7.60 and 7.61.  If
> they're both set then EEE is supported on the current link.  (But, le=
t
> me repeat, I have not done any work on implementing EEE, so it's
> entirely possible that I have misunderstood some things.)

Ben, you are right, the code needs this kind of check.
=46or example, my phy device only supports the 100BASE-TX and, with the
current implementation, the phy_init_eee could enable the EEE on 10/ful=
l
link mode and it is not good.

I'll send the new patch asap.

Thanks
Peppe

>=20
> Ben.
>=20
