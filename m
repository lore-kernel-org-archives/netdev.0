From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net-next] xfrm: Simplify SA looking up when using wildcard
 source address
Date: Fri, 27 Sep 2013 16:35:44 +0800
Message-ID: <52454360.6020305@windriver.com>
References: <1379927917-17365-1-git-send-email-fan.du@windriver.com> <20130924114551.GT7660@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:47102 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752155Ab3I0IgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 04:36:05 -0400
In-Reply-To: <20130924114551.GT7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B409=E6=9C=8824=E6=97=A5 19:45, Steffen Klassert wrote:
> On Mon, Sep 23, 2013 at 05:18:37PM +0800, Fan Du wrote:
>> I'm not quite sure I get this "wildcard source address" right,
>> IMHO if a host needs to protect every traffic for a given remote hos=
t,
>> then the source address is wildcard address, i.e. all ZEROs.
>> (Please correct me if I'm bloodly wrong=E3=80=82=E3=80=82=E3=80=82)
>
> The above does not belong to a commit message, really.
> If you are not sure and you want comments on your patch,
> mark your patch as RFC. You should be sure that your patch
> is correct when you submit, at least in the moment you
> send it. I know that this can change a second after,
> but in that moment you should be sure.

One day without embarrassment is not my day :)
Have sent v2, please kindly review.

Thanks

>>
>> Here is the argument if above statement stands true:
>> __xfrm4/6_state_addr_check is a four steps check, all we need to do
>> is checking whether the destination address match. Passing saddr fro=
m
>> flow is worst option, as the checking needs to reach the fourth step=
=2E
>>
>> So, simply this process by only checking destination address only wh=
en
>> using wildcard source address for looking up SAs.
>>
>> Signed-off-by: Fan Du<fan.du@windriver.com>
>> ---
>
> If you have further comments on your patch that should not be
> included in the commit message, you can add them here.
>
>>   include/net/xfrm.h    |   31 +++++++++++++++++++++++++++++++
>>   net/xfrm/xfrm_state.c |    2 +-
>>   2 files changed, 32 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
>> index e253bf0..fdb9343 100644
>> --- a/include/net/xfrm.h
>> +++ b/include/net/xfrm.h
>> @@ -1282,6 +1282,37 @@ xfrm_state_addr_check(const struct xfrm_state=
 *x,
>>   }
>>
>>   static __inline__ int
>> +__xfrm4_state_daddr_check(const struct xfrm_state *x,
>> +                                const xfrm_address_t *daddr)
>> +{
>> +        return ((daddr->a4 =3D=3D x->id.daddr.a4) ? 1 : 0);
>> +}
>> +
>> +static __inline__ int
>> +__xfrm6_state_daddr_check(const struct xfrm_state *x,
>> +                         const xfrm_address_t *daddr)
>> +{
>> +        if (ipv6_addr_equal((struct in6_addr *)daddr, (struct in6_a=
ddr *)&x->id.daddr))
>> +                return 1;
>> +        else
>> +                return 0;
>> +}
>> +
>> +static __inline__ int
>> +xfrm_state_daddr_check(const struct xfrm_state *x,
>> +                      const xfrm_address_t *daddr,
>> +                      unsigned short family)
>> +{
>> +        switch (family) {
>> +        case AF_INET:
>> +                return __xfrm4_state_daddr_check(x, daddr);
>> +        case AF_INET6:
>> +                return __xfrm6_state_daddr_check(x, daddr);
>> +        }
>> +        return 0;
>> +}
>
> You used whitespaces where you should use tabs in the whole patch.
> Please do the formating right to avoid cleanup patches.
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
