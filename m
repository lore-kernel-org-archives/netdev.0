From: Daniel Wagner <wagi@monom.org>
Subject: Re: [PATCH v0 5/5] cgroup: Assign subsystem IDs during compile time
Date: Fri, 17 Aug 2012 10:48:18 +0200
Message-ID: <502E0552.3080602@monom.org>
References: <1345126336-20755-1-git-send-email-wagi@monom.org> <1345126336-20755-6-git-send-email-wagi@monom.org> <20120816232010.GJ24861@google.com> <502DF1DF.8040109@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org,
	cgroups@vger.kernel.org,
	Daniel Wagner <daniel.wagner@bmw-carit.de>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Glauber Costa <glommer@parallels.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: Li Zefan <lizefan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:33580 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030972Ab2HQIsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2012 04:48:21 -0400
In-Reply-To: <502DF1DF.8040109@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17.08.2012 09:25, Li Zefan wrote:
> On 2012/8/17 7:20, Tejun Heo wrote:
>> On Thu, Aug 16, 2012 at 04:12:16PM +0200, Daniel Wagner wrote:
>>> From: Daniel Wagner <daniel.wagner@bmw-carit.de>
>>>
>>> We are able to safe some space when we assign the subsystem
>>> IDs at compile time. Instead of allocating per cgroup
>>> cgroup->subsys[CGROUP_SUBSYS_COUNT] where CGROUP_SUBSYS_COUNT is
>>> always 64, we allocate 12 + 1 at max (at this point there are 12
>>> subsystem).
>>
>> So, IIUC, this is effectively removing the capability to implement
>> modularized controller which isn't known at kernel compile time.  Am I
>> right?
>>
>
> I think so.

I am preparing an updated version which does not need the extra 1 
pointer. Some more preprocessor magic involved :)

>> I don't think that's a bad idea but if we're doing that, can't we make
>> things even simpler?  Do we need to distinguish in-kernel and module
>> at all?
>>
>> Li, what do you think about this?
>>
>
> I'm definitely all for simplicity, but I'm not sure if we can do better in
> simplifying the code for modularized cgroup subsystem. (I guess you didn't
> mean to remove this feature?)

The new version should also be simpler to review because I don't have to 
touch the loops everywhere.

daniel
