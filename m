From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC 2/2] net: Optimize snmp stat aggregation by walking
 all the percpu data at once
Date: Wed, 26 Aug 2015 16:34:29 +0530
Message-ID: <55DD9D3D.6050003@linux.vnet.ibm.com>
References: <y> <1440489266-31127-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <1440489266-31127-3-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <1440512908.8932.11.camel@edumazet-glaptop2.roam.corp.google.com> <55DC8E06.2040007@linux.vnet.ibm.com> <1440518424.8932.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, jiri@resnulli.us,
	edumazet@google.com, hannes@stressinduktion.org,
	tom@herbertland.com, azhou@nicira.com, ebiederm@xmission.com,
	ipm@chirality.org.uk, nicolas.dichtel@6wind.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	anton@au1.ibm.com, nacc@linux.vnet.ibm.com,
	srikar@linux.vnet.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440518424.8932.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/25/2015 09:30 PM, Eric Dumazet wrote:
> On Tue, 2015-08-25 at 21:17 +0530, Raghavendra K T wrote:
>> On 08/25/2015 07:58 PM, Eric Dumazet wrote:
>
>>>
>>>
>>> This is a great idea, but kcalloc()/kmalloc() can fail and you'll crash
>>> the whole kernel at this point.
>>>
>>
>> Good catch, and my bad. Though system is in bad memory condition,
>> since fill_stat is not critical for the system do you think silently
>> returning from here is a good idea?
>> or do you think we should handle with -ENOMEM way up.?
>
> Hmm... presumably these 288 bytes could be allocated in
> inet6_fill_ifla6_attrs() stack frame.

Correct, since we need to allocate  for IPSTATS_MIB_MAX, we could do 
this in even snmp6_fill_stats() stack frame.
