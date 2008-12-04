From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: TCP default congestion control in linux should be newreno
Date: Thu, 4 Dec 2008 15:56:13 -0800
Message-ID: <1e41a3230812041556p10af2c7bg9873d21bf3bf1d1f@mail.gmail.com>
References: <b98e548c0812030812i3980791y2e4135cb9c5110c0@mail.gmail.com>
	 <Pine.LNX.4.64.0812041419500.26947@wrl-59.cs.helsinki.fi>
	 <20081204185022.6108d19e@gmail.com>
	 <20081204.101805.45306327.davem@davemloft.net>
	 <b98e548c0812041105o6c2ded8br3c2349cabceaf99f@mail.gmail.com>
	 <Pine.LNX.4.64.0812042250360.27758@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Saverio Mascolo" <saverio.mascolo@gmail.com>,
	"David Miller" <davem@davemloft.net>, ldecicco@gmail.com,
	Netdev <netdev@vger.kernel.org>
To: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:15812 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077AbYLDX4P convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 18:56:15 -0500
Received: by yx-out-2324.google.com with SMTP id 8so1857178yxm.1
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2008 15:56:14 -0800 (PST)
In-Reply-To: <Pine.LNX.4.64.0812042250360.27758@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 4, 2008 at 1:05 PM, Ilpo J=E4rvinen <ilpo.jarvinen@helsinki=
=2Efi> wrote:
> On Thu, 4 Dec 2008, Saverio Mascolo wrote:
>
>> we have done many experiments, along with many other "researcher" as=
 u
>> say. as a consequence, i have maturated the belief that changing the
>> probing phase of the van jacobson TCP, which is linear, could not be
>> not a wise thing .
>>  the rationale of  VJ choice seems simple to me: if  the window is
>> increased of one packet in one rtt, i can drop at most one packet in
>> one rtt and so i have to recover only one packet in one rtt (note th=
at
>> rtt is the feedback reaction  time). If cwnd is increased of N packe=
ts
>> i could drop N packets and i could need to recover N pkts. this is t=
he
>> problem here.
>
> 1) N drops is not as bad as you seem to imply, sadly this is a very c=
ommon
> misconcept among much tcp related research that fast retransmits and =
the
> following recovery are a bad things in itself. SACK handles it very
> efficiently as long as N is considerably less than cwnd and the buffe=
r
> before the bottleneck was adequate to keep the link fully utilized ov=
er
> that recovery rtt. Thus the first claim (vj one) does not follow from=
 the
> latter on (n pkts is bad), it is bogus reasoning.

One thing to note, you only get N drops upon cwnd increase of N when
you have simple drop-tail queues.  AQM significantly changes the
behavior here, but drop-tail is still nearly ubiquidous.

A notable effect of multiple loss associated with increasing cwnd by
multiple segments, aside from outright SACK bugs, is that it tends to
synchronize losses across flows, since all N drops are not usually
from the same flow.  (Again, talking only about drop-tail here.)
Synchronized losses lead to lower link utilization with many flows.

  -John
