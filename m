From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 1/3] vlan: Do not support clearing VLAN_FLAG_REORDER_HDR
Date: Tue, 24 May 2011 08:17:05 -0700
Message-ID: <4DDBCBF1.3010102@candelatech.com>
References: <4DDAB72B.9050101@gmail.com> <4DDAC26C.2070601@candelatech.com>	<20110523140048.777fb378@nehalam>	<20110523.172047.1438754754048434316.davem@davemloft.net>	<m1y61x2htp.fsf@fess.ebiederm.org> <4DDADE52.8000008@candelatech.com> <m1boyt10n4.fsf@fess.ebiederm.org> <4DDB3226.8010404@candelatech.com> <4DDB5A3F.8050007@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org, jpirko@redhat.com,
	xiaosuo@gmail.com, netdev@vger.kernel.org, kaber@trash.net,
	fubar@us.ibm.com, eric.dumazet@gmail.com, andy@greyhouse.net,
	jesse@nicira.com
To: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:44527 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755951Ab1EXPRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 11:17:33 -0400
In-Reply-To: <4DDB5A3F.8050007@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/24/2011 12:11 AM, Nicolas de Peslo=FCan wrote:
> Le 24/05/2011 06:20, Ben Greear a =E9crit :
> <snip>
>
>> Then I think we should put it back with pf_packet logic. Possibly wi=
th
>> a per-socket option to disable this and send it as only aux data if =
that
>> is more efficient.
>
> Why would we need a per-socket option for that?

I'd want the tag available at all times, but if it is a performance win=
 to
put the tag in 'aux data', then a socket could opt for that method.  Ot=
herwise,
the tag should always be inline in the packet.

>> If it turns out the NIC is not stripping VLAN tags for whatever reas=
on,
>> we might be able to optimize things so that it never does the HW emu=
lation
>> so that it never has to un-do it later.
>
> It might be very tricky to avoid any do-undo-redo situation. I will l=
atter try and describe all the possible situations: with/without hw-acc=
el, with/without a
> protocol handler registered on the parent interface, with/without a c=
hild interface build on top of a particular parent interface and with t=
he corresponding
> VLAN ID...

You could optimize for some common cases, but leave fix-up code in plac=
e to add/remove the
tag properly before handing the packet to user-space, filters, etc.

Thanks,
Ben

>
> Nicolas.


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
