From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCHv2] xfrm: Fix kernel panic when flush and dump SPD	entries
Date: Mon, 01 Dec 2008 14:25:45 +0800
Message-ID: <49338369.4070405@cn.fujitsu.com>
References: <49334542.3070502@cn.fujitsu.com> <49334788.4030409@cn.fujitsu.com> <20081201050046.GB18292@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56050 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750827AbYLAGZL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2008 01:25:11 -0500
In-Reply-To: <20081201050046.GB18292@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Mon, Dec 01, 2008 at 10:10:16AM +0800, Wei Yongjun wrote:
>   
>> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
>> index 058f04f..fb216c9 100644
>> --- a/net/xfrm/xfrm_policy.c
>> +++ b/net/xfrm/xfrm_policy.c
>> @@ -817,6 +817,7 @@ int xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info)
>>  				continue;
>>  			hlist_del(&pol->bydst);
>>  			hlist_del(&pol->byidx);
>> +			list_del(&pol->walk.all);
>>     
>
> Good catch.  In fact there so man occurrences of these three calls
> that perhaps we should put them (and any other relevant code) in a
> helper.
>   

I think you mean used __xfrm_policy_unlink() function to instead those 
codes.

1098 static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy 
*pol,
1099                                                 int dir)
1100 {
1101         if (hlist_unhashed(&pol->bydst))
1102                 return NULL;
1103
1104         hlist_del(&pol->bydst);
1105         hlist_del(&pol->byidx);
1106         list_del(&pol->walk.all);
1107         xfrm_policy_count[dir]--;
1108
1109         return pol;
1110 }

I will post the patch later.


