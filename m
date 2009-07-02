From: Julius Volz <julius.volz@gmail.com>
Subject: Re: [PATCH] IPVS: Add handling of incoming ICMPV6_PKT_TOOBIG messages
Date: Thu, 2 Jul 2009 16:43:39 +0200
Message-ID: <43ca39800907020743v1ccc1979o5a934d5ead05edc9@mail.gmail.com>
References: <20090624132232.GA9633@egardia>
	 <20090628154302.GB21519@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	robert.gallagher@heanet.ie
To: Simon Horman <horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20090628154302.GB21519@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Simon,

On Sun, Jun 28, 2009 at 5:43 PM, Simon Horman<horms@verge.net.au> wrote=
:
> On Wed, Jun 24, 2009 at 03:22:32PM +0200, Julius Volz wrote:
>> Add handling of incoming ICMPv6 Packet Too Big messages. This messag=
e
>> is received when a realserver sends a packet >PMTU to the client. Th=
e
>> hop on this path with insufficient MTU will generate an ICMPv6 Packe=
t
>> Too Big message back to the VIP. The LVS server receives this messag=
e,
>> but the call to the function handling this has been missing. Thus, I=
PVS
>> fails to forward the message to the real server, which then does not
>> adjust the path MTU. This patch adds the missing call to
>> ip_vs_in_icmp_v6() in ip_vs_in() to handle this situation.
>>
>> Thanks to Rob Gallagher from HEAnet for reporting this issue and for
>> testing this patch in production (with direct routing mode).
>>
>> Signed-off-by: Julius Volz <julius.volz@gmail.com>
>> Tested-by: Rob Gallagher <robert.gallagher@heanet.ie>
>
> Hi Julius, Hi Rob,
>
> this seems reasonable to me, although it seems that the following
> code is common. I wonder if its repetition could be removed.
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (related)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return=
 verdict;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ip_vs_fill_iphdr(af, s=
kb_network_header(skb), &iph);

I agree, though I see no "nice" way to remove this duplication
considering the ifs and #ifdefs around this. You could move the
related and verdict variables to the top of the function and then
recheck afterwards whether one of these ICMP-handling branches was
entered and put the common code in there. But this seems more
cumbersome to me than repeating the code. Maybe you see a nicer way?
Btw., exactly this structure already exists in ip_vs_out(), which is
why I adopted it like this for ip_vs_in().

Cheers,
Julius
