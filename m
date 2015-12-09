From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] net:sysctl fix the confusing corner of tcp_mem
Date: Wed, 9 Dec 2015 16:47:34 +0300
Message-ID: <566830F6.705@cogentembedded.com>
References: <1449626509-3736-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: guohanjun@huawei.com, zhangdianfang@huawei.com,
	dingtianhong@huawei.com, huxinwei@huawei.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Wang Yufen <wangyufen@huawei.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:36790 "EHLO
	mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753083AbbLINrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 08:47:36 -0500
Received: by lfs39 with SMTP id 39so34747627lfs.3
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 05:47:35 -0800 (PST)
In-Reply-To: <1449626509-3736-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/9/2015 5:01 AM, Wang Yufen wrote:

> From: Yufen Wang <wangyufen@huawei.com>
>
> I tried on linux-4.1:
>      linux:~# cat /proc/sys/net/ipv4/tcp_mem
>      8388608	12582912	16777216
>      linux:~# echo 1234 >/proc/sys/net/ipv4/tcp_mem
>      -bash: echo: write error: Invalid argument
>      linux:~# cat /proc/sys/net/ipv4/tcp_mem
>      1234	12582912	16777216
>
> the echo operation got error, but value already written to tcp_mem.
> If a write() returns an error like EINVAL, we expect no change occurred.
> This patch fix the confusing corner and makes __do_proc_doulongvec_minmax
> works the same as __do_proc_dointvec
>
> Signed-off-by: Yufen Wang <wangyufen@huawei.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>   kernel/sysctl.c | 2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index c3eee4c..e3ee4be 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -2318,6 +2318,8 @@ static int __do_proc_doulongvec_minmax(void *data, struct ctl_table *table, int
>   			bool neg;
>
>   			left -= proc_skip_spaces(&kbuf);
> +                        if (!left)
> +                                break;

     Please use tabs for indentation, not spaces.

[...]

MBR, Sergei
