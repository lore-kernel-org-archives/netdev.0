From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH] [XFRM] Fix unexpected SA hard expiration after changing
 date
Date: Tue, 19 Jun 2012 09:34:29 +0800
Message-ID: <4FDFD725.1070301@windriver.com>
References: <1340007856-27651-1-git-send-email-fan.du@windriver.com> <1340007856-27651-2-git-send-email-fan.du@windriver.com> <20120618110523.GA29295@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <herbert@gondor.hengli.com.au>,
	<netdev@vger.kernel.org>, <fdu@windriver.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57627 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753305Ab2FSBdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 21:33:09 -0400
In-Reply-To: <20120618110523.GA29295@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2012=E5=B9=B406=E6=9C=8818=E6=97=A5 19:05, Steffen Klassert wrote:
> On Mon, Jun 18, 2012 at 04:24:16PM +0800, fan.du wrote:
>> After SA is setup, one timer is armed to detect soft/hard expiration=
,
>> however the timer handler uses xtime to do the math. This makes hard
>> expiration occurs first before soft expiration after setting new dat=
e
>> with big interval. As a result new child SA is deleted before rekeyi=
ng
>> the new one.
>>
>> Signed-off-by: fan.du<fan.du@windriver.com>
>> ---
>>   include/net/xfrm.h    |    2 ++
>>   net/xfrm/xfrm_state.c |   22 ++++++++++++++++++----
>>   2 files changed, 20 insertions(+), 4 deletions(-)
>>
>> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
>> index 2933d74..1734acc 100644
>> --- a/include/net/xfrm.h
>> +++ b/include/net/xfrm.h
>> @@ -214,6 +214,8 @@ struct xfrm_state
>>   	/* Private data of this transformer, format is opaque,
>>   	 * interpreted by xfrm_type methods. */
>>   	void			*data;
>> +	u32				flags;
>
> We already have the xflags field, it holds exactly one flag
> at the moment. So I think we don't need yet another u32 that
> holds one flag too.
>

good point!
I will make it in the next version.


--=20

Love each day!
--fan
