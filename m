From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: Do cleanup for ip_mr_init
Date: Wed, 02 Jul 2008 17:38:16 +0800
Message-ID: <486B4C88.9030000@cn.fujitsu.com>
References: <48606D1B.3040507@cn.fujitsu.com> <20080702.181831.32808810.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61442 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751048AbYGBJm7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 05:42:59 -0400
In-Reply-To: <20080702.181831.32808810.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E said the follo=
wing on 2008-7-2 17:18:
> In article <48606D1B.3040507@cn.fujitsu.com> (at Tue, 24 Jun 2008 11:=
42:19 +0800), Wang Chen <wangchen@cn.fujitsu.com> says:
>=20
>> If do not do it, we will get following issues:
>> 1. Leaving junks after inet6_init failing halfway.
>> 2. Leaving proc and notifier junks after ipv6 modules unloading.
>>
>> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
>=20
>> diff --git a/include/linux/mroute6.h b/include/linux/mroute6.h
>> index e798959..05ffaac 100644
>> --- a/include/linux/mroute6.h
>> +++ b/include/linux/mroute6.h
>> diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
>> index e84b3fd..15d4138 100644
>> --- a/net/ipv6/af_inet6.c
>> +++ b/net/ipv6/af_inet6.c
>> @@ -1115,7 +1118,9 @@ static void __exit inet6_exit(void)
>>  	ipv6_netfilter_fini();
>>  	igmp6_cleanup();
>>  	ndisc_cleanup();
>> +#ifdef CONFIG_IPV6_MROUTE
>>  	icmpv6_cleanup();
>> +#endif
>>  	rawv6_exit();
>> =20
>>  	unregister_pernet_subsys(&inet6_net_ops);
>=20
> Well we really need this #ifdef ... #endif?
>=20

My fault.
I meant:
+#ifdef CONFIG_IPV6_MROUTE
+	ip6_mr_cleanup();
+#endif
	icmpv6_cleanup();
I will fix.

> And well, would you please make ip6_mr_init() return
> error and handle it correctly?
>=20

Sure, I will do it.

> We need to fix ipv4-side as well.
>=20

Of course, it can be done by me.

Thank you for the comments.

