From: Alexey Perevalov <a.perevalov@samsung.com>
Subject: Re: [RFC PATCH v3] cgroup: net_cls: traffic counter based on
 classification control cgroup
Date: Mon, 14 Jan 2013 15:50:30 +0400
Message-ID: <50F3F106.50209@samsung.com>
References: <50F04502.9090902@samsung.com> <50F3BD26.6090903@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: cgroups@vger.kernel.org, Glauber Costa <glommer@parallels.com>,
	Kyungmin Park <kyungmin.park@samsung.com>,
	netdev@vger.kernel.org
To: Daniel Wagner <wagi@monom.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.w1.samsung.com ([210.118.77.11]:31680 "EHLO
	mailout1.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751795Ab3ANLud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 06:50:33 -0500
In-reply-to: <50F3BD26.6090903@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

also I got local benchmark result for 100 test.

It looks more trully


     *Local*    Communication    latencies    in    microseconds 
smaller    is    better

   2p/0K ctxsw     Pipe        AF Unix      UDP      RPC/UDP TCP    
RPC/TCP TCP conn
Kernel    without patch    Average values:        3.2809 9.12381    
8.2354    16.327    18.825    24.274    22.759 30.64
Kernel    with patch    Average values:             3.4718 9.61495    
8.5778    19.442    19.807    31.835    23.824 30.85

     *Local*    Communication    bandwidths    in    MB/s bigger    
is    better
Pipe          AF Unix    TCP          File reread    Mmap reread         
Bcopy (libc)    Bcopy (hand)    Mem read    Mem write
Kernel    without patch    Average values:        2119.25 6853.49    
3499.27      4421.796    7543.785             6176.899     3483.647     
      5603.29       6541.38
Kernel    with patch    Average values:             1966.7 6825.42    
3413.67      4426.936    7534.443 6170.924      3481.583          
5602.75       6520.42

Performance degradation exists. But I thing it can be solved, for 
example, by adding incrementation and searching appropriate cgroup to 
delayed timer (add_timer).


On 01/14/2013 12:09 PM, Daniel Wagner wrote:
> Hi Alexey,
>
> On 11.01.2013 17:59, Alexey Perevalov wrote:
>> I'm sorry for previous email with attachments.
>
> It seems something went wrong with the patch, e.g. indention is wrong 
> and also I see '^M$' line endings. I assume you are sending your 
> patches through an exchange server which is likely not to work.
>
>> I would like to represent next version of patch I sent before
>> cgroup: "net_cls: traffic counter based on classification control 
>> cgroup"
>>
>> The main idea is the same as was. It keeping counter in control groups,
>> but now uses atomic instead resource_counters.
>
> +#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
> + if (copied > 0)
> + count_cls_rcv(current, copied, ifindex);
> +#endif
> +
> release_sock(sk);
> return copied;
>
> Normally, distros will enable most config flags. Maybe you could use
> a jump label to reduce the cost for the users which have 
> CONFIG_NET_CLS_COUNTER enabled and do not use it?
>
>> I have a performance measurement for this patch. It was done by lmbench
>> on physical machine.
>> Results are not so representative for 20 tests and some numbers are real
>> weird.
>
> Could you explain in the commit message how your patch is designed? I 
> see you are using a RB tree. What's the purpose of it?
>
>> Daniel Wagner wrote what he is doing something similar, but using
>> namespaces.
>
> I am trying a different approach on this problem using iptables. I am 
> playing around with a few patches which allow to install a iptables rule
> which matches on the security context, e.g.
>
> iptables -t mangle -A OUTPUT -m secmark --secctx \
> unconfined_u:unconfined_r:foo_t:s0-s0:c0.c1023 -j MARK --set-mark 1
>
> So far it looks promising, but as I me previous networking experience 
> is, that something will not work eventually.
>
>> Proposed by me approach is used in upcoming Tizen release, but little
>> bit different version.
>
> Thanks,
> Daniel
>
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Best regards,
Alexey Perevalov,
Technical Leader,
phone: +7 (495) 797 25 00 ext 3969
e-mail: a.perevalov@samsung.com <mailto:a.perevalov@samsumng.com>

Mobile group, Moscow Samsung Research Center
12 Dvintsev street, building 1
127018, Moscow, Russian Federation
