From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] [BUGFIX] memcg/tcp : fix to see use_hierarchy in
 tcp memcontrol cgroup
Date: Thu, 29 Mar 2012 18:16:39 +0900
Message-ID: <4F742877.10402@jp.fujitsu.com>
References: <4F7408B7.9090706@jp.fujitsu.com> <4F74095B.70105@jp.fujitsu.com> <4F7427E4.2020307@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Glauber Costa <glommer@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:54153 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839Ab2C2JS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 05:18:29 -0400
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 9716F3EE0C3
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 18:18:27 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E78F45DD78
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 18:18:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2CA3B45DE54
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 18:18:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F2C0D1DB803E
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 18:18:26 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AF64B1DB803C
	for <netdev@vger.kernel.org>; Thu, 29 Mar 2012 18:18:26 +0900 (JST)
In-Reply-To: <4F7427E4.2020307@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2012/03/29 18:14), Glauber Costa wrote:

> On 03/29/2012 09:03 AM, KAMEZAWA Hiroyuki wrote:
>>
>> Now, tcp memory control cgroup ignores memcg's use_hierarchy value
>> and act as use_hierarchy=1 always. After this patch, tcp memcontrol will
>> work as memcg is designed.
>>
>> Note:
>>     I know there is a discussion to remove use_hierarchy but this is BUG, now.
>>
> 
> Kame,
> 
> Are you sure about that?
> 
> I just tried it myself, and it seems to work:
> 
> root@inf5072-11:~/glommer-temporary/a/b# cat memory.kmem.tcp.usage_in_bytes
> 724992
> root@inf5072-11:~/glommer-temporary/a/b# cat
> ../memory.kmem.tcp.usage_in_bytes
> 0
> 
> 
> Did you got this conclusion through testing or code inspection?
> 
> As a matter of fact, that's why I believe the current behavior is indeed
> correct:
> 
> the res_counter is initialized as:
> 
>         parent_cg = tcp_prot.proto_cgroup(parent);
>         if (parent_cg)
>                 res_parent = parent_cg->memory_allocated;
> 
>         res_counter_init(&tcp->tcp_memory_allocated, res_parent);
> 
> now, parent is drawn from parent_mem_cgroup(), that reads as follows:
> 
> struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg)
> {
>         if (!memcg->res.parent)
>                 return NULL;
>         return mem_cgroup_from_res_counter(memcg->res.parent, res);
> }
> 
> 
> so if we have use_hierarchy = 0, res.parent should be NULL (because that
> is the way we initialize it)
> 


Ah, sorry. you're right. please forget this patch.

To be honest, I wrote this after seeing WARN_ON in patch 2 and 3 and
misunderstood the code at writing patch 2 and 3.

Thanks,
-Kame
