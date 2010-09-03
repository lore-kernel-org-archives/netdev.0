From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [PATCH] cls_cgroup: Fix rcu lockdep warning
Date: Fri, 03 Sep 2010 09:10:00 +0800
Message-ID: <4C804AE8.1090203@cn.fujitsu.com>
References: <4C7F446F.8040303@cn.fujitsu.com> <1283423916.2059.1847.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Dave Jones <davej@redhat.com>, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1283423916.2059.1847.camel@laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Zijlstra wrote:
> On Thu, 2010-09-02 at 14:30 +0800, Li Zefan wrote:
>> Calling task_subsys_state() without holding rcu_read_lock or
>> cgroup_mutex can cause lockdep warning.
>>
> 
> That is not a suitable changelog.
> 
> Was the warning correct? Is your patch correct? What does RCU protect
> here and why can we use classid after dropping it.
> 
> Simply frobbing code to make the warning go away is not good.
> 
> 

task->cgroups and task->cgroups->subsys[i] are protected by RCU.
So we avoid accessing invalid pointers here. This can happen,
for example, when you are deref those pointers while someone move
@task from one cgroup to another.

otoh, there is no lock rule for ->classid.
