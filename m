From: Glauber Costa <glommer@parallels.com>
Subject: Re: [PATCH 1/3] don't attach a task to a dead cgroup
Date: Fri, 20 Apr 2012 12:05:31 -0300
Message-ID: <4F917B3B.1060704@parallels.com>
References: <1334875758-20939-1-git-send-email-glommer@parallels.com> <1334875758-20939-2-git-send-email-glommer@parallels.com> <20120419225322.GC10553@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <cgroups@vger.kernel.org>,
	Li Zefan <lizefan@huawei.com>,
	<kamezawa.hiroyu@jp.fujitsu.com>,
	David Miller <davem@davemloft.net>, <devel@openvz.org>
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:60523 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932491Ab2DTPHQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2012 11:07:16 -0400
In-Reply-To: <20120419225322.GC10553@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/19/2012 07:53 PM, Tejun Heo wrote:
> On Thu, Apr 19, 2012 at 07:49:16PM -0300, Glauber Costa wrote:
>> Not all external callers of cgroup_attach_task() test to
>> see if the cgroup is still live - the internal callers at
>> cgroup.c does.
>>
>> With this test in cgroup_attach_task, we can assure that
>> no tasks are ever moved to a cgroup that is past its
>> destruction point and was already marked as dead.
>>
>> Signed-off-by: Glauber Costa<glommer@parallels.com>
>> CC: Tejun Heo<tj@kernel.org>
>> CC: Li Zefan<lizefan@huawei.com>
>> CC: Kamezawa Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>>   kernel/cgroup.c |    3 +++
>>   1 files changed, 3 insertions(+), 0 deletions(-)
>>
>> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
>> index b61b938..932c318 100644
>> --- a/kernel/cgroup.c
>> +++ b/kernel/cgroup.c
>> @@ -1927,6 +1927,9 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
>>   	struct cgroup_taskset tset = { };
>>   	struct css_set *newcg;
>>
>> +	if (cgroup_is_removed(cgrp))
>> +		return -ENODEV;
>> +
>
> Isn't the test in cgroup_lock_live_group() enough?
>
Yes, when it is done.

Not all callers take it, specially the external ones.
