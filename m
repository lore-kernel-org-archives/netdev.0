From: Daniel Wagner <daniel.wagner@bmw-carit.de>
Subject: Re: [PATCH 7/9] sock, cgroup: add sock->sk_cgroup
Date: Mon, 23 Nov 2015 16:53:25 +0100
Message-ID: <56533675.2070603@bmw-carit.de>
References: <1448122441-9335-1-git-send-email-tj@kernel.org>
 <1448122441-9335-8-git-send-email-tj@kernel.org>
 <56530E4B.4090209@bmw-carit.de> <20151123154809.GD3049@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <pablo@netfilter.org>, <kaber@trash.net>,
	<kadlec@blackhole.kfki.hu>, <daniel@iogearbox.net>,
	<nhorman@tuxdriver.com>, <lizefan@huawei.com>,
	<hannes@cmpxchg.org>, <netdev@vger.kernel.org>,
	<netfilter-devel@vger.kernel.org>, <coreteam@netfilter.org>,
	<cgroups@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>, <ninasc@fb.com>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151123154809.GD3049@mtj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/23/2015 04:48 PM, Tejun Heo wrote:
> On Mon, Nov 23, 2015 at 02:02:03PM +0100, Daniel Wagner wrote:
>> On 11/21/2015 05:13 PM, Tejun Heo wrote:
>>> Signed-off-by: Tejun Heo <tj@kernel.org>
>>> Cc: Daniel Borkmann <daniel@iogearbox.net>
>>> Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>
>>
>> I did a quick test and for new connection the cgroup2 match worked as
>> expected. For an existing connection I wasn't able to trigger the match.
>>
>> It is quite likely I do something wrong:
>>
>> 	ssh into the box
>> 	# mkdir /sys/fs/cgroup/test
>> 	# echo $$ > /sys/fs/cgroup/test/cgroup.procs
>> 	# echo $PPID > /sys/fs/cgroup/test/cgroup.procs
>> 	# iptables -A OUTPUT -m cgroup --path test
>>
>> Should I see matches with the existing ssh session?
> 
> Socket is associated with the creating cgroup and stays associated
> with that cgroup until it's released.  Migrating the process doesn't
> change the ownership of the sockets it has created.  This is in line
> with how other stateful resources such as memory are handled in
> cgroup2 hierarchy.

Thanks for the explanation. Looks good to me:

Tested-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Acked-by: Daniel Wagner <daniel.wagner@bmw-carit.de>

Thanks,
Daniel
