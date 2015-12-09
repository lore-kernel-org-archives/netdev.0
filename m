From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net] net:sysctl fix the confusing corner of tcp_mem
Date: Wed, 09 Dec 2015 10:38:01 -0600
Message-ID: <877fknbms6.fsf@x220.int.ebiederm.org>
References: <1449626509-3736-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<guohanjun@huawei.com>, <zhangdianfang@huawei.com>,
	<dingtianhong@huawei.com>, <huxinwei@huawei.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Wang Yufen <wangyufen@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:50719 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751332AbbLIQq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 11:46:28 -0500
In-Reply-To: <1449626509-3736-1-git-send-email-wangyufen@huawei.com> (Wang
	Yufen's message of "Wed, 9 Dec 2015 10:01:49 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Yufen <wangyufen@huawei.com> writes:

> From: Yufen Wang <wangyufen@huawei.com>
>
> I tried on linux-4.1:
>     linux:~# cat /proc/sys/net/ipv4/tcp_mem 
>     8388608	12582912	16777216
>     linux:~# echo 1234 >/proc/sys/net/ipv4/tcp_mem 
>     -bash: echo: write error: Invalid argument
>     linux:~# cat /proc/sys/net/ipv4/tcp_mem 
>     1234	12582912	16777216
>
> the echo operation got error, but value already written to tcp_mem.
> If a write() returns an error like EINVAL, we expect no change occurred.
> This patch fix the confusing corner and makes __do_proc_doulongvec_minmax 
> works the same as __do_proc_dointvec

Nacked-by: "Eric W. Biederman" <ebiederm@xmission.com>

Except for possibly breaking your muscle memory this does not explain
why this is a problem.

Further you are changing a whole lot more than tcp_mem, without a word
of justification in your description.

I do not think changing every integer use of sysctl for some unknown
reason.  Is justified in this case.

Eric



> Signed-off-by: Yufen Wang <wangyufen@huawei.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  kernel/sysctl.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index c3eee4c..e3ee4be 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -2318,6 +2318,8 @@ static int __do_proc_doulongvec_minmax(void *data, struct ctl_table *table, int
>  			bool neg;
>  
>  			left -= proc_skip_spaces(&kbuf);
> +                        if (!left)
> +                                break;
>  
>  			err = proc_get_long(&kbuf, &left, &val, &neg,
>  					     proc_wspace_sep,
