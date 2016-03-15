From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH v6 net-next 2/2] tcp: Add Redundant Data Bundling (RDB)
Date: Tue, 15 Mar 2016 11:09:18 -0700
Message-ID: <CAK6E8=cq337S_2c5SWtS0zJtd+NXMKrw5A3Y64ZHVTtpF2rcPQ@mail.gmail.com>
References: <1457028388-18226-1-git-send-email-bro.devel+kernel@gmail.com>
 <1457028388-18226-3-git-send-email-bro.devel+kernel@gmail.com>
 <1457990140.31401.20.camel@edumazet-glaptop3.roam.corp.google.com> <56E75F8B.7090101@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?Q?Bendik_R=C3=B8nning_Opstad?= <bro.devel@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	=?UTF-8?Q?P=C3=A5l_Halvorsen?= <paalh@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kristian Evensen <kristian.evensen@gmail.com>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37235 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932212AbcCOSKA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 14:10:00 -0400
Received: by mail-wm0-f46.google.com with SMTP id p65so38683525wmp.0
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 11:09:59 -0700 (PDT)
In-Reply-To: <56E75F8B.7090101@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 14, 2016 at 6:04 PM, Rick Jones <rick.jones2@hpe.com> wrote=
:
>
> On 03/14/2016 02:15 PM, Eric Dumazet wrote:
>>
>> On Thu, 2016-03-03 at 19:06 +0100, Bendik R=C3=B8nning Opstad wrote:
>>>
>>> Redundant Data Bundling (RDB) is a mechanism for TCP aimed at reduc=
ing
>>> the latency for applications sending time-dependent data.
>>>
>>> Latency-sensitive applications or services, such as online games,
>>> remote control systems, and VoIP, produce traffic with thin-stream
>>> characteristics, characterized by small packets and relatively high
>>> inter-transmission times (ITT). When experiencing packet loss, such
>>> latency-sensitive applications are heavily penalized by the need to
>>> retransmit lost packets, which increases the latency by a minimum o=
f
>>> one RTT for the lost packet. Packets coming after a lost packet are
>>> held back due to head-of-line blocking, causing increased delays fo=
r
>>> all data segments until the lost packet has been retransmitted.
>>
>>
>> Acked-by: Eric Dumazet <edumazet@google.com>
>>
>> Note that RDB probably should get some SNMP counters,
>> so that we get an idea of how many times a loss could be repaired.
>
>
> And some idea of the duplication seen by receivers, assuming there is=
n't already a counter for such a thing in Linux.

We sort of track that in the awkwardly named LINUX_MIB_DELAYEDACKLOST



>
> happy benchmarking,
>
> rick jones
>
>
>>
>> Ideally, if the path happens to be lossless, all these pro active
>> bundles are overhead. Might be useful to make RDB conditional to
>> tp->total_retrans or something.
>>
>>
>
