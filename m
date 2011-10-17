From: Ed Swierk <eswierk@bigswitch.com>
Subject: Re: [PATCH 2/2] bridge: allow forwarding some link local frames
Date: Mon, 17 Oct 2011 16:36:07 -0700
Message-ID: <CAF5U64A-o0WHMGZ=x3kRd-bOnscra=oLu8uFju=HB=CF4zNiXQ@mail.gmail.com>
References: <20111004041444.793960297@vyatta.com> <20111004041509.292932641@vyatta.com>
 <CAF5U64AYRhZ1e0=-RhSemgaOnewTQSpAoRY2FUrFr252PG98Pw@mail.gmail.com>
 <20111017135323.00003ee5@unknown> <CAF5U64D36-Kb+KN6kNskE6yaPW6G_Ue8-OcskseKWoBEPQdVUA@mail.gmail.com>
 <20111017160715.000024eb@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ross Brattain <ross.b.brattain@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:42269 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754772Ab1JQXgt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 19:36:49 -0400
Received: by vcge1 with SMTP id e1so17694vcg.19
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2011 16:36:48 -0700 (PDT)
In-Reply-To: <20111017160715.000024eb@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 17, 2011 at 4:07 PM, Ross Brattain
<ross.b.brattain@intel.com> wrote:
> 802.1AB-2009 =C2=A0Section 7.1 Destination address:
>
> NOTE 8=E2=80=94The destination MAC address used by a given LLDP agent=
 defines only the scope of transmission and the
> intended recipient(s) of the LLDPDUs; it plays no part in protocol id=
entification. In particular, the group MAC addresses
> identified in Table 7-1 are not used exclusively by LLDP; other proto=
cols that require to use a similar transmission scope
> are free to use the same addresses.
> ...
> If you control both end stations you could use the optional group MAC=
 address support, or unicast LLDP.
>
> 802.1AB-2009 =C2=A0Section 7.1 Destination address:
>
> In addition to the prescribed support for standard group MAC addresse=
s shown in Table 7-1,
> implementations of LLDP may support the following destination address=
es for LLDPDUs:
> d) Any group MAC address.
> e) Any individual MAC address.
> Support for the use of each of these destination addresses, for both =
transmission and reception of LLDPDUs,
> is either mandatory, recommended, permitted, or not permitted, accord=
ing to the type of system in which
> LLDP is implemented, as shown in Table 7-2.

Thanks for the references. I need to read the updated standards specs
before jumping to conclusions...

> I have no idea if any LLDP agents support the optional group MAC addr=
esses.

In our application we're both generating and consuming the LLDP
frames. We're worried about standards conformance to the extent that
we don't break other tools that might receive the LLDP frames we
generate. As long as they don't care about the destination MAC address
of the frames they receive (and they shouldn't), it's definitely
feasible for us to use the "nearest customer bridge" address
(01-80-C2-00-00-00) to ensure our LLDP frames traverse Linux bridges.

--Ed
