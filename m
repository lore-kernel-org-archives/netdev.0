From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [patch -next] bpf: off by one in check_map_func_compatibility()
Date: Thu, 13 Aug 2015 22:31:50 +0200
Message-ID: <55CCFEB6.3080502@iogearbox.net>
References: <20150813202747.GA6478@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>,
	Alexei Starovoitov <ast@kernel.org>,
	Kaixu Xia <xiakaixu@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53530 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135AbbHMUb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 16:31:57 -0400
In-Reply-To: <20150813202747.GA6478@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/13/2015 10:27 PM, Dan Carpenter wrote:
> The loop iterates one space too far, so we might read beyond the end of
> the func_limit[] array.
>
> Fixes: 35578d798400 ('bpf: Implement function bpf_perf_event_read() that get the selected hardware PMU conuter')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Thanks for the fix, Dan!

There's however already one queued up here:

https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=140d8b335a9beb234fd0ed9a15aa6a47f47fd771

> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index 48e1c71..ed12e38 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
> @@ -853,7 +853,7 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
>   	if (!map)
>   		return 0;
>
> -	for (i = 0; i <= ARRAY_SIZE(func_limit); i++) {
> +	for (i = 0; i < ARRAY_SIZE(func_limit); i++) {
>   		bool_map = (map->map_type == func_limit[i].map_type);
>   		bool_func = (func_id == func_limit[i].func_id);
>   		/* only when map & func pair match it can continue.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
