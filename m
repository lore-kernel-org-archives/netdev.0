From: Nicola Padovano <nicola.padovano@gmail.com>
Subject: Re: problem with flowi structure
Date: Fri, 17 Sep 2010 10:46:10 +0200
Message-ID: <AANLkTimpnqNSE21u=2qjb5VGJrn_3_--Bqp4veCNXMPE@mail.gmail.com>
References: <AANLkTi=bGsvMqnTSanA73FhDH_DashmXTcA1sddtj0P6@mail.gmail.com>
 <1284650768.3352.37.camel@edumazet-laptop> <AANLkTimo1AeBS3rpQj0KtZL15Ct-DGTQMBUsL8hrVNOL@mail.gmail.com>
 <1284652453.3352.38.camel@edumazet-laptop> <AANLkTi=Y7beG4vPDx5eNg-gTN1CVg_G=1+dWwi2Xd2-R@mail.gmail.com>
 <AANLkTim7TeMCG9RQyrrk8WS4+S_y1q06+8FG2-X=1cB-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org
To: AIJAZ BAIG <aijazbaig1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:54873 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751268Ab0IQIqb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 04:46:31 -0400
In-Reply-To: <AANLkTim7TeMCG9RQyrrk8WS4+S_y1q06+8FG2-X=1cB-@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Aijaz, great! Now it' clear. Thank you.
It remains a problem: the meaning of

fl.nl_u.ip4_u.saddr =3D 0

But, first of all:
- we know that a routing table doesn't contain the ip source
- but the routing cache contains it.

so my first question is: why routing cache has it and routing cache
not? what it its usage?
Then my second question: the meaning of fl.nl_u.ip4_u.saddr =3D 0

thank you very much

On Fri, Sep 17, 2010 at 7:40 AM, AIJAZ BAIG <aijazbaig1@gmail.com> wrot=
e:
> Hi there,
>
> Well..if u see the code, ull see that ip_route_output_key is a wrappe=
r
> around ip_route_output_flow which in turn internally calls
> __ip_route_output_key. This later function tries to find a route for =
a
> packet first by looking up the routing cache and then if it isnt foun=
d
> there it =A0constructs a cache entry by calling its slow counterpart
> which is ip_route_output_slow.
>
> Now, the name tells u a lot. First ip_route_output_key tells u that
> this function 'routes' an 'output' packet. An output packet normally
> means that the packet is a locally generated packet. The routing (L3)
> protocol being used is ip (ipv4 specifically) and key tells us that w=
e
> are specifying the key to be used to check the routing cache (since
> the cache is organized as a hash and it needs a key to retrieve an
> entry).
>
> Thus all in all, the ip_route_output_key function is used to get a
> route for an output packet either from the routing cache if an entry
> is present or create one and update the cache accordingly.
>
> Hope it helped.
>
> Regards,
> Aijaz
>
> On 9/17/10, Nicola Padovano <nicola.padovano@gmail.com> wrote:
>> ok, let's step back...
>> what's the task of ip_route_output_key function ?
>>
>> --
>> Nicola Padovano
>> e-mail: nicola.padovano@gmail.com
>> web: http://npadovano.altervista.org
>> --
>> To unsubscribe from this list: send the line "unsubscribe netfilter-=
devel"
>> in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>>
>



--=20
Nicola Padovano
e-mail: nicola.padovano@gmail.com
web: http://npadovano.altervista.org
