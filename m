From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCHv2 net-next] {ipv4,xfrm}: Introduce xfrm_tunnel_notifier
 for xfrm tunnel mode callback
Date: Fri, 30 Aug 2013 16:29:47 +0800
Message-ID: <522057FB.2010306@windriver.com>
References: <1377673780-9778-1-git-send-email-fan.du@windriver.com> <20130830073801.GH7660@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <herbert@gondor.hengli.com.au>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:51769 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753974Ab3H3I30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 04:29:26 -0400
In-Reply-To: <20130830073801.GH7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B408=E6=9C=8830=E6=97=A5 15:38, Steffen Klassert wrote:
> On Wed, Aug 28, 2013 at 03:09:40PM +0800, Fan Du wrote:
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
>> A IPsec protected packet is first handled by protocol handlers, e.g =
AH/ESP,
>> to check packet authentication or encryption rightness. PMTU update =
is taken
>> care of in this stage by protocol error handler.
>>
>> Then the packet is rearranged properly depending on whether it's tra=
nsport
>> mode or tunnel mode packed by mode "input" handler. The VTI handler =
code
>> takes effects in this stage in tunnel mode only. So it neither need =
propagate
>> PMTU, as it has already been done if necessary, nor the VTI handler =
is
>> qualified as a xfrm_tunnel.
>>
>> So this patch introduces xfrm_tunnel_notifier and meanwhile wipe out=
 vti_err
>> code.
>>
>> Signed-off-by: Fan Du<fan.du@windriver.com>
>> Cc: Steffen Klassert<steffen.klassert@secunet.com>
>> Cc: David S. Miller<davem@davemloft.net>
>> Reviewed-by: Saurabh Mohan<saurabh.mohan@vyatta.com>
>
> Applied to ipsec-next, thanks a lot!
>

Hi, Steffen

Thanks for picking this up!

About "xfrm: Refactor xfrm_state timer management", Thomas objects addi=
ng notifier
at clock_was_set( https://lkml.org/lkml/2013/8/18/36 ), frankly speakin=
g I'm not
experienced to argue with such high level person, neither could I convi=
nce David
that getting rid of wall clock in xfrm_state is the right thing to do.
So I really don't know what to do with this patch now :( scratching my =
head harder=E3=80=82=E3=80=82=E3=80=82

Is there any slim light of hope for me to keep working on this IPsec is=
sue?
Or should I drop it?

Thanks

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
