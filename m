From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: delete protocol when cleanup
Date: Wed, 19 Nov 2014 09:10:56 +0800
Message-ID: <546BEE20.6060907@cn.fujitsu.com>
References: <546B20F8.6010806@cn.fujitsu.com> <CAHA+R7PNmac7KQpSK-vO9zVd3+926f6n_GpaGrbpBnSn98xiyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:54484 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753660AbaKSBNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 20:13:22 -0500
In-Reply-To: <CAHA+R7PNmac7KQpSK-vO9zVd3+926f6n_GpaGrbpBnSn98xiyQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/19/2014 02:56 AM, Cong Wang wrote:
> On Tue, Nov 18, 2014 at 2:35 AM, Duan Jiong <duanj.fnst@cn.fujitsu.com> wrote:
>>
>> pim6_protocol was added when initiation, but it not deleted.
>>
>> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>> ---
>>  net/ipv6/ip6mr.c | 3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
>> index 0171f08..6dcdecd 100644
>> --- a/net/ipv6/ip6mr.c
>> +++ b/net/ipv6/ip6mr.c
>> @@ -1439,6 +1439,9 @@ reg_pernet_fail:
>>
>>  void ip6_mr_cleanup(void)
>>  {
>> +#ifdef CONFIG_IPV6_PIMSM_V2
>> +       inet6_del_protocol(&pim6_protocol, IPPROTO_PIM);
>> +#endif
>>         unregister_netdevice_notifier(&ip6_mr_notifier);
>>         unregister_pernet_subsys(&ip6mr_net_ops);
>>         kmem_cache_destroy(mrt_cachep);
> 
> 
> Looks like rtnl_unregister() is missing as well.
> 

Thanks for pointing this, i will send v2.

Thanks,
  Duan
