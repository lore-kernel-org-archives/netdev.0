From: Rui <wirelesser@gmail.com>
Subject: Re: does intel X520-SR(ixgbe) support RSS on single VLAN?
Date: Tue, 25 Jan 2011 10:10:43 +0800
Message-ID: <AANLkTimFuUp+wbgJY4koZ96st1eBbFqVOxOPj4tU_-Ao@mail.gmail.com>
References: <AANLkTinuozfPcAZStV-a=siqcLesqPHnGhVh=QitOnQs@mail.gmail.com>
	<4D3DB248.5070802@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40191 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547Ab1AYCKo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 21:10:44 -0500
Received: by wyb28 with SMTP id 28so4797593wyb.19
        for <netdev@vger.kernel.org>; Mon, 24 Jan 2011 18:10:43 -0800 (PST)
In-Reply-To: <4D3DB248.5070802@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 25, 2011 at 1:09 AM, Alexander Duyck
<alexander.h.duyck@intel.com> wrote:
> On 1/24/2011 6:18 AM, Rui wrote:
>>
>> hi
>> does intel X520-SR support RSS on single VLAN?
>>
>> tested with 3 different vlan id and priority packets
>> What I saw is that all packets were always delivered to the same RxQ=
=2E
>> looks can not get a different RSS index for these packet?
>> any setting needed?
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
> The X520 should have no problems hashing on a single VLAN tagged fram=
e.
> =A0However the VLAN will not be a part of the RSS hash. =A0The =A0onl=
y components
> of the hash are the IPv4/IPv6 source and destination addresses, and i=
f the
> flow is TCP then the port numbers.
>
hi alexander
I got these information from the intel community:

'I asked our software engineers about your question, and this is what I=
 learned.
You cannot filter by just VLAN or VLAN priority.  The L4 type will
also play a role in the filter and as such you would only be able to
filter TCP, UDP, and SCTP packets that are bound for a VLAN.
The command itself to setup a filter is =93ethtool =96U ethX flow-type
tcp4 vlan 0x2000 vlan-mask 0xE000 action Y=94 where X is the correct
index for the interface and Y is the queue you want to route the
traffic to.  This would have to be repeated for udp4 and sctp4.
I hope this will help.
Mark H"

so my question is that the VLAN is PART of the RSS or not? looks the
perfect filter support vlan id ?can the perfect filter support
wildchar,such as: flow-type ANY?
thanks


> I would recommend testing with something like the "netperf -t TCP_CRR=
" test
> which should open a number of ports and spread traffic out between mu=
ltiple
> queues.
>
> Thanks,
>
> Alex
>
