From: Ross Brattain <ross.b.brattain@intel.com>
Subject: Re: [PATCH 2/2] bridge: allow forwarding some link local frames
Date: Mon, 17 Oct 2011 16:07:15 -0700
Message-ID: <20111017160715.000024eb@unknown>
References: <20111004041444.793960297@vyatta.com>
	<20111004041509.292932641@vyatta.com>
	<CAF5U64AYRhZ1e0=-RhSemgaOnewTQSpAoRY2FUrFr252PG98Pw@mail.gmail.com>
	<20111017135323.00003ee5@unknown>
	<CAF5U64D36-Kb+KN6kNskE6yaPW6G_Ue8-OcskseKWoBEPQdVUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ed Swierk <eswierk@bigswitch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55264 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754524Ab1JQXHS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 19:07:18 -0400
In-Reply-To: <CAF5U64D36-Kb+KN6kNskE6yaPW6G_Ue8-OcskseKWoBEPQdVUA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Oct 2011 14:09:34 -0700
Ed Swierk <eswierk@bigswitch.com> wrote:

> Interesting, I didn't realize LLDP could use any of those addresses.
>=20
> I finally got a peek at the hot-off-the-presses IEEE 802.1Q-2011, and
> notice that 01-80-C2-00-00-0E is now assigned as "Individual LAN Scop=
e
> group address, Nearest bridge group address" rather than dedicated to
> LLDP specifically.
>=20

802.1AB-2009  Section 7.1 Destination address:

NOTE 8=E2=80=94The destination MAC address used by a given LLDP agent d=
efines only the scope of transmission and the
intended recipient(s) of the LLDPDUs; it plays no part in protocol iden=
tification. In particular, the group MAC addresses
identified in Table 7-1 are not used exclusively by LLDP; other protoco=
ls that require to use a similar transmission scope
are free to use the same addresses.

> Since our application is generating the LLDP frames we could change i=
t
> to use -00 or -03 and let the Linux bridge drop the -0E frames.
>=20

If you control both end stations you could use the optional group MAC a=
ddress support, or unicast LLDP.

802.1AB-2009  Section 7.1 Destination address:

In addition to the prescribed support for standard group MAC addresses =
shown in Table 7-1,
implementations of LLDP may support the following destination addresses=
 for LLDPDUs:
d) Any group MAC address.
e) Any individual MAC address.
Support for the use of each of these destination addresses, for both tr=
ansmission and reception of LLDPDUs,
is either mandatory, recommended, permitted, or not permitted, accordin=
g to the type of system in which
LLDP is implemented, as shown in Table 7-2.

I have no idea if any LLDP agents support the optional group MAC addres=
ses.

--
Ross
