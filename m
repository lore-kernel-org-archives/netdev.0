From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC 0/2] Optimize the snmp stat aggregation for large
 cpus
Date: Wed, 26 Aug 2015 15:55:05 +0530
Message-ID: <55DD9401.9090809@linux.vnet.ibm.com>
References: <y> <1440489266-31127-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20150825.160730.1747721171751442778.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, jiri@resnulli.us, edumazet@google.com,
	hannes@stressinduktion.org, tom@herbertland.com, azhou@nicira.com,
	ebiederm@xmission.com, ipm@chirality.org.uk,
	nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, anton@au1.ibm.com,
	nacc@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150825.160730.1747721171751442778.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/26/2015 04:37 AM, David Miller wrote:
> From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
> Date: Tue, 25 Aug 2015 13:24:24 +0530
>
>> Please let me know if you have suggestions/comments.
>
> Like Eric Dumazet said the idea is good but needs some adjustments.
>
> You might want to see whether a per-cpu work buffer works for this.

sure, Let me know if I understood correctly,

we allocate the temp buffer,
we will have a  "add_this_cpu_data" function and do

for_each_online_cpu(cpu)
                 smp_call_function_single(cpu, add_this_cpu_data, buffer, 1)

if not could you please point to an example you had in mind.

>
> It's extremely unfortunately that we can't depend upon the destination
> buffer being properly aligned, because we wouldn't need a temporary
> scratch area if it were aligned properly.

True, But I think for 64 bit cpus when (pad == 0) we can go ahead and
use stats array directly and get rid of put_unaligned(). is it correct?

(my internal initial patch had this version but thought it is ugly to
have ifdef BITS_PER_LONG==64)
