From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH net-2.6] bonding: drop frames received with master's source
 MAC
Date: Wed, 02 Mar 2011 21:26:07 +0100
Message-ID: <4D6EA7DF.7010804@gmail.com>
References: <1298668408-14849-1-git-send-email-andy@greyhouse.net> <4D68276B.90104@gmail.com> <20110225222455.GI11864@gospo.rdu.redhat.com> <4D683653.4050409@gmail.com> <20110228163255.GJ11864@gospo.rdu.redhat.com> <4D6C1764.1040008@gmail.com> <20110301023525.GK11864@gospo.rdu.redhat.com> <9882.1298958366@death> <20110301181624.GM11864@gospo.rdu.redhat.com> <4D6D658C.90300@gmail.com> <20893.1299018331@death> <4D6D7C66.6050205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Jiri Pirko <jpirko@redhat.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:65260 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754997Ab1CBU0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 15:26:12 -0500
Received: by wyg36 with SMTP id 36so392823wyg.19
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 12:26:11 -0800 (PST)
In-Reply-To: <4D6D7C66.6050205@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/03/2011 00:08, Nicolas de Peslo=C3=BCan a =C3=A9crit :
[snip]
> Can we imagine that, at the time we change the bonding mode to -rr or
> -xor, we simply brodcast or multicast one or two frames with some ran=
dom
> data and wait to see whether we receive the frame back? If we receive=
 at
> least one frame with the same random data, in one of the slaves
> interface for this bonding, we know for sure the switch configuration=
 is
> not "multicast loop safe". Bonding already send ARP requests/replies =
in
> many situations. Adding one broadcast/multicast frame at bond setup t=
ime
> is probably acceptable.
>
> And to ensure consistent results, we need to send such
> broadcast/multicast every time the link goes up for an already enslav=
ed
> slave. This is not perfect, as the switch topology may change in a wa=
y
> that won't be detected by bonding, but still cause a new multicast lo=
op,
> but...
>
> Knowing the switch configuration is not "multicast loop safe", we can=
,
> at a minimum, issue a warning, telling the user she should expect
> strange behaviors, like false duplicate address detection.
>
> And we can probably use this information into the should-drop logic, =
for
> mode that lack "inactive" slaves.
>

Still thinking about it:

We should drop the frame if :

the bonding interface is in -rr or -xor mode,
and we know the switch topology in front of our slaves is not "multicas=
t
loop safe" (see above).
and the source MAC is the MAC of the bonding interface
and the destination MAC is a multicast one.

That being said, I wonder if this is only bonding related.

If one decide to configure two interfaces with the same MAC and connect
them to the same LAN, then we get the exact same situation. Having eth0
and eth1 share a single MAC and a single IP address, connected to a
switch in Etherchannel mode is a perfectly valid setup, while
suboptimal. And if the Etherchannel mode happens to be improperly
configured, we end up with the same problem as reported by Andy.

          Nicolas.

[ Resent, because netdev ML didn't get it the first time ]
