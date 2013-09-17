From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net] xfrm: Guard IPsec anti replay window against replay
 bitmap
Date: Tue, 17 Sep 2013 15:12:50 +0800
Message-ID: <523800F2.3050704@windriver.com>
References: <1379399165-8955-1-git-send-email-fan.du@windriver.com> <20130917065647.GO7660@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:37806 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338Ab3IQHMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 03:12:42 -0400
In-Reply-To: <20130917065647.GO7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B409=E6=9C=8817=E6=97=A5 14:56, Steffen Klassert wrote:
> On Tue, Sep 17, 2013 at 02:26:05PM +0800, Fan Du wrote:
>>
>> diff --git a/net/key/af_key.c b/net/key/af_key.c
>> index 9d58537..911ef03 100644
>> --- a/net/key/af_key.c
>> +++ b/net/key/af_key.c
>> @@ -1098,7 +1098,8 @@ static struct xfrm_state * pfkey_msg2xfrm_stat=
e(struct net *net,
>>
>>   	x->id.proto =3D proto;
>>   	x->id.spi =3D sa->sadb_sa_spi;
>> -	x->props.replay_window =3D sa->sadb_sa_replay;
>> +	x->props.replay_window =3D min_t(unsigned int, sa->sadb_sa_replay,
>> +					(sizeof(x->replay.bitmap) * 8));
>>   	if (sa->sadb_sa_flags&  SADB_SAFLAGS_NOECN)
>>   		x->props.flags |=3D XFRM_STATE_NOECN;
>>   	if (sa->sadb_sa_flags&  SADB_SAFLAGS_DECAP_DSCP)
>> diff --git a/net/xfrm/xfrm_replay.c b/net/xfrm/xfrm_replay.c
>> index 8dafe6d3..eeca388 100644
>> --- a/net/xfrm/xfrm_replay.c
>> +++ b/net/xfrm/xfrm_replay.c
>> @@ -129,8 +129,7 @@ static int xfrm_replay_check(struct xfrm_state *=
x,
>>   		return 0;
>>
>>   	diff =3D x->replay.seq - seq;
>> -	if (diff>=3D min_t(unsigned int, x->props.replay_window,
>> -			  sizeof(x->replay.bitmap) * 8)) {
>> +	if (diff>=3D x->props.replay_window) {
>
> So x->props.replay_window will be valid if the state was added with t=
he
> pfkey interface, but what if the netlink interface was used? You shou=
ld
> also update the netlink part to always hold a valid replay window.
>

Smell positively, v2 in seconds=E3=80=82=E3=80=82=E3=80=82

Thanks, Steffen.


--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
