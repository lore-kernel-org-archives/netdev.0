From: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
Subject: Re: [PATCH][IPV6][NDISC] unify ipv6 output routine
Date: Sat, 07 Feb 2004 10:40:40 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4024A488.60203@kolumbus.fi>
References: <200402070232.33771.kazunori@miyazawa.org>	<4023D6FB.9010909@kolumbus.fi> <20040207.131455.27570445.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: kazunori@miyazawa.org, davem@redhat.com, netdev@oss.sgi.com,
        usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: =?ISO-8859-1?Q?YOSHIFUJI_Hideaki_/_=3F=3F=3F=3F?=
 <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040207.131455.27570445.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



YOSHIFUJI Hideaki / ???? wrote:

>In article <4023D6FB.9010909@kolumbus.fi> (at Fri, 06 Feb 2004 20:03:39 =
+0200), Mika Penttil=E4 <mika.penttila@kolumbus.fi> says:
>
> =20
>
>>Kazunori Miyazawa wrote:
>>   =20
>>
>:
> =20
>
>>>Yoshifuji-san and I send the patch which unifies IPv6 output routine a=
nd remove
>>>RTF_NDISC again. It resolves an issue of IPv6 IPsec with neighbor disc=
overy
>>>without a flag.
>>>     =20
>>>
>:
> =20
>
>>You break multicast replies, see what ndisc_build_ll_hdr() does...
>>   =20
>>
>
>It doesn't "break."=20
>The ip6_output2() resolves and inserts link-layer address appropriately.
>If it did, we would have noticed (by conformance test or even by
>usual operation). ;-)
> =20
>
ip6_output2() doesn't resolve link-layer addresses. We don't even have a=20
neighbour, in

ndisc_dst_alloc(dev, NULL, ip6_output2); case.


>BTW, Miyazawa-san, we do not need ndisc_build_ll_hdr() anymore.
>Compiler warns it. Please remove it. Thanks.
>
>
>Here's the description:
>
>dst->neighbour owns the neighbour entry for the destination.=20
>
>For multicast, we know its link-layer address=20
>(filled in ndisc_constructor()).
>For unicast, the link-layer address may be unknown.
>
>ip6_output2() will call ip6_output_finish() and
>it tries inserting the link-layer header.
>
>The destination link-layer address is used if it is known (*).
>(Note: you remember that we know link-layer address for multicast.)
>
>If the link-layer address is not known or invalid,=20
>we queue the packet and resolve the link-layer address for the destinati=
on.
>Here, since the neighbour entry is "invalid," *multicast* NS is sent.=20
>The NS packet passes similar path.=20
>We know the destination for the NS is multicast and=20
>what the link-layer address is, and the packet is sent via (*).
>We will send the queued packet when we got NA from that node.
>
>Real story:
>A node may send NS without source link-layer address option=20
>while we do not know the link-layer address for the source of the NS.
>We need to send NA in reply to this NS.
>Original code cannot handle this case.  The new code path can.
> =20
>

You just described how the normal link layer address resolving goes. It=20
doesn't apply here. Again, there is no dst->neighbour.



--Mika
