From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: 2.6.28-git1 build failure
Date: Mon, 29 Dec 2008 17:33:29 +0800
Message-ID: <49589969.3020001@cn.fujitsu.com>
References: <495853C6.6030000@oracle.com> <49587FDD.5000504@cn.fujitsu.com> <20081229092436.GA25707@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Roland Dreier <rdreier@cisco.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, sean.hefty@intel.com,
	Aleksey Senin <alekseys@voltaire.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59154 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752637AbYL2Jdo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Dec 2008 04:33:44 -0500
In-Reply-To: <20081229092436.GA25707@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar said the following on 2008-12-29 17:24:
> * Wang Chen <wangchen@cn.fujitsu.com> wrote:
> 
>> Randy Dunlap said the following on 2008-12-29 12:36:
>>> drivers/built-in.o: In function `addr_resolve_remote':
>>> addr.c:(.text+0x12fe75): undefined reference to `ip6_route_output'
>>> drivers/built-in.o: In function `rdma_translate_ip':
>>> (.text+0x1301a7): undefined reference to `ipv6_chk_addr'
>>> drivers/built-in.o: In function `rdma_resolve_ip':
>>> (.text+0x1303a9): undefined reference to `ipv6_chk_addr'
>>> drivers/built-in.o: In function `rdma_resolve_ip':
>>> (.text+0x13051b): undefined reference to `ip6_route_output'
>>>
>>> when CONFIG_IPV6=n.
>>>
>> Aleksey added IPv6 function to it but not change the Kconfig file.
>> The following patch will temporarily fix this build failure.
>> But IMHO separating the IPv4/IPv6 parts or using #ifdef would be better.
>>
>> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
>> ---
>> diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
>> index a5dc78a..9535e13 100644
>> --- a/drivers/infiniband/Kconfig
>> +++ b/drivers/infiniband/Kconfig
>> @@ -36,7 +36,7 @@ config INFINIBAND_USER_MEM
>>  
>>  config INFINIBAND_ADDR_TRANS
>>  	bool
>> -	depends on INET
>> +	depends on INET && IPV6
>>  	default y
>>  
> 
> that's not good enough yet:
> 

Aleksey will fix it by adding #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) now.
See another thread "linux-next: origin tree build failure" :)

> net/built-in.o: In function `rpcrdma_ep_disconnect':
> (.text+0xf12c8): undefined reference to `rdma_disconnect'
> net/built-in.o: In function `rpcrdma_create_id':
> verbs.c:(.text+0xf13f9): undefined reference to `rdma_create_id'
> verbs.c:(.text+0xf1448): undefined reference to `rdma_resolve_addr'
> verbs.c:(.text+0xf14a7): undefined reference to `rdma_resolve_route'
> verbs.c:(.text+0xf14f9): undefined reference to `rdma_destroy_id'
> net/built-in.o: In function `rpcrdma_ep_connect':
> (.text+0xf15c4): undefined reference to `rdma_destroy_id'
> net/built-in.o: In function `rpcrdma_ep_connect':
> (.text+0xf15ce): undefined reference to `rdma_destroy_qp'
> net/built-in.o: In function `rpcrdma_ep_connect':
> (.text+0xf15d6): undefined reference to `rdma_destroy_id'
> net/built-in.o: In function `rpcrdma_ep_connect':
> (.text+0xf15e9): undefined reference to `rdma_create_qp'
> net/built-in.o: In function `rpcrdma_ep_connect':
> (.text+0xf16a3): undefined reference to `rdma_connect'
> net/built-in.o: In function `rpcrdma_ep_destroy':
> (.text+0xf1c28): undefined reference to `rdma_destroy_qp'
> net/built-in.o: In function `rpcrdma_ia_close':
> (.text+0xf223f): undefined reference to `rdma_destroy_qp'
> net/built-in.o: In function `rpcrdma_ia_close':
> (.text+0xf2247): undefined reference to `rdma_destroy_id'
> net/built-in.o: In function `rpcrdma_ia_open':
> (.text+0xf2503): undefined reference to `rdma_destroy_id'
> net/built-in.o: In function `svc_rdma_detach':
> svc_rdma_transport.c:(.text+0xf2b04): undefined reference to `rdma_disconnect'
> net/built-in.o: In function `svc_rdma_create':
> svc_rdma_transport.c:(.text+0xf3003): undefined reference to `rdma_create_id'
> svc_rdma_transport.c:(.text+0xf303d): undefined reference to `rdma_bind_addr'
> svc_rdma_transport.c:(.text+0xf306b): undefined reference to `rdma_listen'
> svc_rdma_transport.c:(.text+0xf30ba): undefined reference to `rdma_destroy_id'
> net/built-in.o: In function `__svc_rdma_free':
> svc_rdma_transport.c:(.text+0xf36f5): undefined reference to `rdma_destroy_id'
> net/built-in.o: In function `svc_rdma_accept':
> svc_rdma_transport.c:(.text+0xf43d2): undefined reference to `rdma_create_qp'
> svc_rdma_transport.c:(.text+0xf43f4): undefined reference to `rdma_create_qp'
> svc_rdma_transport.c:(.text+0xf45b2): undefined reference to `rdma_accept'
> svc_rdma_transport.c:(.text+0xf4699): undefined reference to `rdma_destroy_id'
> 
> with the attached config.
> 
> 	Ingo
> 
