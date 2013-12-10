From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net-next 3/3] xfrm: Restrict "level use" for IPComp configuration
Date: Tue, 10 Dec 2013 10:39:51 +0800
Message-ID: <52A67EF7.3070402@windriver.com>
References: <1385607161-27597-1-git-send-email-fan.du@windriver.com> <1385607161-27597-4-git-send-email-fan.du@windriver.com> <20131209103856.GL31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:47180 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858Ab3LJCkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 21:40:07 -0500
In-Reply-To: <20131209103856.GL31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B412=E6=9C=8809=E6=97=A5 18:38, Steffen Klassert wrote:
> On Thu, Nov 28, 2013 at 10:52:41AM +0800, Fan Du wrote:
>>
>> diff --git a/net/key/af_key.c b/net/key/af_key.c
>> index 911ef03..d37a2c1 100644
>> --- a/net/key/af_key.c
>> +++ b/net/key/af_key.c
>> @@ -1895,6 +1895,12 @@ parse_ipsecrequest(struct xfrm_policy *xp, st=
ruct sadb_x_ipsecrequest *rq)
>>   			return -ENOBUFS;
>>   	}
>>
>> +	/* IPComp requires level use option to accomodate both compressed
>> +	 * and non-compressed packet when checking policy.
>> +	 */
>> +	if ((t->id.proto =3D=3D IPPROTO_COMP)&&  (t->optional =3D=3D 0))
>> +		return -EINVAL;
>> +
>>   	/* addresses present only in tunnel mode */
>>   	if (t->mode =3D=3D XFRM_MODE_TUNNEL) {
>>   		u8 *sa =3D (u8 *) (rq + 1);
>> diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
>> index 52efe71..d7216ea 100644
>> --- a/net/xfrm/xfrm_user.c
>> +++ b/net/xfrm/xfrm_user.c
>> @@ -1293,6 +1293,10 @@ static int validate_tmpl(int nr, struct xfrm_=
user_tmpl *ut, u16 family)
>>   		default:
>>   			return -EINVAL;
>>   		}
>> +
>> +		/* Refuse any IPComp conf that missing "level use" */
>> +		if ((ut[i].id.proto =3D=3D IPPROTO_COMP)&&  (ut[i].optional =3D=3D=
 0))
>> +			return -EINVAL;
>>   	}
>
> I think this will make a lot of people unhappy. It was never required
> to set 'optional' for ipcomp, and I'd bet that most users don't set
> it for ipcomp. I understand the problem, but we can't fix it like tha=
t.

Instead of making this check, what about wire 'optional' to 1? it doesn=
't
breaking existing script.

Do you have any other way to cure this problem other than 'optional'.

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
