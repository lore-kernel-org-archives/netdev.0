From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH v6 net-next 2/2] tcp: Add Redundant Data Bundling (RDB)
Date: Mon, 14 Mar 2016 18:04:11 -0700
Message-ID: <56E75F8B.7090101@hpe.com>
References: <1457028388-18226-1-git-send-email-bro.devel+kernel@gmail.com>
 <1457028388-18226-3-git-send-email-bro.devel+kernel@gmail.com>
 <1457990140.31401.20.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	=?UTF-8?Q?P=c3=a5l_Halvorsen?= <paalh@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kristian Evensen <kristian.evensen@gmail.com>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?Q?Bendik_R=c3=b8nning_Opstad?= <bro.devel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3425.houston.hp.com ([15.201.208.53]:45555 "EHLO
	g4t3425.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754116AbcCOBEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 21:04:16 -0400
In-Reply-To: <1457990140.31401.20.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/14/2016 02:15 PM, Eric Dumazet wrote:
> On Thu, 2016-03-03 at 19:06 +0100, Bendik R=C3=B8nning Opstad wrote:
>> Redundant Data Bundling (RDB) is a mechanism for TCP aimed at reduci=
ng
>> the latency for applications sending time-dependent data.
>>
>> Latency-sensitive applications or services, such as online games,
>> remote control systems, and VoIP, produce traffic with thin-stream
>> characteristics, characterized by small packets and relatively high
>> inter-transmission times (ITT). When experiencing packet loss, such
>> latency-sensitive applications are heavily penalized by the need to
>> retransmit lost packets, which increases the latency by a minimum of
>> one RTT for the lost packet. Packets coming after a lost packet are
>> held back due to head-of-line blocking, causing increased delays for
>> all data segments until the lost packet has been retransmitted.
>
> Acked-by: Eric Dumazet <edumazet@google.com>
>
> Note that RDB probably should get some SNMP counters,
> so that we get an idea of how many times a loss could be repaired.

And some idea of the duplication seen by receivers, assuming there isn'=
t=20
already a counter for such a thing in Linux.

happy benchmarking,

rick jones

>
> Ideally, if the path happens to be lossless, all these pro active
> bundles are overhead. Might be useful to make RDB conditional to
> tp->total_retrans or something.
>
>
