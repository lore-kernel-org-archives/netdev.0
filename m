From: Ed Swierk <eswierk@bigswitch.com>
Subject: Re: [PATCH 2/2] bridge: allow forwarding some link local frames
Date: Mon, 17 Oct 2011 14:09:34 -0700
Message-ID: <CAF5U64D36-Kb+KN6kNskE6yaPW6G_Ue8-OcskseKWoBEPQdVUA@mail.gmail.com>
References: <20111004041444.793960297@vyatta.com> <20111004041509.292932641@vyatta.com>
 <CAF5U64AYRhZ1e0=-RhSemgaOnewTQSpAoRY2FUrFr252PG98Pw@mail.gmail.com> <20111017135323.00003ee5@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ross Brattain <ross.b.brattain@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:39632 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754099Ab1JQVKP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 17:10:15 -0400
Received: by vws1 with SMTP id 1so2966412vws.19
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2011 14:10:14 -0700 (PDT)
In-Reply-To: <20111017135323.00003ee5@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Interesting, I didn't realize LLDP could use any of those addresses.

I finally got a peek at the hot-off-the-presses IEEE 802.1Q-2011, and
notice that 01-80-C2-00-00-0E is now assigned as "Individual LAN Scope
group address, Nearest bridge group address" rather than dedicated to
LLDP specifically.

Since our application is generating the LLDP frames we could change it
to use -00 or -03 and let the Linux bridge drop the -0E frames.

--Ed

On Mon, Oct 17, 2011 at 1:53 PM, Ross Brattain
<ross.b.brattain@intel.com> wrote:
> On Mon, 17 Oct 2011 07:35:53 -0700
> Ed Swierk <eswierk@bigswitch.com> wrote:
>
>> Why is forwarding LLDP (01-80-C2-00-00-0E) frames forbidden? I'm
>> testing LLDP in a virtual topology and need the bridge to forward
>> them.
>>
>> If we're worried about standards, there is justification for allowin=
g
>> forwarding of LLDP frames. 802.1d-2005 specifies two classes of
>> bridge, customer (C-VLAN) and provider (S-VLAN). Customer bridge is
>> just new terminology for what was previously just called an
>> 802.1d-compliant bridge, while provider bridge is a new class that
>> transparently forwards certain control frames.
>
> 01-80-C2-00-00-0E should not pass the physical link. =C2=A0If it does=
 it will affect PFC 802.1Qbb and ETS 802.1Qaz.
>
> 802.1AB-2009 is more specific. =C2=A0See Table 7-1 Group MAC addresse=
s used by LLDP:
>
> Nearest bridge: 01-80-C2-00-00-0E
> Propagation constrained to a single physical link; stopped by all typ=
es of bridge
>
> Nearest non-TPMR bridge: 01-80-C2-00-00-03
> Propagation constrained by all bridges other than TPMRs; intended for=
 use within provider bridged networks
>
> Nearest Customer Bridge: 01-80-C2-00-00-00
> Propagation constrained by customer bridges; this gives the same cove=
rage as a customer-customer MACSec connection
>
>
> --
> Ross
>
