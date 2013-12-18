From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCHv3 net-next 0/7] pktgen IPsec support
Date: Wed, 18 Dec 2013 09:48:27 +0800
Message-ID: <52B0FEEB.70508@windriver.com>
References: <1387094284-2901-1-git-send-email-fan.du@windriver.com> <52AEF4ED.4020504@mojatatu.com> <52AFB580.5060403@windriver.com> <52B05482.7030400@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, <davem@davemloft.net>,
	<steffen.klassert@secunet.com>, <hadi@cyberus.ca>,
	<netdev@vger.kernel.org>
To: jamal <j.hadi123@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43943 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875Ab3LRBsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 20:48:35 -0500
In-Reply-To: <52B05482.7030400@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B412=E6=9C=8817=E6=97=A5 21:41, jamal wrote:
> On 12/16/13 21:22, Fan Du wrote:
>>
>>
>> I thought we have reach the consensus on this part in previous discu=
ssion
>> (http://www.spinics.net/lists/netdev/msg261411.html), This enhanceme=
nt
>> patch didn't change original behavior, nor does remove original impl=
ementation.
>>
>
> right - thats the agreement. i.e nothing changes by default unless
> some pktgen parameter is set.
> If someone wants to send using original scheme it should work
> as long as they dont set this extra parameter.
>
>> This enhancement expects good encapsulation format for the receiver =
to
>> de-encapsulation.
>>
>
> Maybe i missed something - receiver wasnt affected in the discussion.
> It was only the sender.

It's in this thread, see: http://www.spinics.net/lists/netdev/msg260537=
=2Ehtml


>> This is snippets of doc updates I could come up with. Please check i=
f it's ok
>> for you.
>>
>> @@ -108,7 +108,9 @@ Examples:
>> MPLS_RND, VID_RND, SVID_RND
>> QUEUE_MAP_RND # queue map random
>> QUEUE_MAP_CPU # queue map mirrors smp_processor_id()
>> + IPSEC # Make IPsec encapsulation for packet
>>
>> + pgset spi SPI_VALUE Set specific SA used to transform packet.
>>
>> pgset "udp_src_min 9" set UDP source port min, If < udp_src_max, the=
n
>> cycle through the port range.
>> @@ -177,6 +179,18 @@ Note when adding devices to a specific CPU ther=
e good idea to also assign
>> /proc/irq/XX/smp_affinity so the TX-interrupts gets bound to the sam=
e CPU.
>> as this reduces cache bouncing when freeing skb's.
>>
>> +Enable IPsec
>> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> +Default IPsec transformation with ESP encapsulation plus Transport =
mode
>> +could be enabled by simply setting:
>> +
>> +pgset "flag IPSEC"
>> +pgset "flows 1"
>> +
>> +To avoid breaking existing testbed scripts for using AH type and tu=
nnel mode,
>> +user could use "pgset spi SPI_VALUE" to specify which formal of tra=
nsformation
>> +to employ.
>> +
>>
>
> Thanks. Thats a good starting point. I just realized there's nothing =
at all on
> ipsec ;-> Maybe you can add even more extensive info to describe all =
modes?

No, those information does not belong to pktgen at all.

All we need is a 'spi' to point which SA to employ for the transformati=
on. The SA, either
manually created temporally for pktgen test, or using existing one(thou=
gh with different
tmpl info)will describe specific type(ESP/AH) or mode(Transport/Tunnel)=
 in use.


> cheers,
> jamal
>> Current commands and configuration options
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> @@ -225,6 +239,7 @@ flag
>> UDPDST_RND
>> MACSRC_RND
>> MACDST_RND
>> + IPSEC
>>
>> dst_min
>>
>>
>
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
