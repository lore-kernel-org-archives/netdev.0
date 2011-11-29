From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH v4 0/10] bql: Byte Queue Limits
Date: Tue, 29 Nov 2011 00:03:40 -0800
Message-ID: <4ED491DC.8030304@intel.com>
References: <alpine.DEB.2.00.1111281825200.25622@pokey.mtv.corp.google.com>   <CAA93jw7P=7YMOS_sMQWBJx0UJ6e+xw4e_hw8szNiVTOjGNwukw@mail.gmail.com>  <1322550138.2970.70.camel@edumazet-laptop> <4ED4885F.8060309@intel.com> <1322552733.2970.78.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Taht <dave.taht@gmail.com>, Tom Herbert <therbert@google.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:51862 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751857Ab1K2IDm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Nov 2011 03:03:42 -0500
In-Reply-To: <1322552733.2970.78.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/2011 11:45 PM, Eric Dumazet wrote:
> Le lundi 28 novembre 2011 =C3=A0 23:23 -0800, John Fastabend a =C3=A9=
crit :
>=20
>> I wonder if we should consider enabling TSO/GSO per queue or per tra=
ffic
>> class on devices that support this. At least in devices that support
>> multiple traffic classes it seems to be a common usage case to put b=
ulk
>> storage traffic (iSCSI) on a traffic class and low latency traffic o=
n a
>> separate traffic class, VoIP for example.
>>
>=20
> It all depends on how device itself is doing its mux from queues to
> ethernet wire. If queue 0 starts transmit of one 64KB 'super packet',
> will queue 1 be able to insert a litle frame between the frames of qu=
eue
> 0 ?
>=20

Yes this works at least on the ixgbe supported 82599 device as you
would hope. 'super packets' from queues can and will be interleaved,
perhaps with standard sized packets, depending on the currently
configured arbitration scheme. So with multiple traffic classes we
can make a link strict 'low latency' class to TX frames as soon as
they are available.

Also I would expect this to work correctly on any of the coined
CNA devices, the bnx2x devices for example. I'll probably see what
can be done after finishing up some other things first.
