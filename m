From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Subject: Re: fib6_del_route has redundant code
Date: Fri, 28 Dec 2007 13:58:21 +0800
Message-ID: <4774907D.5070806@cn.fujitsu.com>
References: <477353B6.6000102@cn.fujitsu.com> <20071227.211808.221171928.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51112 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751170AbXL1F61 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Dec 2007 00:58:27 -0500
In-Reply-To: <20071227.211808.221171928.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> I think the following code in fib6_del_route in the latest kernel is useless.
>> 1125         if (fn->leaf == NULL && fn->fn_flags&RTN_TL_ROOT)
>> 1126                 fn->leaf = &ip6_null_entry;
>>
>> ip6_null_entry will never be unlinked from fn->leaf now, that is,
>> fn->leaf == NULL will never meet.
> 
> I think you are right, but if it is true the next block of
> code is dead too:
> 
> 	/* If it was last route, expunge its radix tree node */
> 	if (fn->leaf == NULL) {
> 		fn->fn_flags &= ~RTN_RTINFO;
> 		rt6_stats.fib_route_nodes--;
> 		fn = fib6_repair_tree(fn);
> 	}
> 
Dave,

I think this block of code can't be removed, because just the root(default route)
fn->leaf always has ip6_null_entry on it. The normal fn->leaf becomes NULL when last
route has been deleted, the radix tree should be expunged.

> But I am not completely convinced that all of these lines
> of code can be removed :-)
> 
> 

-- 


Regards
Gui Jianfeng
--------------------------------------------------
Gui Jianfeng
Development Dept.I
Nanjing Fujitsu Nanda Software Tech. Co., Ltd.(FNST)
8/F., Civil Defense Building, No.189 Guangzhou Road,
Nanjing, 210029, China
TEL: +86+25-86630566-838
COINS: 79955-838
FAX: +86+25-83317685
MAIL:guijianfeng@cn.fujitsu.com
--------------------------------------------------
