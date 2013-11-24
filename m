From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net v3] vti: fix spd lookup: match plaintext pkt, not
 ipsec pkt
Date: Sun, 24 Nov 2013 18:21:24 +0800
Message-ID: <5291D324.3020808@windriver.com>
References: <1383646612-30103-1-git-send-email-christophe.gouault@6wind.com> <1383725153-26298-1-git-send-email-christophe.gouault@6wind.com> <20131107112549.GP31491@secunet.com> <527B8DC5.6080702@6wind.com> <1902752B0C92F943AB7EA9EE13E2DEEC1273BA977C@HQ1-EXCH02.corp.brocade.com> <528B2C72.5060809@windriver.com> <1902752B0C92F943AB7EA9EE13E2DEEC1273BA9ACD@HQ1-EXCH02.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christophe Gouault <christophe.gouault@6wind.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Saurabh Mohan <saurabh.mohan@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:34204 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120Ab3KXKTA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Nov 2013 05:19:00 -0500
In-Reply-To: <1902752B0C92F943AB7EA9EE13E2DEEC1273BA9ACD@HQ1-EXCH02.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B411=E6=9C=8822=E6=97=A5 02:39, Saurabh Mohan wrote:
>
>
>> -----Original Message-----
>> From: Fan Du [mailto:fan.du@windriver.com]
>> Sent: Tuesday, November 19, 2013 1:17 AM
>> To: Saurabh Mohan
>> Cc: Christophe Gouault; Steffen Klassert; David S. Miller; Herbert X=
u;
>> netdev@vger.kernel.org; Sergei Shtylyov; Eric Dumazet
>> Subject: Re: [PATCH net v3] vti: fix spd lookup: match plaintext pkt=
, not ipsec
>> pkt
>>
>> Hi, Saurabh
>>
>> On 2013=E5=B9=B411=E6=9C=8819=E6=97=A5 05:38, Saurabh Mohan wrote:
>>>
>>>
>>>> -----Original Message-----
>>>> From: Christophe Gouault [mailto:christophe.gouault@6wind.com]
>>>> Sent: Thursday, November 07, 2013 4:56 AM
>>>> To: Steffen Klassert
>>>> Cc: David S. Miller; Herbert Xu; netdev@vger.kernel.org; Saurabh M=
ohan;
>>>> Sergei Shtylyov; Eric Dumazet
>>>> Subject: Re: [PATCH net v3] vti: fix spd lookup: match plaintext p=
kt, not
>> ipsec
>>>> pkt
>>>>
>>>> Hello Steffen,
>>>>
>>>> I am also interested in knowing Saurabh's intentions regarding the
>>>> behavior of policies bound to vti interfaces.
>>>>
>>> The semantics is to match the policy "src 0.0.0.0/0 dst 0.0.0.0/0 p=
roto any"
>>> That is the only policy that VTI should use. The mark is needed to
>>> distinguish and limit the policy to a specific vti tunnel interface=
 only.
>>> There is no other policy that may be applied to a vti interface.
>>> The fact that traffic is going over the tunnel  interface implies t=
hat it
>>> must be encrypted/decrypted. Applying the above policy is a way
>>> to achieve that.
>>
>> I'm not much experienced with VTI usage practical production usage
>> scenario, but
>> I have one question about the necessity of policy checking on VTI re=
ceiving
>> part.
>> - A VTI tunnel is hashed by destination address and i_key when creat=
ing
>> them;
>> - After each tunneled IP packet delivered to vti_rcv, the first step=
 is looking
>>     for the right tunnel, this is done by using tunneled IP packet o=
uter source
>> and
>>     destination address without any key matching rule involved.
>>
>> If there are any other tunnel with the same source/destination addre=
ss, but
>> not
>> the same mark in place, the tunnel lookup in the vti_rcv will proper=
ly not hit
>> VTI tunnel, but the non-VTI tunnel. So the VTI net device statistics=
 will not be
>> accurate, and what's the point of checking policy for the wrong tunn=
el
>> interface?
>
> So far this is not supported. If it were needed then we'd have to use=
 another
> key on the tunnel(s) to distinguish between tunnel with same src and =
dst.
> In such a case there would be two keys on the tunnel (one for vti mar=
k
> and the other one to separate out tunnels with same src and dst).
>

That's indeed what I am pointing, one vti tunnel with mark_a,
another tunnel sharing same VTI tunnel's src/dst address with
only different mark_b/wildcard mark. This configuration probably
cause vti_rcv using the non-VTI tunnel for the policy checking.

So after b2942004fb5c9f3304b77e187b8a1977b3626c9b ("ipv4/ip_vti.c:
  VTI fix post-decryption forwarding"), no other non-VTI tunnel
should be mingled with VTI tunnel, otherwise, the forward process
will be malfunctional.



--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan fan
