From: Caitlin Bestler <caitlin.bestler@gmail.com>
Subject: Re: Connection tracking and vlan
Date: Fri, 30 Oct 2009 12:51:30 -0700
Message-ID: <469958e00910301251he051d69p178ce53e84130765@mail.gmail.com>
References: <20091030152054.GA7936@gondor.apana.org.au>
	 <4AEB06E6.6020206@gmail.com>
	 <fb7befa20910301220y53e43608u3b37de17661feb4e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Adayadil Thomas <adayadil.thomas@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f188.google.com ([209.85.222.188]:41337 "EHLO
	mail-pz0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755678AbZJ3Tv0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 15:51:26 -0400
Received: by pzk26 with SMTP id 26so2108418pzk.4
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2009 12:51:31 -0700 (PDT)
In-Reply-To: <fb7befa20910301220y53e43608u3b37de17661feb4e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes, it is legitimate for a Bridge to see two different 10.*.*.*
networks on different VLANs.
A Bridge can even see that same MAC address being used by two
different end stations
on different VLANs (especially if the global bit is not set).

What is not legitimate is presenting both of those 10.*.*.* networks
for local delivery.

If you are only bridging the frames then there are no connections to
track, only frames.



On Fri, Oct 30, 2009 at 12:20 PM, Adayadil Thomas
<adayadil.thomas@gmail.com> wrote:
> On Fri, Oct 30, 2009 at 11:31 AM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>
>> Very strange, this question about vlan looks like discussion we had
>> yesterday (or the day before...) about interfaces (versus packet def=
ragmentation)
>>
>> "IP conntracking" is about IP, and [V]LAN doesnt matter at all at th=
is protocol level.
>>
>> Same thing if you have two interfaces, eth0 & eth1 : IP conntrack tu=
ples dont
>> include interface name/index
>
> I am concerned about the following situation -
>
> The linux device is configured as a bridge and is deployed between th=
e
> trunk ports
> of 2 switches. In this situation the linux device will be seeing 802.=
1q packets
> with vlan headers specifying the vlanids.
>
> It is valid to have an environment where private IP addresses are dup=
licated
> on different virtual LANs. i.e. it is valid to have machine A (
> 10.10.10.1) talking to
> machine B (10.10.10.2) on vlan 1,
> and
> at the same time machine C ( 10.10.10.1) talking to machine D
> (10.10.10.2) on vlan 2.
>
> Since they are on different LANs (VLANs), there should not be any iss=
ues.
>
> Now when VLANs are shared across switches, the trunk port will sent
> 802.1q tagged
> packets between the switches. Imagine these packets when going throug=
h
> the linux bridge.
> The 802.1q header should identify the separate vlans by the vlan id.
>
> If ip_conntrack does not consider vlans, it is possible that all 5
> tuple are the same
> and thus affect the connection tracking.
>
> I hope I have described the scenario well. If not I can explain in a
> more detailed fashion.
>
> Thanks
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
>
