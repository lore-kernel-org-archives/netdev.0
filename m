From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [RFC PATCH net-next 1/5]IPv6:netfilter: defrag:Introduce net
 namespace
Date: Thu, 25 Feb 2010 19:36:13 +0800
Message-ID: <4B8660AD.7030308@cn.fujitsu.com>
References: <b6fcc0a1002232348y6ff84ca8wf3bdf21de45fffbd@mail.gmail.com> <4B84E2A2.6020006@cn.fujitsu.com> <4B85321B.1090003@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61130 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1759252Ab0BYLgP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2010 06:36:15 -0500
In-Reply-To: <4B85321B.1090003@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote, at 02/24/2010 10:05 PM:
> Shan Wei wrote:
>> Alexey Dobriyan wrote, at 02/24/2010 03:48 PM:
>>>> -		.procname	= "nf_conntrack_frag6_timeout",
>>>> -		.data		= &nf_init_frags.timeout,
>>>> -		.maxlen		= sizeof(unsigned int),
>>>> -		.mode		= 0644,
>>>> -		.proc_handler	= proc_dointvec_jiffies,
>>> Why are you removing sysctls?
>> Because, after introduced net namespace, we can use net->ipv6.frags to 
>> manage IPv6 conntrack fragment queue instead of nf_init_frags. 
>> And sysctls of ip6frag_low_thresh, ip6frag_time and ip6frag_high_thresh 
>> also can control IPv6 conntrack fragment queue.
>>
>> So, private member of nf_init_frags becomes redundant, and remove these sysctls. 
> 
> You can't simply remove them without a warning, people might be
> using them.

How to provide a warning to user?
How about handle these sysctl ABIs like this:

s1) Retain these sysctls and refer .data to appropriate member of frags of init_net.
    Take nf_conntrack_frag6_timeout for example, .data = &init_net.ipv6.frags.timeout.

s2) When register sysctls of conntrack ipv6 protocol in nf_ct_l3proto_register_sysctl(),
    print a waring like this.
    "nf_conntrack_frag6_timeout and ip6frag_time, nf_conntrack_frag6_low_thresh and ip6frag_low_thresh,
     nf_conntrack_frag6_high_thresh and ip6frag_high_thresh, the three sets are equivalent. 
     nf_conntrack_frag6_timeout is just an alias for ip6frag_time. The former Parameters of IPv6 conntrack
     will be removed in the future, please use the latter ones of IPv6."

s3) Describe these removable sysctl ABIs in Documentation/feature-removal-schedule.txt


-- 
Best Regards
-----
Shan Wei
