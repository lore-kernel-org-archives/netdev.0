From: Daniel Wagner <wagi@monom.org>
Subject: Re: [PATCH v2 03/10] cgroup: net_cls: Protect access to task_cls_classid()
 when built as module
Date: Sat, 25 Aug 2012 18:56:29 +0200
Message-ID: <503903BD.6020208@monom.org>
References: <1345816904-21745-1-git-send-email-wagi@monom.org> <1345816904-21745-4-git-send-email-wagi@monom.org> <20120824232621.GQ21325@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cgroups@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Li Zefan <lizefan@huawei.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:41299 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753294Ab2HYQ4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2012 12:56:31 -0400
In-Reply-To: <20120824232621.GQ21325@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25.08.2012 01:26, Tejun Heo wrote:
> On Fri, Aug 24, 2012 at 04:01:37PM +0200, Daniel Wagner wrote:
>> @@ -306,6 +312,11 @@ static void __exit exit_cgroup_cls(void)
>>   	synchronize_rcu();
>>   #endif
>>
>> +#if IS_MODULE(CONFIG_NET_CLS_CGROUP)
>> +	static_key_slow_dec(&cgroup_cls_enabled);
>> +	rcu_barrier();
>
> Why is this rcu_barrier() necessary?

I have read the rcubarrier.txt document and I got from that that an 
rcu_barrier() is needed when unloading a module. But maybe I got it wrong.

So the idea after disabling the jump lables all pending readers in
task_cls_classid() have left. THe same thing is done in the old code 
with the dynamic id part. With the difference that synchronize_rcu() is 
used.

> In general, please explain what
> synchronization is going on when using sync constructs which aren't
> obvious - e.g. memory barriers, rcu barriers.

Sure, I will keep this in mind.
