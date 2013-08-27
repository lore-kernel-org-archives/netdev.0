From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net-next] {ipv4,xfrm}: Introduce xfrm_tunnel_notifier
 for xfrm tunnel mode callback
Date: Tue, 27 Aug 2013 09:29:40 +0800
Message-ID: <521C0104.2070906@windriver.com>
References: <1377240424-11758-1-git-send-email-fan.du@windriver.com> <20130826.162135.1765443562851401512.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <steffen.klassert@secunet.com>, <saurabh.mohan@vyatta.com>,
	<herbert@gondor.hengli.com.au>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.windriver.com ([128.224.252.3]:44747 "EHLO
	mail7.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752694Ab3H0B32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Aug 2013 21:29:28 -0400
In-Reply-To: <20130826.162135.1765443562851401512.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Dave

Thanks for your reply :)

On 2013=E5=B9=B408=E6=9C=8827=E6=97=A5 04:21, David Miller wrote:
> From: Fan Du<fan.du@windriver.com>
> Date: Fri, 23 Aug 2013 14:47:04 +0800
>
>> Some thoughts on IPv4 VTI implementation:
>>
>> The connection between VTI receiving part and xfrm tunnel mode input=
 process
>> is hardly a "xfrm_tunnel", xfrm_tunnel is used in places where, e.g =
ipip/sit
>> and xfrm4_tunnel, acts like a true "tunnel" device.
>>
>> In addition, IMHO, VTI doesn't need vti_err to do something meaningf=
ul, as all
>> VTI needs is just a notifier to be called whenever xfrm_input ingres=
s a packet
>> to update statistics.
>>
>> So this patch introduce xfrm_tunnel_notifier and meanwhile wipe out =
vti_erri
>> code.
>>
>> Signed-off-by: Fan Du<fan.du@windriver.com>
>
> I don't understand why VTI doesn't need to propagate a PMTU update vi=
a
> ipv4_update_pmtu().  Why is it different from a real xfrm_tunnel?
   ^^^^^^^^^^^^^^^^

A IPsec protected packet is first handled by protocol handlers, e.g AH/=
ESP,
to check packet authentication or encryption rightness. PMTU update is =
taken
care of in this stage by protocol error handler.

Then the packet is rearranged properly depending on whether it's transp=
ort
mode or tunnel mode packed by mode "input" handler. The VTI handler cod=
e
takes effects in this stage in tunnel mode only. So it neither need pro=
pagate
PMTU, as it has already been done if necessary, nor the VTI handler is
qualified as a xfrm_tunnel.

IMHO, xfrm_tunnel is protocol layer specific only, which denotes a meth=
od
how IPPROTO_IPIP inner packet is handled, while as VTI reform XFRM poli=
cy into
a routable net device. That's the difference between them.

>
> Your changelog has to explain this better and in more detail.
> Thanks.
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
