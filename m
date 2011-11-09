From: Li Wei <lw@cn.fujitsu.com>
Subject: Re: [PATCH] ipv4: fix a bug in SRR option matching.
Date: Wed, 09 Nov 2011 15:37:55 +0800
Message-ID: <4EBA2DD3.1070204@cn.fujitsu.com>
References: <4EB8E0B8.40500@cn.fujitsu.com> <20111108.120621.691425261290061620.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60301 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753238Ab1KIHhd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Nov 2011 02:37:33 -0500
In-Reply-To: <20111108.120621.691425261290061620.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Li Wei <lw@cn.fujitsu.com>
> Date: Tue, 08 Nov 2011 15:56:40 +0800
> 
>> Since commit 7be799a7 (ipv4: Remove rt->rt_dst reference from
>> ip_forward_options()) and commit 0374d9ce (ipv4: Kill spurious
>> write to iph->daddr in ip_forward_options()) we use iph->daddr
>> for SRR option matching and assume iph->daddr equals to rt->rt_dst,
>> Unfortunately skb_rtable(skb) has been updated in ip_options_rcv_srr()
>> for the nexthop in SRR option but iph->daddr *not* updated,
>> We should use the updated rt->rt_dst for SRR option matching
>> and update iph->daddr here.
>>
>> Signed-off-by: Li Wei <lw@cn.fujitsu.com>
> 
> Please replace this by whatever logic ip_options_rcv_srr() uses to
> determine the destination address.
> 
> I would strongly encourage you, when fixing bugs like this, to use
> as a hint the intentions of the commit which introduced the bug.  And
> try as hard as possible to retain the goals of the guilty commit.
> 
> In this case, that means not introducing references to rt->rt_dst
> back into the code.
> 
> Thank you.
> 
> 

Thank you for your advice, I reviewed the code again think that as you said
in commit def57687, "No matter what kind of header mangling occurs due to IP
options processing, rt->rt_dst will always equal iph->daddr in the packet",
iph->daddr in ip_options_rcv_srr() should be updated either as skb_rtable(skb)
has been updated for 'nexthop'. So we can elide all rt->rt_dst reference
in ip_forward() and ip_forward_options().

I will submit another patch to fix this bug.
