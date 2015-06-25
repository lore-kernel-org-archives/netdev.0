From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] flow_dissector: Pre-initialize ip_proto in
 __skb_flow_dissect()
Date: Thu, 25 Jun 2015 15:48:38 +0200
Message-ID: <20150625134838.GA2455@nanopsycho.ki.iif.hu>
References: <1435237832-28838-1-git-send-email-geert@linux-m68k.org>
 <20150625.063331.1437042913073267200.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: geert@linux-m68k.org, tom@herbertland.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150625.063331.1437042913073267200.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thu, Jun 25, 2015 at 03:33:31PM CEST, davem@davemloft.net wrote:
>From: Geert Uytterhoeven <geert@linux-m68k.org>
>Date: Thu, 25 Jun 2015 15:10:32 +0200
>
>> net/core/flow_dissector.c: In function =E2=80=98__skb_flow_dissect=E2=
=80=99:
>> net/core/flow_dissector.c:132: warning: =E2=80=98ip_proto=E2=80=99 m=
ay be used uninitialized in this function
>>=20
>> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
>> ---
>> This may be a false positive, but the state machine in
>> __skb_flow_dissect() is a bit hard to follow.
>> As I believe it is controlled by a packet received from the network,=
 the
>> only safe thing to do is to pre-initialize ip_proto.
>
>Actually I think this is a real bug, because for the ETH_P_MPLS_* case=
s I cannot
>see what will always set ip_proto before it gets used as an input.

I think that MPLS cases are ok. In this case, return is always hit.
I believe this is false positive.
