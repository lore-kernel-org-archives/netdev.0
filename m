From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC 0/2] Optimize the snmp stat aggregation for large
 cpus
Date: Tue, 25 Aug 2015 21:25:41 +0530
Message-ID: <55DC8FFD.2020306@linux.vnet.ibm.com>
References: <y> <1440489266-31127-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <1440513231.8932.14.camel@edumazet-glaptop2.roam.corp.google.com>
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
In-Reply-To: <1440513231.8932.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/25/2015 08:03 PM, Eric Dumazet wrote:
> On Tue, 2015-08-25 at 13:24 +0530, Raghavendra K T wrote:
>> While creating 1000 containers, perf is showing lot of time spent in
>> snmp_fold_field on a large cpu system.
>>
>> The current patch tries to improve by reordering the statistics gathering.
>>
>> Please note that similar overhead was also reported while creating
>> veth pairs  https://lkml.org/lkml/2013/3/19/556
>>
>> Setup:
>> 160 cpu (20 core) baremetal powerpc system with 1TB memory
>
> I wonder if these kind of results would demonstrate cache coloring
> problems on this host. Looks like all the per cpu data are colliding on
> same cache lines.
>

It could be. My testing on a 128 cpu system with less memory did not
incur huge time penalty for 1000 containers.
But snmp_fold_field in general had the problem.
for e.g. same experiment I had around 15% overhead for snmp_fold reduced 
to 5% after the patch.
